defmodule GlobalTaskFintech.Applications do
  @moduledoc """
  The Applications context, handling the orchestration of credit application business logic.
  It provides a facade for domain services and repositories.
  """

  alias GlobalTaskFintech.Domain.Models.CreditApplication
  alias GlobalTaskFintech.Domain.Services.CreateCreditApplication
  alias GlobalTaskFintech.Infrastructure.Repositories.CreditApplicationRepository
  alias GlobalTaskFintech.Domain.Services.EvaluateRisk
  alias GlobalTaskFintech.Domain.Services.GetDocumentTypes
  alias GlobalTaskFintech.Domain.Services.AuditService

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
    case CreditApplicationRepository.update(application, attrs) do
      {:ok, updated_application} ->
        if needs_reevaluation?(attrs) do
          GlobalTaskFintech.Infrastructure.Jobs.BackgroundJob.run(
            EvaluateRisk,
            :execute,
            [updated_application]
          )
        end

        Phoenix.PubSub.broadcast(
          GlobalTaskFintech.PubSub,
          "credit_applications",
          {:application_updated, updated_application}
        )

        Phoenix.PubSub.broadcast(
          GlobalTaskFintech.PubSub,
          "credit_applications:#{updated_application.id}",
          {:application_updated, updated_application}
        )

        action =
          if application.status != updated_application.status,
            do: :status_transition,
            else: :update

        AuditService.log_async(:credit_application, application.id, action,
          previous_state: application,
          new_state: updated_application,
          country: updated_application.country
        )

        {:ok, updated_application}

      error ->
        error
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

  @doc """
  Returns the available document types for a given country.
  """
  def get_document_types(country) do
    GetDocumentTypes.execute(country)
  end
end
