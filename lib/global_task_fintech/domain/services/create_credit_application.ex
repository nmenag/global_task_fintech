defmodule GlobalTaskFintech.Domain.Services.CreateCreditApplication do
  @moduledoc """
  Service for creating a new Credit Application.
  Coordinates synchronous fetching and asynchronous side effects.
  """
  alias GlobalTaskFintech.Applications
  alias GlobalTaskFintech.Infrastructure.Banks
  alias GlobalTaskFintech.Infrastructure.Jobs.BackgroundJob
  alias GlobalTaskFintech.Infrastructure.Audit.AuditLogger
  alias GlobalTaskFintech.Domain.Services.EvaluateRisk

  def execute(attrs) do
    attrs = stringify_keys(attrs)

    case fetch_bank_data(attrs) do
      {:ok, bank_info} ->
        attrs
        |> Map.put("bank_data", bank_info)
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
    |> Map.put("bank_data", nil)
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
    BackgroundJob.run(AuditLogger, :log_creation, [application])

    BackgroundJob.run(EvaluateRisk, :execute, [application])
  end

  defp fetch_bank_data(%{"country" => country, "document_type" => type, "document_value" => val})
       when not is_nil(country) and not is_nil(type) and not is_nil(val) do
    Banks.fetch_data(country, type, val)
  end

  defp fetch_bank_data(_), do: {:error, :invalid_attributes}

  defp stringify_keys(attrs) do
    for {k, v} <- attrs, into: %{}, do: {to_string(k), v}
  end
end
