defmodule GlobalTaskFintech.ApplicationsTest do
  use GlobalTaskFintech.DataCase

  alias GlobalTaskFintech.Applications

  describe "credit_applications" do
    alias GlobalTaskFintech.Domain.Entities.CreditApplication

    import GlobalTaskFintech.ApplicationsFixtures

    @invalid_attrs %{
      country: nil,
      full_name: nil,
      document_type: nil,
      document_value: nil,
      monthly_income: nil,
      amount_requested: nil
    }

    test "list_credit_applications/0 returns all credit_applications" do
      credit_application = credit_application_fixture()
      assert Applications.list_credit_applications() == [credit_application]
    end

    test "get_credit_application!/1 returns the credit_application with given id" do
      credit_application = credit_application_fixture()
      assert Applications.get_credit_application!(credit_application.id) == credit_application
    end

    test "create_credit_application/1 with valid data creates a credit_application" do
      valid_attrs = %{
        country: "MX",
        full_name: "some full_name",
        document_type: "id_card",
        document_value: "some document_value",
        monthly_income: "120.5",
        amount_requested: "120.5"
      }

      assert {:ok, %CreditApplication{} = credit_application} =
               Applications.create_credit_application(valid_attrs)

      assert credit_application.country == "MX"
      assert credit_application.full_name == "some full_name"
      assert credit_application.document_type == "id_card"
      assert credit_application.document_value == "some document_value"
      assert credit_application.monthly_income == Decimal.new("120.5")
      assert credit_application.amount_requested == Decimal.new("120.5")
    end

    test "create_credit_application/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Applications.create_credit_application(@invalid_attrs)
    end

    test "update_credit_application/2 with valid data updates the credit_application" do
      credit_application = credit_application_fixture()

      update_attrs = %{
        country: "CO",
        full_name: "some updated full_name",
        document_type: "passport",
        document_value: "some updated document_value",
        monthly_income: "456.7",
        amount_requested: "456.7"
      }

      assert {:ok, %CreditApplication{} = credit_application} =
               Applications.update_credit_application(credit_application, update_attrs)

      assert credit_application.country == "CO"
      assert credit_application.full_name == "some updated full_name"
      assert credit_application.document_type == "passport"
      assert credit_application.document_value == "some updated document_value"
      assert credit_application.monthly_income == Decimal.new("456.7")
      assert credit_application.amount_requested == Decimal.new("456.7")
    end

    test "update_credit_application/2 with invalid data returns error changeset" do
      credit_application = credit_application_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Applications.update_credit_application(credit_application, @invalid_attrs)

      assert credit_application == Applications.get_credit_application!(credit_application.id)
    end

    test "delete_credit_application/1 deletes the credit_application" do
      credit_application = credit_application_fixture()

      assert {:ok, %CreditApplication{}} =
               Applications.delete_credit_application(credit_application)

      assert_raise Ecto.NoResultsError, fn ->
        Applications.get_credit_application!(credit_application.id)
      end
    end

    test "change_credit_application/1 returns a credit_application changeset" do
      credit_application = credit_application_fixture()
      assert %Ecto.Changeset{} = Applications.change_credit_application(credit_application)
    end
  end
end
