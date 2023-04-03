# VMware Identity Manager - Directory Sync Terraform Module
Fun exercise in using Terraform to execute VMware Identity Manager sync, to improve end to end provisioning with vRA provider and AD Groups.

## Usage
This module requires an OAUTH2 Client ID and Secret created with the admin scope to work.

Have your administrator go to the Admin Console, then Catalog->Settings->Remote App Access.

Click **Create Client** and specify the following values:

| Access Type | Client ID | Shared Secret | Token Time-To-Live  |
|---|---|---|---|
| Service Client Token | \<Your OAUTH2 Client Name>\  | Click **Generate Shared Secret**  | Whatever your admin wants, but low values are better. |

When this module runs, it will return the ID of the directory that a sync was submitted against for troubleshooting purposes.

**NOTE**: This module is tested against on-prem deployments, but theoretically should work for the SaaS Tenant as it is just a different URL.

If not, well, test it out and let me know how we can improve it!