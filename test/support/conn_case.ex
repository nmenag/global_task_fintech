defmodule GlobalTaskFintechWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use GlobalTaskFintechWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint GlobalTaskFintechWeb.Endpoint

      use GlobalTaskFintechWeb, :verified_routes
      alias GlobalTaskFintech.Infrastructure.Auth.Guardian

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import GlobalTaskFintechWeb.ConnCase
      import GlobalTaskFintech.UserFixtures
    end
  end

  @doc """
  Logs the given `user` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_user(conn, user) do
    {:ok, token, _claims} = GlobalTaskFintech.Infrastructure.Auth.Guardian.encode_and_sign(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:guardian_default_token, token)
    |> Plug.Conn.assign(:current_user, user)
  end

  setup tags do
    GlobalTaskFintech.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
