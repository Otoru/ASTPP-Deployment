variable "database_password" {
  type = string
  description = "Password to be used by the user 'astpp' in the database."

  validation {
    condition = length(var.database_password) > 8 
    error_message = "The password must contain more than 8 characters."
  }
}