defmodule GlobalTaskFintech.Encrypted.Binary do
  @moduledoc false
  use Cloak.Ecto.Binary, vault: GlobalTaskFintech.Vault
end
