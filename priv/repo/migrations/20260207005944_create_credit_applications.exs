defmodule GlobalTaskFintech.Repo.Migrations.CreateCreditApplications do
  use Ecto.Migration

  def change do
    create table(:credit_applications) do
      add :country, :string
      add :full_name, :string
      add :document_type, :string
      add :document_value, :string
      add :monthly_income, :decimal
      add :amount_requested, :decimal

      timestamps(type: :utc_datetime)
    end
  end
end
