defmodule GlobalTaskFintech.Domain.Services.AuthService do
  alias GlobalTaskFintech.Infrastructure.Repositories.UserRepository
  alias GlobalTaskFintech.Infrastructure.Auth.Guardian

  def authenticate_user(email, password) do
    case UserRepository.get_by_email(email) do
      nil ->
        Argon2.no_user_verify()
        {:error, :unauthorized}

      user ->
        if Argon2.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :unauthorized}
        end
    end
  end

  def generate_token(user) do
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    {:ok, token}
  end
end
