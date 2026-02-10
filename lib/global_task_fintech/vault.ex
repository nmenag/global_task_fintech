defmodule GlobalTaskFintech.Vault do
  @moduledoc """
  Vault for handling encryption keys.
  """
  use Cloak.Vault, otp_app: :global_task_fintech
end
