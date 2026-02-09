defmodule GlobalTaskFintechWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use GlobalTaskFintechWeb, :controller

  # This clause handles errors returned by Ecto's transaction/with.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: GlobalTaskFintechWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  # This clause is an example of how you can customize error handling.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: GlobalTaskFintechWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, :invalid_transition}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{status: "error", message: "Invalid state transition"})
  end

  def call(conn, {:error, :bad_request}) do
    conn
    |> put_status(:bad_request)
    |> json(%{status: "error", message: "Bad request"})
  end

  def call(conn, {:error, reason}) when is_binary(reason) do
    conn
    |> put_status(:bad_request)
    |> json(%{status: "error", message: reason})
  end
end
