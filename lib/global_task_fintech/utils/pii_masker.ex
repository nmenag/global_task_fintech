defmodule GlobalTaskFintech.Utils.PIIMasker do
  @moduledoc """
  Utility for masking sensitive PII data.
  """

  @sensitive_keys [
    :document_number,
    :phone
  ]

  def mask_value(nil), do: nil

  def mask_value(v) when is_binary(v) do
    len = String.length(v)

    if len <= 4 do
      "****"
    else
      String.slice(v, 0, 2) <> String.duplicate("*", len - 4) <> String.slice(v, -2, 2)
    end
  end

  def mask_value(_), do: "********"

  def mask(%{__struct__: _} = data) do
    data
    |> Map.from_struct()
    |> Map.drop([:__meta__])
    |> mask()
  end

  def mask(data) when is_map(data) do
    Enum.into(data, %{}, fn {k, v} ->
      if k in @sensitive_keys do
        {k, mask_value(v)}
      else
        {k, mask_nested(v)}
      end
    end)
  end

  def mask(data) when is_list(data) do
    Enum.map(data, &mask_nested/1)
  end

  def mask(data), do: data

  defp mask_nested(v) when is_map(v), do: mask(v)
  defp mask_nested(v) when is_list(v), do: Enum.map(v, &mask_nested/1)
  defp mask_nested(v) when is_tuple(v), do: v |> Tuple.to_list() |> Enum.map(&mask_nested/1)
  defp mask_nested(v), do: v
end
