defmodule GlobalTaskFintech.Applications do
  @moduledoc """
  The Applications context, handling the orchestration of credit application business logic.
  It provides a facade for domain services and repositories.
  """

  alias GlobalTaskFintech.Domain.Models.CreditApplication
  alias GlobalTaskFintech.Domain.Services.CreateCreditApplication
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
    CreditApplicationRepository.save(attrs)
  end

  @doc """
  Updates a credit_application.
  """
  def update_credit_application(%CreditApplication{} = application, attrs) do
    CreditApplicationRepository.update(application, attrs)
  end

  @doc """
  Deletes a credit_application.
  """
  def delete_credit_application(%CreditApplication{} = application) do
    CreditApplicationRepository.delete(application)
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
  def get_document_types("MX") do
    [
      {"INE", "ine"},
      {"CURP", "curp"},
      {"RFC", "rfc"},
      {"pasaporte", "passport"}
    ]
  end

  def get_document_types("CO") do
    [
      {"Cédula de Ciudadanía (CC)", "cc"},
      {"Cédula de Extranjería (CE)", "ce"},
      {"NIT", "nit"},
      {"pasaporte", "passport"}
    ]
  end

  def get_document_types(_) do
    [
      {"National ID", "id_card"},
      {"Passport", "passport"}
    ]
  end
end
