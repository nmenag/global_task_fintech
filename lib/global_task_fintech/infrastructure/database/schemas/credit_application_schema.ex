defmodule GlobalTaskFintech.Infrastructure.Database.Schemas.CreditApplicationSchema do
  @moduledoc """
  Ecto schema for persisting Credit Applications to the database.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias GlobalTaskFintech.Domain.Models.CreditApplication

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
    |> validate_inclusion(:document_type, ["id_card", "passport", "license"])
    |> validate_number(:monthly_income, greater_than: 0)
    |> validate_number(:amount_requested, greater_than: 0)
  end

  def to_entity(%__MODULE__{} = schema) do
    %CreditApplication{
      id: schema.id,
      country: schema.country,
      full_name: schema.full_name,
      document_type: schema.document_type,
      document_value: schema.document_value,
      monthly_income: schema.monthly_income,
      amount_requested: schema.amount_requested,
      status: schema.status,
      bank_data: schema.bank_data,
      inserted_at: schema.inserted_at
    }
  end

  def from_entity(%CreditApplication{} = entity) do
    %__MODULE__{
      id: entity.id,
      country: entity.country,
      full_name: entity.full_name,
      document_type: entity.document_type,
      document_value: entity.document_value,
      monthly_income: entity.monthly_income,
      amount_requested: entity.amount_requested,
      status: entity.status,
      bank_data: entity.bank_data,
      inserted_at: entity.inserted_at
    }
  end
end
