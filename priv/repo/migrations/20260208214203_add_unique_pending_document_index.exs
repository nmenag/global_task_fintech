defmodule GlobalTaskFintech.Repo.Migrations.AddUniquePendingDocumentIndex do
  use Ecto.Migration

  def change do
    create unique_index(:credit_applications, [:document_number],
             where: "status = 'pending'",
             name: :unique_pending_document_number
           )
  end
end
