// Input variables for vIDM to perform sync operation
variable "idm_hostname" {
  type        = string
  description = "Identity Manager FQDN. Ensure that the tenant is part of the URL if the environment is multi-tenant."
}

variable "idm_user" {
  type        = string
  description = "Identity Manager OAUTH2 Client Name for API calls"
}

variable "idm_password" {
  type        = string
  description = "Identity Manager OAUTH2 Client Secret for API calls"
  sensitive   = true
}

variable "idm_directory_type" {
  description = "Active Directory type: [LDAP, IWA] - default is IWA"
  type        = string
  default     = "IWA"

  validation {
    condition = can(regex("^IWA$|^LDAP$", var.idm_directory_type))
    error_message = "The directory type must be [LDAP] or [IWA]. Please try again with one of these choices."
  }
}

variable "idm_directory_name" {
  description = "Name of the Identity Manager directory to perform sync operations on"
  type        = string
}


// Outputs
output "idm_directory" {
  description = "The directory ID that was synchronized"
  value       = local.directoryId
}
