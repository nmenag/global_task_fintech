defmodule GlobalTaskFintech.Domain.Services.CreateCreditApplication do
  @moduledoc """
  Service for creating a new Credit Application.
  Coordinates synchronous fetching and asynchronous side effects.
  """
  alias GlobalTaskFintech.Applications
  alias GlobalTaskFintech.Infrastructure.Banks

  def execute(attrs) do
    case fetch_bank_data(attrs) do
      {:ok, bank_info} ->
        attrs
        |> put_bank_data(bank_info)
        |> Applications.save_credit_application()
        |> case do
          {:ok, application} ->
            trigger_side_effects(application)
            {:ok, application}

          {:error, changeset} ->
            {:error, changeset}
        end

      {:error, :unsupported_country} ->
        {:error, :unsupported_country}

      {:error, _} ->
        save_without_bank_data(attrs)
    end
  end

  defp save_without_bank_data(attrs) do
    attrs
    |> put_bank_data(nil)
    |> Applications.save_credit_application()
    |> case do
      {:ok, application} ->
        trigger_side_effects(application)
        {:ok, application}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp trigger_side_effects(application) do
    %{"application_id" => application.id}
    |> GlobalTaskFintech.Workers.RiskEvaluationWorker.new()
    |> Oban.insert()
  end

  defp fetch_bank_data(%{
         "country" => country,
         "document_type" => document_type,
         "document_number" => document_number
       })
       when not is_nil(country) and not is_nil(document_type) and not is_nil(document_number) do
    Banks.fetch_data(country, document_type, document_number)
  end

  defp fetch_bank_data(%{country: c, document_type: t, document_number: n})
       when not is_nil(c) and not is_nil(t) and not is_nil(n),
       do: Banks.fetch_data(c, t, n)

  defp fetch_bank_data(_), do: {:error, :invalid_attributes}

  defp put_bank_data(attrs, value) do
    if Map.has_key?(attrs, :country) do
      Map.put(attrs, :bank_data, value)
    else
      Map.put(attrs, "bank_data", value)
    end
  end
end
