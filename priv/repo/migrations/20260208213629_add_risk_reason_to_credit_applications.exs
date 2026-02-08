defmodule GlobalTaskFintech.Repo.Migrations.AddRiskReasonToCreditApplications do
  use Ecto.Migration

  def change do
    alter table(:credit_applications) do
      add :risk_reason, :text
    end
  end
end
