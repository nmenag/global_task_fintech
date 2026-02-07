defmodule GlobalTaskFintech.Applications do
  @moduledoc """
  The Applications context, now acting as a facade for the Hexagonal Architecture.
  """

  import Ecto.Query, warn: false
  alias GlobalTaskFintech.Repo

  alias GlobalTaskFintech.Infrastructure.Database.Schemas.CreditApplicationSchema
  alias GlobalTaskFintech.Infrastructure.Database.Adapters.EctoCreditApplicationRepo
  alias GlobalTaskFintech.Domain.Entities.CreditApplication

  @repo EctoCreditApplicationRepo

  @doc """
  Returns the list of credit_applications.
  """
  def list_credit_applications do
    @repo.list()
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
    # Using the repository directly for CRUD, or could use the Use Case
    # To keep compatibility with LiveView, we return the {:ok, entity} or {:error, changeset}

    %CreditApplicationSchema{}
    |> CreditApplicationSchema.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, schema} -> {:ok, CreditApplicationSchema.to_entity(schema)}
      {:error, changeset} -> {:error, changeset}
    end
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
