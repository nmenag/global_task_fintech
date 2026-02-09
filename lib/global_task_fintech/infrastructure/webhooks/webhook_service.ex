defmodule GlobalTaskFintech.Infrastructure.Webhooks.WebhookService do
  @moduledoc """
  Service for delivering webhook notifications.
  """
  require Logger

  @doc """
  Delivers a status update webhook.
  """
  def notify_status_change(application) do
    url = get_webhook_url()

    payload = %{
      event: "application.status_updated",
      timestamp: DateTime.utc_now(),
      data: %{
        application_id: application.id,
        new_status: application.status,
        country: application.country,
        full_name: application.full_name
      }
    }

    Logger.info("[WEBHOOK] Sending status update for #{application.id} to #{url}")

    case Req.post(url, json: payload) do
      {:ok, %{status: status}} when status in 200..299 ->
        Logger.info("[WEBHOOK] Delivered successfully (HTTP #{status})")
        :ok

      {:ok, %{status: status}} ->
        Logger.error("[WEBHOOK] Delivery failed with HTTP #{status}")
        {:error, :delivery_failed}

      {:error, reason} ->
        Logger.error("[WEBHOOK] Delivery error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp get_webhook_url do
    Application.get_env(:global_task_fintech, :webhooks)[:status_update_url]
  end
end
