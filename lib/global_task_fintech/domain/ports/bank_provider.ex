defmodule GlobalTaskFintech.Domain.Ports.BankProvider do
  @moduledoc """
  Port for banking integrations.
  """

  @type bank_data :: %{
          String.t() => any()
        }

  @callback fetch_data(document_type :: String.t(), document_number :: String.t()) ::
              {:ok, bank_data()} | {:error, any()}
end
