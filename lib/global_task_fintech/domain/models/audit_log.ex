defmodule GlobalTaskFintech.Domain.Models.AuditLog do
  @moduledoc """
  Schema for persisting audit logs.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "audit_logs" do
    field :entity_type, :string
    field :entity_id, :binary_id
    field :action, :string
    field :previous_state, :map
    field :new_state, :map
    field :country, :string
    field :metadata, :map, default: %{}

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(audit_log, attrs) do
    audit_log
    |> cast(attrs, [
      :entity_type,
      :entity_id,
      :action,
      :previous_state,
      :new_state,
      :country,
      :metadata
    ])
    |> validate_required([:entity_type, :entity_id, :action])
  end
end
