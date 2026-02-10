defmodule GlobalTaskFintech.Infrastructure.Cache.EtsAdapter do
  @moduledoc """
  In-memory cache adapter using ETS.
  """
  use GenServer

  @behaviour GlobalTaskFintech.Domain.Ports.Cache

  @name __MODULE__
  @table :business_cache_store

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  @impl true
  def get(key) do
    case :ets.lookup(@table, key) do
      [{^key, value}] -> {:ok, value}
      [] -> :miss
    end
  end

  @impl true
  def put(key, value) do
    :ets.insert(@table, {key, value})
    :ok
  end

  @impl true
  def clear do
    :ets.delete_all_objects(@table)
    :ok
  end

  @impl true
  def init(state) do
    :ets.new(@table, [:named_table, :set, :public, read_concurrency: true])
    {:ok, state}
  end
end
