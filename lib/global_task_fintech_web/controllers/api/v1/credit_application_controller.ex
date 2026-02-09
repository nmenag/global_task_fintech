defmodule GlobalTaskFintechWeb.Api.V1.CreditApplicationController do
  use GlobalTaskFintechWeb, :controller

  alias GlobalTaskFintech.Applications
  alias GlobalTaskFintech.Domain.Models.CreditApplication

  action_fallback GlobalTaskFintechWeb.FallbackController

  def index(conn, params) do
    credit_applications = Applications.list_credit_applications(params)
    render(conn, :index, credit_applications: credit_applications)
  end

  def create(conn, %{"credit_application" => application_params}) do
    with {:ok, %CreditApplication{} = application} <-
           Applications.create_credit_application(application_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/v1/credit-applications/#{application}")
      |> render(:show, credit_application: application)
    end
  end

  def show(conn, %{"id" => id}) do
    application = Applications.get_credit_application!(id)
    render(conn, :show, credit_application: application)
  end

  def update(conn, %{"id" => id, "credit_application" => application_params}) do
    application = Applications.get_credit_application!(id)

    with {:ok, %CreditApplication{} = application} <-
           Applications.update_credit_application(application, application_params) do
      render(conn, :show, credit_application: application)
    end
  end

  def delete(conn, %{"id" => id}) do
    application = Applications.get_credit_application!(id)

    with {:ok, %CreditApplication{}} <- Applications.delete_credit_application(application) do
      send_resp(conn, :no_content, "")
    end
  end
end
