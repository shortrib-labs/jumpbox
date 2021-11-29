output "password" {
  value     = random_pet.default_password.id
  sensitive = true
}
