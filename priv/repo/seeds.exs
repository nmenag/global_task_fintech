alias GlobalTaskFintech.Infrastructure.Repositories.UserRepository

unless UserRepository.get_by_email("admin@fintech.com") do
  UserRepository.create(%{
    email: "admin@fintech.com",
    password: "password123",
    full_name: "System Admin",
    role: "admin"
  })
end

unless UserRepository.get_by_email("viewer@fintech.com") do
  UserRepository.create(%{
    email: "viewer@fintech.com",
    password: "password123",
    full_name: "View Only User",
    role: "user"
  })
end
