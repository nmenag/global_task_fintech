defmodule GlobalTaskFintech.Infrastructure.Rules.BusinessRulesClient do
  @moduledoc """
  HTTP client for BusinessRules Agent.
  """
  @behaviour GlobalTaskFintech.Domain.Ports.RulesEngine

  @cache_adapter Application.compile_env(
                   :global_task_fintech,
                   :cache_adapter,
                   GlobalTaskFintech.Infrastructure.Cache.EtsAdapter
                 )

  @doc """
  Evaluates a set of facts against a specific rule using BusinessRules Agent.
  """
  @impl true

  def evaluate(request_payload, rule_name) do
    payload = sanitize_payload(request_payload)
    key = {rule_name, payload}

    case @cache_adapter.get(key) do
      {:ok, result} ->
        {:ok, result}

      :miss ->
        perform_evaluation(payload, rule_name)
        |> tap(fn
          {:ok, result} -> @cache_adapter.put(key, result)
          _ -> :ok
        end)
    end
  end

  defp perform_evaluation(payload, rule_name) do
    base_url = get_config(:base_url)
    api_key = get_config(:api_key)

    url = "#{base_url}/evaluate/#{rule_name}"

    Req.post(url,
      json: payload,
      headers: [
        {"x-api-key", api_key},
        {"content-type", "application/json"}
      ],
      receive_timeout: 5000
    )
    |> handle_response()
  end

  defp sanitize_payload(%Decimal{} = d), do: Decimal.to_float(d)

  defp sanitize_payload(payload) when is_map(payload) do
    Map.new(payload, fn {k, v} -> {k, sanitize_payload(v)} end)
  end

  defp sanitize_payload(payload) when is_list(payload) do
    Enum.map(payload, &sanitize_payload/1)
  end

  defp sanitize_payload(payload), do: payload

  defp handle_response({:ok, %Req.Response{status: 200, body: body}}) do
    {:ok, normalize_result(body)}
  end

  defp handle_response({:ok, %Req.Response{status: status, body: body}}) do
    {:error, {:http_error, status, body}}
  end

  defp handle_response({:error, exception}) do
    {:error, {:network_error, exception}}
  end

  defp normalize_result(body) do
    case body do
      %{"result" => result} -> result
      _ -> body
    end
  end

  defp get_config(key) do
    Application.get_env(:global_task_fintech, __MODULE__)
    |> Keyword.get(key)
  end
end
