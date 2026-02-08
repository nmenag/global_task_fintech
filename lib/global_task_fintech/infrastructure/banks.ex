defmodule GlobalTaskFintech.Infrastructure.Banks do
  @moduledoc """
  Dispatcher for bank providers based on country.
  Resolves providers dynamically from configuration.
  If a country is not supported, it returns an error.
  """

  def fetch_data(country, doc_type, doc_value) do
    case get_provider(country) do
      {:ok, provider} ->
        provider.fetch_data(doc_type, doc_value)

      {:error, :unsupported_country} ->
        {:error, :unsupported_country}
    end
  end

  defp get_provider(country) do
    providers = Application.get_env(:global_task_fintech, :bank_providers, %{})

    case Map.get(providers, country) do
      nil -> {:error, :unsupported_country}
      provider -> {:ok, provider}
    end
  end
end
