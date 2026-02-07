defmodule GlobalTaskFintech.Domain.UseCases.CreateCreditApplication do
  @moduledoc """
  Use case for creating a new Credit Application.
  """
  alias GlobalTaskFintech.Domain.Entities.CreditApplication
  alias GlobalTaskFintech.Infrastructure.Database.Adapters.EctoCreditApplicationRepo

  # In a strict hexagonal setup, we might inject this or use a config
  @repo EctoCreditApplicationRepo

  def execute(attrs) do
    # Business logic could go here (e.g. checking blacklist, scoring, etc.)
    # For now, we just convert attrs to entity and save.
    # Note: Ecto changesets are usually infrastructure-specific, but often used in Elixir apps.
    # To keep it "pure hexagonal", we'd validate in the domain entity or a separate validator.
    # However, to maintain functionality with the LiveView and Ecto, we'll use the schema's changeset
    # but wrap it in the repo adapter which handles the mapping.

    # If we want the LiveView to keep working with changesets, we might still return them.
    # But usually, Use Cases return domain results.

    %CreditApplication{}
    |> Map.merge(cast_attrs(attrs))
    |> @repo.save()
  end

  defp cast_attrs(attrs) do
    # Simple casting for now. In a real app, this might be more robust.
    %{
      country: attrs["country"],
      full_name: attrs["full_name"],
      document_type: attrs["document_type"],
      document_value: attrs["document_value"],
      monthly_income: to_decimal(attrs["monthly_income"]),
      amount_requested: to_decimal(attrs["amount_requested"]),
      status: String.to_existing_atom(attrs["status"] || "pending"),
      bank_data: attrs["bank_data"]
    }
  end

  defp to_decimal(nil), do: nil
  defp to_decimal(val) when is_binary(val), do: Decimal.new(val)
  defp to_decimal(val), do: val
end
