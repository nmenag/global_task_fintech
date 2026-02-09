# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     GlobalTaskFintech.Repo.insert!(%GlobalTaskFintech.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias GlobalTaskFintech.Infrastructure.Repositories.UserRepository

unless UserRepository.get_by_email("admin@fintech.com") do
  UserRepository.create(%{
    email: "admin@fintech.com",
    password: "password123",
    full_name: "System Admin",
    role: "admin"
  })
end
