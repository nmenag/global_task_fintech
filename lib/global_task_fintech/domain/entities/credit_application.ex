defmodule GlobalTaskFintech.Domain.Entities.CreditApplication do
  @moduledoc """
  Domain entity representing a Credit Application.
  """
  defstruct [
    :id,
    :country,
    :full_name,
    :document_type,
    :document_value,
    :monthly_income,
    :amount_requested,
    :status,
    :bank_data,
    :inserted_at
  ]

  @type t :: %__MODULE__{
          id: binary() | integer() | nil,
          country: String.t(),
          full_name: String.t(),
          document_type: String.t(),
          document_value: String.t(),
          monthly_income: Decimal.t(),
          amount_requested: Decimal.t(),
          status: :pending | :approved | :rejected,
          bank_data: map() | nil,
          inserted_at: DateTime.t() | nil
        }
end
