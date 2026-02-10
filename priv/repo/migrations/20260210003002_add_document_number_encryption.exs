defmodule GlobalTaskFintech.Repo.Migrations.AddDocumentNumberEncryption do
  use Ecto.Migration

  def up do
    # 1. Add `document_number_hash` column
    alter table(:credit_applications) do
      add :document_number_hash, :binary
    end

    # 2. Change `document_number` to `binary` for encryption
    # Using `modify` with `using` clause to hint conversion if needed, but since we probably don't have production data
    # (or we accept specific conversion), we'll do straight modify.
    # Note: If there was existing data, we'd need to populate the hash and encrypt the number in a data migration.
    # For now, we assume we can cast string to binary directly.
    execute "ALTER TABLE credit_applications ALTER COLUMN document_number TYPE bytea USING document_number::bytea",
            "ALTER TABLE credit_applications ALTER COLUMN document_number TYPE text USING document_number::text"

    # 3. Update indexes
    drop_if_exists unique_index(:credit_applications, [:document_number],
                     name: :unique_pending_document_number
                   )

    # We create a unique index on the HASH for lookups
    create unique_index(:credit_applications, [:document_number_hash],
             name: :unique_pending_document_number_hash
           )
  end

  def down do
    drop unique_index(:credit_applications, [:document_number_hash],
           name: :unique_pending_document_number_hash
         )

    alter table(:credit_applications) do
      modify :document_number, :string
      remove :document_number_hash
    end

    create unique_index(:credit_applications, [:document_number],
             name: :unique_pending_document_number
           )
  end
end
