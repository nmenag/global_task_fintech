defmodule GlobalTaskFintech.EncryptionTest do
  use GlobalTaskFintech.DataCase
  alias GlobalTaskFintech.Applications
  alias GlobalTaskFintech.Repo

  test "document_number is encrypted in the database" do
    attrs = %{
      country: "MX",
      full_name: "John Doe",
      document_type: "curp",
      document_number: "ABCD123456EFGHIJ12",
      monthly_income: Decimal.new("10000"),
      amount_requested: Decimal.new("50000")
    }

    {:ok, app} = Applications.create_credit_application(attrs)

    # Verify struct has plaintext
    assert app.document_number == "ABCD123456EFGHIJ12"

    {:ok, app_id_bin} = Ecto.UUID.dump(app.id)

    # Verify database has ciphertext
    result =
      Ecto.Adapters.SQL.query!(
        Repo,
        "SELECT document_number FROM credit_applications WHERE id = $1",
        [
          app_id_bin
        ]
      )

    [[ciphertext]] = result.rows

    # Ciphertext should be binary and different from plaintext (and not just same string as binary)
    assert is_binary(ciphertext)
    assert ciphertext != "ABCD123456EFGHIJ12"
    # Basic check for Cloak header usually
    assert byte_size(ciphertext) > byte_size("ABCD123456EFGHIJ12")
  end

  test "document_number_hash is populated" do
    attrs = %{
      country: "MX",
      full_name: "Jane Doe",
      document_type: "curp",
      document_number: "XYZ123456EFGHIJ12A",
      monthly_income: Decimal.new("20000"),
      amount_requested: Decimal.new("1000")
    }

    {:ok, app} = Applications.create_credit_application(attrs)

    assert app.document_number_hash != nil
    assert app.document_number_hash == :crypto.hash(:sha256, "XYZ123456EFGHIJ12A")
  end
end
