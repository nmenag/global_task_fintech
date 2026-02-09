defmodule GlobalTaskFintechWeb.Api.V1.CreditApplicationJSON do
  alias GlobalTaskFintech.Domain.Models.CreditApplication

  @doc """
  Renders a list of credit applications.
  """
  def index(%{credit_applications: credit_applications}) do
    %{data: for(application <- credit_applications, do: data(application))}
  end

  @doc """
  Renders a single credit application.
  """
  def show(%{credit_application: credit_application}) do
    %{data: data(credit_application)}
  end

  defp data(%CreditApplication{} = application) do
    %{
      id: application.id,
      country: application.country,
      full_name: application.full_name,
      document_type: application.document_type,
      document_number: application.document_number,
      monthly_income: application.monthly_income,
      amount_requested: application.amount_requested,
      status: application.status,
      bank_data: application.bank_data,
      risk_reason: application.risk_reason,
      inserted_at: application.inserted_at,
      updated_at: application.updated_at
    }
    |> GlobalTaskFintech.Utils.PIIMasker.mask()
  end
end
