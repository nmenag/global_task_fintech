defmodule GlobalTaskFintech.ApplicationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GlobalTaskFintech.Applications` context.
  """

  @doc """
  Generate a credit_application.
  """
  def credit_application_fixture(attrs \\ %{}) do
    {:ok, credit_application} =
      attrs
      |> Enum.into(%{
        amount_requested: "120.5",
        country: "MX",
        document_type: "id_card",
        document_value: "some document_value",
        full_name: "some full_name",
        monthly_income: "120.5"
      })
      |> GlobalTaskFintech.Applications.create_credit_application()

    credit_application
  end
end
