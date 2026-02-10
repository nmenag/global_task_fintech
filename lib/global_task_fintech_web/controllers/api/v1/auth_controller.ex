defmodule GlobalTaskFintechWeb.Api.V1.AuthController do
  use GlobalTaskFintechWeb, :controller

  alias GlobalTaskFintech.Domain.Services.AuthService

  @doc """
  Authenticates a user and returns a JWT token.
  Expects: %{"email" => email, "password" => password}
  """
  def login(conn, %{"email" => email, "password" => password}) do
    case AuthService.authenticate_user(email, password) do
      {:ok, user} ->
        {:ok, token} = AuthService.generate_token(user)

        json(conn, %{
          status: "success",
          token: token,
          user: %{email: user.email, full_name: user.full_name, role: user.role}
        })

      {:error, :unauthorized} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{status: "error", message: "Invalid credentials"})
    end
  end
end
