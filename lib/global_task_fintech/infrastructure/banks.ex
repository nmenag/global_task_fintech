defmodule GlobalTaskFintech.Infrastructure.Banks do
  @moduledoc """
  Dispatcher for bank providers based on country.
  """
  alias GlobalTaskFintech.Infrastructure.Banks.MxBankProvider
  alias GlobalTaskFintech.Infrastructure.Banks.CoBankProvider

  def fetch_data(country, doc_type, doc_value) do
    provider = get_provider(country)
    provider.fetch_data(doc_type, doc_value)
  end

  defp get_provider("MX"), do: MxBankProvider
  defp get_provider("CO"), do: CoBankProvider
  defp get_provider(_), do: MxBankProvider
end
