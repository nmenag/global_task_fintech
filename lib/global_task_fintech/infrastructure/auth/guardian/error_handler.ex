defmodule GlobalTaskFintech.Infrastructure.Auth.Guardian.ErrorHandler do
  @moduledoc """
  Handles authentication errors from Guardian.
  """
  import Plug.Conn
  import Phoenix.Controller

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    # Check if it's an API request or browser request
    if conn.path_info |> List.first() == "api" do
      conn
      |> put_status(:unauthorized)
      |> json(%{error: to_string(type)})
    else
      conn
      |> put_flash(:error, "You must be logged in to access this page.")
      |> redirect(to: "/login")
    end
  end
end
