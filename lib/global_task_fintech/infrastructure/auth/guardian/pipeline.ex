defmodule GlobalTaskFintech.Infrastructure.Auth.Guardian.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :global_task_fintech,
    error_handler: GlobalTaskFintech.Infrastructure.Auth.Guardian.ErrorHandler,
    module: GlobalTaskFintech.Infrastructure.Auth.Guardian

  # If there is a session token, restrict it to an access token and validate it
  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
  # If there is an authorization header, restrict it to an access token and validate it
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}
  # Load the user if either of the verifications worked
  plug Guardian.Plug.LoadResource, allow_blank: true
  plug GlobalTaskFintechWeb.Plugs.AssignUser
end
