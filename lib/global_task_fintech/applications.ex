defmodule GlobalTaskFintech.Applications do
  @moduledoc """
  The Applications context, handling the orchestration of credit application business logic.
  It provides a facade for domain services and repositories.
  """

  alias GlobalTaskFintech.Domain.Models.CreditApplication
  alias GlobalTaskFintech.Domain.Services.AuditService
  alias GlobalTaskFintech.Domain.Services.CreateCreditApplication
  alias GlobalTaskFintech.Domain.Services.GetDocumentTypes
  alias GlobalTaskFintech.Infrastructure.Repositories.CreditApplicationRepository

  @doc """
  Returns the list of credit_applications with optional filtering.
  """
  def list_credit_applications(filters \\ %{}) do
    CreditApplicationRepository.list(filters)
  end

  @doc """
  Gets a single credit_application.
  """
  def get_credit_application!(id) do
    CreditApplicationRepository.get!(id)
  end

  @doc """
  Gets a single credit_application. Returns nil if not found.
  """
  def get_credit_application(id) do
    CreditApplicationRepository.get(id)
  end

  @doc """
  Creates a credit_application via the domain service.
  """
  def create_credit_application(attrs) do
    case CreateCreditApplication.execute(attrs) do
      {:ok, application} ->
        Phoenix.PubSub.broadcast(
          GlobalTaskFintech.PubSub,
          "credit_applications",
          {:application_created, application}
        )

        AuditService.log_async(:credit_application, application.id, :create,
          new_state: application,
          country: application.country
        )

        {:ok, application}

      error ->
        error
    end
  end

  @doc """
  Initializes a new credit_application struct.
  """
  def new_credit_application(attrs \\ %{}) do
    %CreditApplication{}
    |> Map.merge(attrs)
  end

  @doc """
  Saves or updates a credit_application directly.
  """
  def save_credit_application(attrs) do
    CreditApplicationRepository.save(attrs)
  end

  @doc """
  Updates a credit_application.
  """
  def update_credit_application(%CreditApplication{} = application, attrs) do
    CreditApplicationRepository.transaction(fn ->
      do_update(application, attrs)
    end)
    |> case do
      {:ok, updated_application} ->
        broadcast_application_update(application, updated_application)
        {:ok, updated_application}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp do_update(application, attrs) do
    with {:ok, locked_app} <- fetch_and_lock(application.id),
         {:ok, updated_app} <- CreditApplicationRepository.update(locked_app, attrs) do
      finalize_update(locked_app, updated_app, attrs)
    end
    |> case do
      {:error, reason} -> CreditApplicationRepository.rollback(reason)
      updated_app -> updated_app
    end
  end

  defp fetch_and_lock(id) do
    case CreditApplicationRepository.get_for_update(id) do
      nil -> {:error, :not_found}
      application -> {:ok, application}
    end
  end

  defp finalize_update(locked_app, updated_app, attrs) do
    action = resolve_update_action(locked_app, updated_app)
    opts = CreditApplicationRepository.default_transaction_opts()

    maybe_reevaluate_risk(updated_app, attrs, opts)
    maybe_dispatch_webhook(action, updated_app, opts)

    AuditService.log_async(
      :credit_application,
      locked_app.id,
      action,
      Keyword.merge(opts,
        previous_state: locked_app,
        new_state: updated_app,
        country: updated_app.country
      )
    )

    updated_app
  end

  defp broadcast_application_update(old_app, updated_app) do
    Phoenix.PubSub.broadcast(
      GlobalTaskFintech.PubSub,
      "credit_applications",
      {:application_updated, updated_app}
    )

    Phoenix.PubSub.broadcast(
      GlobalTaskFintech.PubSub,
      "credit_applications:#{updated_app.id}",
      {:application_updated, updated_app}
    )

    case resolve_update_action(old_app, updated_app) do
      :status_transition ->
        Phoenix.PubSub.broadcast(
          GlobalTaskFintech.PubSub,
          "domain_events",
          {:status_changed, updated_app, old_app.status, updated_app.status}
        )

      _ ->
        :ok
    end
  end

  defp needs_reevaluation?(attrs) do
    relevant_keys = [
      "monthly_income",
      "amount_requested",
      "country",
      "document_type",
      "document_number",
      :monthly_income,
      :amount_requested,
      :country,
      :document_type,
      :document_number
    ]

    Enum.any?(relevant_keys, &Map.has_key?(attrs, &1))
  end

  @doc """
  Deletes a credit_application.
  """
  def delete_credit_application(%CreditApplication{} = application) do
    case CreditApplicationRepository.delete(application) do
      {:ok, deleted_application} ->
        AuditService.log_async(:credit_application, application.id, :delete,
          previous_state: application,
          country: application.country
        )

        {:ok, deleted_application}

      error ->
        error
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking credit_application changes.
  """
  def change_credit_application(%CreditApplication{} = application, attrs \\ %{}) do
    CreditApplication.changeset(application, attrs)
  end

  defp maybe_reevaluate_risk(application, attrs, opts) do
    attrs
    |> needs_reevaluation?()
    |> dispatch_reevaluation(application, opts)
  end

  defp dispatch_reevaluation(true, application, opts) do
    %{"application_id" => application.id}
    |> GlobalTaskFintech.Workers.RiskEvaluationWorker.new()
    |> Oban.insert(opts)
  end

  defp dispatch_reevaluation(false, _, _), do: :ok

  @doc """
  Returns the available document types for a given country.
  """
  def get_document_types(country) do
    GetDocumentTypes.execute(country)
  end

  defp resolve_update_action(%{status: s}, %{status: s}), do: :update
  defp resolve_update_action(_, _), do: :status_transition

  defp maybe_dispatch_webhook(:status_transition, application, opts) do
    %{"application_id" => application.id}
    |> GlobalTaskFintech.Workers.WebhookWorker.new()
    |> Oban.insert(opts)
  end

  defp maybe_dispatch_webhook(_, _, _), do: :ok
end
