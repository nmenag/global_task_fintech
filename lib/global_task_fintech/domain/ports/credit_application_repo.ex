defmodule GlobalTaskFintech.Domain.Ports.CreditApplicationRepo do
  @moduledoc """
  Port defining the repository operations for Credit Applications.
  """
  alias GlobalTaskFintech.Domain.Entities.CreditApplication

  @callback save(CreditApplication.t()) :: {:ok, CreditApplication.t()} | {:error, any()}
  @callback get(any()) :: {:ok, CreditApplication.t()} | {:error, :not_found}
  @callback list() :: [CreditApplication.t()]
end
