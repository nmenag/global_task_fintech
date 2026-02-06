defmodule GlobalTaskFintech.Repo do
  use Ecto.Repo,
    otp_app: :global_task_fintech,
    adapter: Ecto.Adapters.Postgres
end
