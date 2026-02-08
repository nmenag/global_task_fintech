defmodule GlobalTaskFintech.Domain.Services.CreateCreditApplication do
  @moduledoc """
  Service for creating a new Credit Application.
  """
  alias GlobalTaskFintech.Applications
  alias GlobalTaskFintech.Infrastructure.Banks

  def execute(attrs) do
    # Fetch bank data based on country and document
    bank_info = fetch_bank_data(attrs)

    attrs
    |> sanitize_attrs()
    |> Map.put("bank_data", bank_info)
    |> Applications.save_credit_application()
  end

  defp fetch_bank_data(%{"country" => country, "document_type" => type, "document_value" => val}) do
    case Banks.fetch_data(country, type, val) do
      {:ok, data} -> data
      _ -> nil
    end
  end

  defp fetch_bank_data(_), do: nil

  defp sanitize_attrs(attrs) do
    # Ensure status is set if missing, or other domain-specific sanitization
    attrs
    |> Map.put_new("status", "pending")
  end
end
