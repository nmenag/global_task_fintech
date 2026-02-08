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
      "estado_cuenta" => "ACTIVA",
      "entidad" => "Bancolombia"
    }

    {:ok, normalize(raw)}
  end

  defp normalize(raw) do
    %{
      "bank_name" => raw["entidad"],
      "account_status" => String.downcase(raw["estado_cuenta"]),
      "credit_score" => raw["puntaje_datacredito"],
      "verified" => raw["estado_cuenta"] == "ACTIVA",
      "raw_response" => raw
    }
  end
end
