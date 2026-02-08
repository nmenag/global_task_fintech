defmodule GlobalTaskFintech.Infrastructure.Banks.MxBankProvider do
  @moduledoc """
  Fake bank provider for Mexico (BBVA style).
  """
  @behaviour GlobalTaskFintech.Domain.Ports.BankProvider

  @impl true
  def fetch_data(_type, _value) do
    raw = %{
      "folio" => "MX-#{:rand.uniform(999_999)}",
      "score_buro" => 650 + :rand.uniform(150),
      "status_pago" => "al_corriente",
      "banco" => "BBVA México"
    }

    {:ok, normalize(raw)}
  end

  defp normalize(raw) do
    %{
      "bank_name" => raw["banco"],
      "account_status" => String.downcase(raw["status_pago"]),
      "credit_score" => raw["score_buro"],
      "total_debt" => 0,
      "verified" => raw["status_pago"] == "al_corriente",
      "raw_response" => raw
    }
  end
end
