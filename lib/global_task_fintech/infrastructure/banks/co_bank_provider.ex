defmodule GlobalTaskFintech.Infrastructure.Banks.CoBankProvider do
  @moduledoc """
  Fake bank provider for Colombia (Bancolombia).
  """
  @behaviour GlobalTaskFintech.Domain.Ports.BankProvider

  @impl true
  def fetch_data(_type, _value) do
    raw = %{
      "referencia_interna" => "CO-#{:rand.uniform(999_999)}",
      "puntaje_datacredito" => 700 + :rand.uniform(200),
      "entidad" => "Bancolombia",
      "deuda_total" => 500_000 + :rand.uniform(5_000_000)
    }

    {:ok, normalize(raw)}
  end

  defp normalize(raw) do
    %{
      "bank_name" => raw["entidad"],
      "account_status" => String.downcase(raw["estado_cuenta"]),
      "credit_score" => raw["puntaje_datacredito"],
      "total_debt" => raw["deuda_total"],
      "verified" => raw["estado_cuenta"] == "ACTIVA",
      "raw_response" => raw
    }
  end
end
