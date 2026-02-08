defmodule GlobalTaskFintech.Domain.Ports.RulesEngine do
  @moduledoc """
  Port for business rules engine integrations.
  """

  @callback evaluate(request_payload :: map()) ::
              {:ok, result :: map()} | {:error, any()}
end
