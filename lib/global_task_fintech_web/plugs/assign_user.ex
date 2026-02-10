defmodule GlobalTaskFintechWeb.Plugs.AssignUser do
  @moduledoc """
  Plug to assign the current user resource to the connection.
  """
  import Plug.Conn
  alias GlobalTaskFintech.Infrastructure.Auth.Guardian

  def init(opts), do: opts

  def call(conn, _opts) do
    user = Guardian.Plug.current_resource(conn)
    assign(conn, :current_user, user)
  end
end
