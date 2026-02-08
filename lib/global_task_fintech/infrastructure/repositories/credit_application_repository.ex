defmodule GlobalTaskFintech.Infrastructure.Repositories.CreditApplicationRepository do
  @moduledoc """
  Persistence logic for Credit Applications.
  """
  import Ecto.Query
  alias GlobalTaskFintech.Repo
  alias GlobalTaskFintech.Domain.Models.CreditApplication

  def list(filters \\ %{}) do
    query = from(c in CreditApplication, order_by: [desc: c.inserted_at])

    query
    |> filter_by_country(filters["country"])
    |> filter_by_status(filters["status"])
    |> Repo.all()
  end

  def get!(id), do: Repo.get!(CreditApplication, id)

  def save(attrs) do
    case attrs["id"] || attrs[:id] do
      nil ->
        %CreditApplication{}
        |> CreditApplication.changeset(attrs)
        |> Repo.insert()

      id ->
        get!(id)
        |> CreditApplication.changeset(attrs)
        |> Repo.update()
    end
  end

  def update(%CreditApplication{} = application, attrs) do
    application
    |> CreditApplication.changeset(attrs)
    |> Repo.update()
  end

  def delete(%CreditApplication{} = application) do
    Repo.delete(application)
  end

  defp filter_by_country(query, nil), do: query
  defp filter_by_country(query, ""), do: query
  defp filter_by_country(query, country), do: from(c in query, where: c.country == ^country)

  defp filter_by_status(query, nil), do: query
  defp filter_by_status(query, ""), do: query
  defp filter_by_status(query, status), do: from(c in query, where: c.status == ^status)
end
