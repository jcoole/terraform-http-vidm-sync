terraform {
  required_providers {
    http = {
      version = "3.2.1"
    }
  }
  required_version = "~> 1.3.7"
}

// Store a few local variables for the process.data 
locals {
  vidm_access_token = format("%s %s", jsondecode(data.http.idm_post_oauth_token.response_body).token_type, jsondecode(data.http.idm_post_oauth_token.response_body).access_token)
  directoryId = one([for i in toset(jsondecode(data.http.idm_get_directory_list.response_body).items) : i.directoryId if i.syncConfigurationEnabled == true && i.type == "ACTIVE_DIRECTORY_${var.idm_directory_type}" && i.name == "${var.idm_directory_name}"])
}

// Step 1 - Make a POST call to vIDM and return the result.
// If the status code isn't 200, throw an error.

data "http" "idm_post_oauth_token" {
  url    = "https://${var.idm_hostname}/SAAS/auth/oauthtoken?grant_type=client_credentials"
  method = "POST"
  request_headers = {
    Authorization = format("Basic %s", base64encode("${var.idm_user}:${var.idm_password}"))
    Content-Type  = "application/x-www-form-urlencoded"
  }
  lifecycle {
    postcondition {
      condition     = contains([200], self.status_code)
      error_message = "Identity Manager - Get Bearer Token :: Invalid Status Code [${self.status_code}]! The response says :: ${self.response_body}"
    }
  }
}

// Step 2 - List the available directories via the API and Bearer token.data 
// This data is filtered in the 'locals' block based on user inputs.
data "http" "idm_get_directory_list" {
  url    = "https://${var.idm_hostname}/SAAS/jersey/manager/api/connectormanagement/directoryconfigs"
  method = "GET"
  lifecycle {
    postcondition {
      condition     = contains([200], self.status_code)
      error_message = "Identity Manager - Get Directories :: Invalid Status Code [${self.status_code}]! The response body was :: ${self.response_body} to URL [${self.url}]"
    }
  }
  request_headers = {
    Authorization = local.vidm_access_token
    Accept        = "application/vnd.vmware.horizon.manager.connector.management.directory.list+json"
  }
}

// Step 3 - Perform directory sync on a specific ID, defined in the 'locals' block.
// This creates an async job and the response contains no link to the execution URL to verify it.
data "http" "idm_post_sync_directory" {
  url    = "https://${var.idm_hostname}/SAAS/jersey/manager/api/connectormanagement/directoryconfigs/${local.directoryId}/syncprofile/sync"
  method = "POST"

  request_headers = {
    Accept        = "application/vnd.vmware.horizon.v1.0+json"
    Content-Type  = "application/vnd.vmware.horizon.manager.connector.management.directory.sync.profile.sync+json"
    Authorization = local.vidm_access_token
  }

  request_body = jsonencode({
    ignoreSafeguards = false
  })

  lifecycle {
    postcondition {
      condition     = contains([200], self.status_code)
      error_message = "Identity Manager - Sync Directory :: HTTP Error [${self.status_code}] during sync request, the response was ::  ${self.response_body}"
    }
  }
}

