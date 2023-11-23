# AzureAD-Sign-In-Log-MSSQL-Exporter

**Description:** A PowerShell script (or container) to automatically pull Azure AD Sign-In Logs from the Graph API and write to an MS SQL Server continuously e.g. every 5 minutes. I use this for a sign-in map that shows worldwide tenancy sign-ins.

**Based off:**
https://github.com/NickJongens/PSDocker

# Build Docker Image

To build the Docker image, use the following commands:

```bash
sudo docker build -t exportazureadlogstosqlserver .

sudo docker tag exportazureadlogstosqlserver:latest <dockerhubusername>/exportazureadlogstosqlserver:latest

sudo docker push <dockerhubusername>/exportazureadlogstosqlserver:latest
```

# Deploy Unattended Docker Container for Continuous Upload
Use the following docker run command to deploy an unattended Docker container for continuous upload:

```bash
docker run -d --name azuread-log-exporter \
  -e CLIENT_ID=<App ID/Client ID in App Registration> \
  -e CLIENT_SECRET=<Application Secret> \
  -e TENANT_ID=<Azure AD/Entra ID Tenant ID> \
  -e SERVER_NAME=<IP Address/Hostname OF SQL SERVER> \
  -e DATABASE_NAME=<Database Name> \
  -e DATABASE_TABLE=<Table Name e.g. SignInLogs> \
  -e USERNAME=<DB Username> \
  -e PASSWORD=<DB Password> \
  exportazureadlogstosqlserver

```

