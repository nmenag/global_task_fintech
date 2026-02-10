defmodule GlobalTaskFintech.Repo.Migrations.FixUniqueDocumentIndexLogic do
  use Ecto.Migration

  def up do
    drop unique_index(:credit_applications, [:document_number_hash],
           name: :unique_pending_document_number_hash
         )

    create unique_index(:credit_applications, [:document_number_hash],
             name: :unique_pending_document_number_hash,
             where: "status NOT IN ('approved', 'rejected')"
           )
  end

  def down do
    drop unique_index(:credit_applications, [:document_number_hash],
           name: :unique_pending_document_number_hash
         )

    create unique_index(:credit_applications, [:document_number_hash],
             name: :unique_pending_document_number_hash
           )
  end
end
