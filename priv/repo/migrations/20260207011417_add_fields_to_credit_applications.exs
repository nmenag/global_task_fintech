defmodule GlobalTaskFintech.Repo.Migrations.AddFieldsToCreditApplications do
  use Ecto.Migration

  def change do
    alter table(:credit_applications) do
      add :status, :string, default: "pending"
      add :bank_data, :map
    end

    create index(:credit_applications, [:country])
    create index(:credit_applications, [:status])

    # inserted_at already indexed? No, timestamps usually only creates updated_at index by default in Phoenix if explicit? No, timestamps doesn't create indexes by default.
    create index(:credit_applications, [:inserted_at])
  end
end
