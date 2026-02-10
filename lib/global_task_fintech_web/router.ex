defmodule GlobalTaskFintechWeb.Router do
  use GlobalTaskFintechWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {GlobalTaskFintechWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_layout, html: {GlobalTaskFintechWeb.Layouts, :app}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug GlobalTaskFintech.Infrastructure.Auth.Guardian.Pipeline
  end

  pipeline :require_auth do
    plug Guardian.Plug.EnsureAuthenticated,
      handler: GlobalTaskFintech.Infrastructure.Auth.Guardian.ErrorHandler
  end

  scope "/", GlobalTaskFintechWeb do
    pipe_through [:browser, :auth]

    get "/login", SessionController, :new
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete

    scope "/" do
      pipe_through :require_auth

      live_session :authenticated,
        on_mount: [{GlobalTaskFintechWeb.Live.AuthHook, :default}],
        layout: {GlobalTaskFintechWeb.Layouts, :app} do
        # Only allow authenticated users to see these
        live "/", CreditApplicationLive.Index
        live "/credit-applications", CreditApplicationLive.Index
        live "/credit-applications/:id", CreditApplicationLive.Show, :show
        live "/credit-applications/:country/new", CreditApplicationLive.New
      end
    end
  end

  scope "/api/v1", GlobalTaskFintechWeb.Api.V1 do
    pipe_through :api

    post "/login", AuthController, :login

    scope "/" do
      pipe_through [:auth, :require_auth]
      resources "/credit-applications", CreditApplicationController, except: [:new, :edit]
    end
  end

  scope "/api/webhooks", GlobalTaskFintechWeb.Api do
    pipe_through :api
    post "/receive", WebhookController, :receive
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:global_task_fintech, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: GlobalTaskFintechWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
