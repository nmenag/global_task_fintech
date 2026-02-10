defmodule GlobalTaskFintech.Infrastructure.Cache.EtsAdapterTest do
  use ExUnit.Case, async: true
  alias GlobalTaskFintech.Infrastructure.Cache.EtsAdapter

  # Cache is started as part of the application, but we can clear it before tests
  setup do
    EtsAdapter.clear()
    :ok
  end

  test "stores and retrieves values" do
    key = {:test_rule, %{"data" => 123}}
    value = %{"result" => "approved"}

    assert EtsAdapter.get(key) == :miss
    assert EtsAdapter.put(key, value) == :ok
    assert EtsAdapter.get(key) == {:ok, value}
  end

  test "handles complex keys correctly" do
    key = {:complex_rule, %{"a" => 1, "b" => [2, 3]}}
    value = %{"score" => 0.95}

    EtsAdapter.put(key, value)
    assert EtsAdapter.get(key) == {:ok, value}
  end

  test "clears cache" do
    EtsAdapter.put(:key1, :val1)
    assert EtsAdapter.get(:key1) == {:ok, :val1}

    EtsAdapter.clear()
    assert EtsAdapter.get(:key1) == :miss
  end
end
