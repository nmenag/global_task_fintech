defmodule GlobalTaskFintech.Infrastructure.Auth.Guardian do
  @moduledoc """
  Guardian module for JWT authentication.
  """
  use Guardian, otp_app: :global_task_fintech

  alias GlobalTaskFintech.Infrastructure.Repositories.UserRepository

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    user = UserRepository.get(id)
    {:ok, user}
  end

  def resource_from_claims(_claims) do
    {:error, :reason_for_error}
  end
end
