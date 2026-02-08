defmodule GlobalTaskFintech.Infrastructure.Rules.BusinessRulesClient do
  @moduledoc """
  HTTP client for BusinessRules Agent.
  """
  @behaviour GlobalTaskFintech.Domain.Ports.RulesEngine

  @doc """
  Evaluates a set of facts against a specific rule using BusinessRules Agent.
  """
  @impl true
  def evaluate(request_payload, rule_name) do
    base_url = get_config(:base_url)
    api_key = get_config(:api_key)

    url = "#{base_url}/evaluate/#{rule_name}"

    Req.post(url,
      json: request_payload,
      headers: [
        {"x-api-key", api_key},
        {"content-type", "application/json"}
      ],
      receive_timeout: 5000
    )
    |> handle_response()
  end

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
    # BusinessRules usually returns an object with 'result' field
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
