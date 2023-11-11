# Resource block for generating a random string
resource "random_string" "random" {
  length  = 16   # Specifies the length of the string. Here, it is set to 16 characters.
  special = true # When set to true, the string will include special characters.
  # If false, it will be alphanumeric only.
}

# Output block to output the generated random string
# This needs to be in the VAULT
output "password" {
  value = random_string.random.result # Outputs the result of the random string generation.
}
