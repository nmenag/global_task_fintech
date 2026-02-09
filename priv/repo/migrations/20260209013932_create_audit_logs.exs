defmodule GlobalTaskFintech.Repo.Migrations.CreateAuditLogs do
  use Ecto.Migration

  def change do
    create table(:audit_logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :entity_type, :string, null: false
      add :entity_id, :binary_id, null: false
      add :action, :string, null: false
      add :previous_state, :map
      add :new_state, :map
      add :country, :string
      add :metadata, :map, default: "{}"

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:audit_logs, [:entity_id])
    create index(:audit_logs, [:entity_type, :action])
  end
end
