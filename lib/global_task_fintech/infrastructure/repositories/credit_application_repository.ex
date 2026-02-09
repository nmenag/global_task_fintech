defmodule GlobalTaskFintech.Infrastructure.Repositories.CreditApplicationRepository do
  @moduledoc """
  Persistence logic for Credit Applications.
  """
  import Ecto.Query
  alias GlobalTaskFintech.Domain.Models.CreditApplication
  alias GlobalTaskFintech.Repo

  def list(filters \\ %{}) do
    query = from(c in CreditApplication, order_by: [desc: c.inserted_at])

    query
    |> filter_by_country(filters["country"])
    |> filter_by_status(filters["status"])
    |> filter_by_date(filters)
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

  defp filter_by_date(query, %{"start_date" => start_date, "end_date" => end_date}) do
    query
    |> maybe_filter_start_date(start_date)
    |> maybe_filter_end_date(end_date)
  end

  defp filter_by_date(query, _), do: query

  defp maybe_filter_start_date(query, date) when date in [nil, ""], do: query

  defp maybe_filter_start_date(query, date) do
    {:ok, dt} = Date.from_iso8601(date)
    start_dt = DateTime.new!(dt, ~T[00:00:00], "Etc/UTC")
    from(c in query, where: c.inserted_at >= ^start_dt)
  end

  defp maybe_filter_end_date(query, date) when date in [nil, ""], do: query

  defp maybe_filter_end_date(query, date) do
    {:ok, dt} = Date.from_iso8601(date)
    end_dt = DateTime.new!(dt, ~T[23:59:59], "Etc/UTC")
    from(c in query, where: c.inserted_at <= ^end_dt)
  end
end
