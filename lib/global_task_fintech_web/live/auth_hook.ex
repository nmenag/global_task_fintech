defmodule GlobalTaskFintechWeb.Live.AuthHook do
  @moduledoc """
  on_mount hook to ensure LiveView sessions are authenticated.
  """
  import Phoenix.Component
  import Phoenix.LiveView

  alias GlobalTaskFintech.Infrastructure.Auth.Guardian

  def on_mount(:default, _params, session, socket) do
    case Guardian.resource_from_token(session["guardian_default_token"]) do
      {:ok, user, _claims} ->
        {:cont, assign(socket, :current_user, user)}

      _ ->
        {:halt, redirect(socket, to: "/login")}
    end
  end
end
