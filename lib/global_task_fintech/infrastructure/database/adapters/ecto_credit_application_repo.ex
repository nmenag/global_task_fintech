defmodule GlobalTaskFintech.Infrastructure.Database.Adapters.EctoCreditApplicationRepo do
  @moduledoc """
  Ecto adapter implementation for the CreditApplication repository port.
  """
  @behaviour GlobalTaskFintech.Domain.Ports.CreditApplicationRepo

  alias GlobalTaskFintech.Repo
  alias GlobalTaskFintech.Infrastructure.Database.Schemas.CreditApplicationSchema
  alias GlobalTaskFintech.Domain.Entities.CreditApplication

  @impl true
  def save(%CreditApplication{} = entity) do
    changes = Map.from_struct(entity)

    result =
      case entity.id do
        nil ->
          %CreditApplicationSchema{}
          |> CreditApplicationSchema.changeset(changes)
          |> Repo.insert()

        id ->
          case Repo.get(CreditApplicationSchema, id) do
            nil ->
              {:error, :not_found}

            schema ->
              schema
              |> CreditApplicationSchema.changeset(changes)
              |> Repo.update()
          end
      end

    case result do
      {:ok, schema} -> {:ok, CreditApplicationSchema.to_entity(schema)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @impl true
  def get(id) do
    case Repo.get(CreditApplicationSchema, id) do
      nil -> {:error, :not_found}
      schema -> {:ok, CreditApplicationSchema.to_entity(schema)}
    end
  end

  @impl true
  def list do
    CreditApplicationSchema
    |> Repo.all()
    |> Enum.map(&CreditApplicationSchema.to_entity/1)
  end
end
