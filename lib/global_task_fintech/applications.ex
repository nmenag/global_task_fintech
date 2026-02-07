defmodule GlobalTaskFintech.Applications do
  @moduledoc """
  The Applications context, now acting as a facade for the Hexagonal Architecture.
  """

  import Ecto.Query, warn: false
  alias GlobalTaskFintech.Repo

  alias GlobalTaskFintech.Infrastructure.Database.Schemas.CreditApplicationSchema
  alias GlobalTaskFintech.Infrastructure.Database.Adapters.EctoCreditApplicationRepo
  alias GlobalTaskFintech.Domain.Models.CreditApplication
  alias GlobalTaskFintech.Domain.Services.CreateCreditApplication

  @repo EctoCreditApplicationRepo

  @doc """
  Returns the list of credit_applications.
  """
  def list_credit_applications(filters \\ %{}) do
    @repo.list(filters)
  end

  @doc """
  Gets a single credit_application.
  """
  def get_credit_application!(id) do
    case @repo.get(id) do
      {:ok, entity} -> entity
      {:error, :not_found} -> raise Ecto.NoResultsError, queryable: CreditApplicationSchema
    end
  end

  @doc """
  Creates a credit_application.
  """
  def create_credit_application(attrs) do
    CreateCreditApplication.execute(attrs)
  end

  @doc """
  Initializes a new credit_application model.
  """
  def new_credit_application(attrs \\ %{}) do
    struct(CreditApplication, attrs)
  end

  @doc """
  Updates a credit_application.
  """
  def update_credit_application(entity, attrs) do
    # Convert entity back to schema for Ecto update
    case Repo.get(CreditApplicationSchema, entity.id) do
      nil ->
        {:error, :not_found}

      schema ->
        schema
        |> CreditApplicationSchema.changeset(attrs)
        |> Repo.update()
        |> case do
          {:ok, schema} -> {:ok, CreditApplicationSchema.to_entity(schema)}
          {:error, changeset} -> {:error, changeset}
        end
    end
  end

  @doc """
  Deletes a credit_application.
  """
  def delete_credit_application(entity) do
    case Repo.get(CreditApplicationSchema, entity.id) do
      nil ->
        {:error, :not_found}

      schema ->
        case Repo.delete(schema) do
          {:ok, schema} -> {:ok, CreditApplicationSchema.to_entity(schema)}
          {:error, changeset} -> {:error, changeset}
        end
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking credit_application changes.
  """
  def change_credit_application(entity_or_schema, attrs \\ %{}) do
    case entity_or_schema do
      %CreditApplication{} = entity ->
        CreditApplicationSchema.from_entity(entity)
        |> CreditApplicationSchema.changeset(attrs)

      %CreditApplicationSchema{} = schema ->
        CreditApplicationSchema.changeset(schema, attrs)
    end
  end
end
