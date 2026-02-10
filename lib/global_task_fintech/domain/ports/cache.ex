defmodule GlobalTaskFintech.Domain.Ports.Cache do
  @moduledoc """
  This module defines the behaviour for operations that can be performed on a key-value store.
  """

  @callback get(key :: any()) :: {:ok, value :: any()} | :miss
  @callback put(key :: any(), value :: any()) :: :ok
  @callback clear() :: :ok
end
