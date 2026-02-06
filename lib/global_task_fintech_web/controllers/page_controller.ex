defmodule GlobalTaskFintechWeb.PageController do
  use GlobalTaskFintechWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
