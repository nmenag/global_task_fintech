defmodule GlobalTaskFintech.Domain.Services.CreateCreditApplication do
  @moduledoc """
  Service for creating a new Credit Application.
  """
  alias GlobalTaskFintech.Applications

  def execute(attrs) do
    # Business logic could go here (e.g. checking blacklist, scoring, etc.)
    # Then we delegate to the context for persistence.

    attrs
    |> sanitize_attrs()
    |> Applications.save_credit_application()
  end

  defp sanitize_attrs(attrs) do
    # Ensure status is set if missing, or other domain-specific sanitization
    attrs
    |> Map.put_new("status", "pending")
  end
end
