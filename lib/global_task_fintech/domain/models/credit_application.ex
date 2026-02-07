defmodule GlobalTaskFintech.Domain.Models.CreditApplication do
  @moduledoc """
  Domain model representing a Credit Application.
  Now combines business structure with persistence schema.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "credit_applications" do
    field :country, :string
    field :full_name, :string
    field :document_type, :string
    field :document_value, :string
    field :monthly_income, :decimal
    field :amount_requested, :decimal
    field :status, Ecto.Enum, values: [:pending, :approved, :rejected], default: :pending
    field :bank_data, :map

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{
          id: binary() | nil,
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

  @doc false
  def changeset(credit_application, attrs) do
    credit_application
    |> cast(attrs, [
      :country,
      :full_name,
      :document_type,
      :document_value,
      :monthly_income,
      :amount_requested,
      :status,
      :bank_data
    ])
    |> validate_required([
      :country,
      :full_name,
      :document_type,
      :document_value,
      :monthly_income,
      :amount_requested,
      :status
    ])
    |> validate_inclusion(:country, ["MX", "CO"])
    |> validate_number(:monthly_income, greater_than: 0)
    |> validate_number(:amount_requested, greater_than: 0)
  end
end
