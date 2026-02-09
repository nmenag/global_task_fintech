defmodule GlobalTaskFintech.Infrastructure.Repositories.UserRepository do
  alias GlobalTaskFintech.Domain.Models.User
  alias GlobalTaskFintech.Repo

  def get(id), do: Repo.get(User, id)

  def get_by_email(email), do: Repo.get_by(User, email: email)

  def create(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
