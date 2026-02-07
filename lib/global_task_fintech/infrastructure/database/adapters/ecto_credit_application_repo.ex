defmodule GlobalTaskFintech.Infrastructure.Database.Adapters.EctoCreditApplicationRepo do
  @moduledoc """
  Ecto adapter implementation for the CreditApplication repository port.
  """
  @behaviour GlobalTaskFintech.Domain.Ports.CreditApplicationRepo

  alias GlobalTaskFintech.Repo
  alias GlobalTaskFintech.Infrastructure.Database.Schemas.CreditApplicationSchema
  alias GlobalTaskFintech.Domain.Models.CreditApplication

  import Ecto.Query

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
  def list(filters \\ %{}) do
    query = from(c in CreditApplicationSchema, order_by: [desc: c.inserted_at])

    query
    |> filter_by_country(filters["country"])
    |> filter_by_status(filters["status"])
    |> Repo.all()
    |> Enum.map(&CreditApplicationSchema.to_entity/1)
  end

  defp filter_by_country(query, nil), do: query
  defp filter_by_country(query, ""), do: query
  defp filter_by_country(query, country), do: from(c in query, where: c.country == ^country)

  defp filter_by_status(query, nil), do: query
  defp filter_by_status(query, ""), do: query
  defp filter_by_status(query, status), do: from(c in query, where: c.status == ^status)
end
