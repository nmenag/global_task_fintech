defmodule GlobalTaskFintech.Domain.Ports.RulesEngine do
  @moduledoc """
  Port for business rules engine integrations.
  """

  @callback evaluate(request_payload :: map(), rule_name :: String.t()) ::
              {:ok, result :: map()} | {:error, any()}
end
