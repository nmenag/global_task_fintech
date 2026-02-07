defmodule GlobalTaskFintech.Applications do
  @moduledoc """
  The Applications context, handling the orchestration of credit application business logic.
  It manages persistence and provides a facade for domain services.
  """

  import Ecto.Query, warn: false
  alias GlobalTaskFintech.Repo
  alias GlobalTaskFintech.Domain.Models.CreditApplication
  alias GlobalTaskFintech.Domain.Services.CreateCreditApplication

  @doc """
  Returns the list of credit_applications with optional filtering.
  """
  def list_credit_applications(filters \\ %{}) do
    query = from(c in CreditApplication, order_by: [desc: c.inserted_at])

    query
    |> filter_by_country(filters["country"])
    |> filter_by_status(filters["status"])
    |> Repo.all()
  end

  @doc """
  Gets a single credit_application.
  """
  def get_credit_application!(id) do
    Repo.get!(CreditApplication, id)
  end

  @doc """
  Creates a credit_application via the domain service.
  """
  def create_credit_application(attrs) do
    CreateCreditApplication.execute(attrs)
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
    case attrs["id"] || attrs[:id] do
      nil ->
        %CreditApplication{}
        |> CreditApplication.changeset(attrs)
        |> Repo.insert()

      id ->
        get_credit_application!(id)
        |> CreditApplication.changeset(attrs)
        |> Repo.update()
    end
  end

  @doc """
  Updates a credit_application.
  """
  def update_credit_application(%CreditApplication{} = application, attrs) do
    application
    |> CreditApplication.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a credit_application.
  """
  def delete_credit_application(%CreditApplication{} = application) do
    Repo.delete(application)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking credit_application changes.
  """
  def change_credit_application(%CreditApplication{} = application, attrs \\ %{}) do
    CreditApplication.changeset(application, attrs)
  end

  # Private filtering helpers

  defp filter_by_country(query, nil), do: query
  defp filter_by_country(query, ""), do: query
  defp filter_by_country(query, country), do: from(c in query, where: c.country == ^country)

  defp filter_by_status(query, nil), do: query
  defp filter_by_status(query, ""), do: query
  defp filter_by_status(query, status), do: from(c in query, where: c.status == ^status)
end
