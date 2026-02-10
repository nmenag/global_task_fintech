defmodule GlobalTaskFintech.UserFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GlobalTaskFintech.Infrastructure.Repositories.UserRepository` context.
  """

  alias GlobalTaskFintech.Infrastructure.Repositories.UserRepository

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      full_name: "Some User",
      role: "user"
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> UserRepository.create()

    user
  end
end
