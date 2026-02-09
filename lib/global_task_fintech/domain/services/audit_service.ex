defmodule GlobalTaskFintech.Domain.Services.AuditService do
  @moduledoc """
  Service for recording audit logs asynchronously.
  """
  require Logger

  @doc """
  Logs an action asynchronously.
  """
  def log_async(entity_type, entity_id, action, opts \\ []) do
    attrs = %{
      entity_type: to_string(entity_type),
      entity_id: entity_id,
      action: to_string(action),
      previous_state: sanitize_state(opts[:previous_state]),
      new_state: sanitize_state(opts[:new_state]),
      country: opts[:country],
      metadata: opts[:metadata] || %{}
    }

    oban_opts = if opts[:repo], do: [repo: opts[:repo]], else: []

    %{"attrs" => attrs}
    |> GlobalTaskFintech.Workers.AuditWorker.new()
    |> Oban.insert(oban_opts)
  end

  defp sanitize_state(nil), do: nil

  defp sanitize_state(%_{} = struct) do
    struct
    |> Map.from_struct()
    |> Map.drop([:__meta__, :__struct__])
    |> Enum.into(%{}, fn {k, v} -> {k, sanitize_value(v)} end)
  end

  defp sanitize_state(map) when is_map(map), do: map
  defp sanitize_state(val), do: val

  defp sanitize_value(%Decimal{} = d), do: Decimal.to_float(d)
  defp sanitize_value(%_{} = struct), do: sanitize_state(struct)
  defp sanitize_value(list) when is_list(list), do: Enum.map(list, &sanitize_value/1)

  defp sanitize_value(tuple) when is_tuple(tuple),
    do: tuple |> Tuple.to_list() |> Enum.map(&sanitize_value/1)

  defp sanitize_value(val), do: val
end
