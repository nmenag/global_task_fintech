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
    field :document_number, GlobalTaskFintech.Encrypted.Binary
    field :document_number_hash, :binary
    field :monthly_income, :decimal
    field :amount_requested, :decimal

    field :status, Ecto.Enum,
      values: [:pending, :approved, :rejected, :manual_review, :risk_check],
      default: :pending

    field :bank_data, :map
    field :risk_reason, :string

    timestamps(type: :utc_datetime)
  end

  @type t :: %__MODULE__{
          id: binary() | nil,
          country: String.t(),
          full_name: String.t(),
          document_type: String.t(),
          document_number: String.t(),
          monthly_income: Decimal.t(),
          amount_requested: Decimal.t(),
          status: :pending | :approved | :rejected,
          bank_data: map() | nil,
          risk_reason: String.t() | nil,
          inserted_at: DateTime.t() | nil
        }

  @doc false
  def changeset(credit_application, attrs) do
    credit_application
    |> cast(attrs, [
      :country,
      :full_name,
      :document_type,
      :document_number,
      :monthly_income,
      :amount_requested,
      :status,
      :bank_data,
      :risk_reason
    ])
    |> validate_required([
      :country,
      :full_name,
      :document_type,
      :document_number,
      :monthly_income,
      :amount_requested,
      :status
    ])
    |> validate_inclusion(:country, ["MX", "CO"])
    |> validate_number(:monthly_income, greater_than: 0)
    |> validate_number(:amount_requested, greater_than: 0)
    |> validate_document_number_format()
    |> put_document_number_hash()
    |> unique_constraint(:document_number_hash,
      name: :unique_pending_document_number_hash,
      message: "already has a pending application"
    )
  end

  defp validate_document_number_format(changeset) do
    country = get_field(changeset, :country)
    doc_type = get_field(changeset, :document_type)

    case {country, doc_type} do
      {"MX", "curp"} ->
        validate_length(changeset, :document_number, is: 18)

      {"CO", "cc"} ->
        validate_length(changeset, :document_number, min: 6, max: 10)

      _ ->
        changeset
    end
  end

  defp put_document_number_hash(changeset) do
    case get_change(changeset, :document_number) do
      nil ->
        changeset

      document_number ->
        put_change(changeset, :document_number_hash, :crypto.hash(:sha256, document_number))
    end
  end
end
