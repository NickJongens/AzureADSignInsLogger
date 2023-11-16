# Import SimplySQL module
Import-Module SimplySQL

$clientId = $env:CLIENT_ID
$clientSecret = $env:CLIENT_SECRET
$tenantId = $env:TENANT_ID

$serverName = $env:SERVER_NAME
$databaseName = $env:DATABASE_NAME
$databaseTable = $env:DATABASE_TABLE
$username = $env:USERNAME
$password = $env:PASSWORD
# Convert the password to a secure string
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($username, $securePassword)


try {
    # Obtain an access token for Microsoft Graph
    $tokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    $tokenParams = @{
        client_id     = $clientId
        scope         = "https://graph.microsoft.com/.default"
        client_secret = $clientSecret
        grant_type    = "client_credentials"
    }

    $tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Method Post -ContentType "application/x-www-form-urlencoded" -Body $tokenParams
    $accessToken = $tokenResponse.access_token
    # Use the access token to call Microsoft Graph and retrieve sign-in logs
    $graphApiUri = "https://graph.microsoft.com/v1.0/auditLogs/signIns"

    $signInLogs = Invoke-RestMethod -Uri $graphApiUri -Headers @{ "Authorization" = "Bearer $accessToken" }
    Write-Host $signInLogs
    # Write the retrieved data to SQL Server
    $connection = Open-MySQLConnection -Server $serverName -Port "3306" -Database $databaseName -Credential $credential
    $query = @"
    INSERT INTO $databaseTable (
        Id,
        CreatedDateTime,
        UserDisplayName,
        UserPrincipalName,
        UserId,
        AppId,
        AppDisplayName,
        IpAddress,
        ClientAppUsed,
        CorrelationId,
        ConditionalAccessStatus,
        IsInteractive,
        RiskDetail,
        RiskLevelAggregated,
        RiskLevelDuringSignIn,
        RiskState,
        RiskEventTypes,
        RiskEventTypes_v2,
        ResourceDisplayName,
        ResourceId,
        StatusCode,
        StatusFailureReason,
        StatusAdditionalDetails,
        DeviceId,
        DeviceDisplayName,
        DeviceOperatingSystem,
        DeviceBrowser,
        DeviceIsCompliant,
        DeviceIsManaged,
        DeviceTrustType,
        LocationCity,
        LocationState,
        LocationCountryOrRegion,
        LocationLatitude,
        LocationLongitude
    )
    SELECT
        @Id,
        @CreatedDateTime,
        @UserDisplayName,
        @UserPrincipalName,
        @UserId,
        @AppId,
        @AppDisplayName,
        @IpAddress,
        @ClientAppUsed,
        @CorrelationId,
        @ConditionalAccessStatus,
        @IsInteractive,
        @RiskDetail,
        @RiskLevelAggregated,
        @RiskLevelDuringSignIn,
        @RiskState,
        @RiskEventTypes,
        @RiskEventTypes_v2,
        @ResourceDisplayName,
        @ResourceId,
        @StatusCode,
        @StatusFailureReason,
        @StatusAdditionalDetails,
        @DeviceId,
        @DeviceDisplayName,
        @DeviceOperatingSystem,
        @DeviceBrowser,
        @DeviceIsCompliant,
        @DeviceIsManaged,
        @DeviceTrustType,
        @LocationCity,
        @LocationState,
        @LocationCountryOrRegion,
        @LocationLatitude,
        @LocationLongitude
    WHERE NOT EXISTS (
        SELECT 1 FROM SignInLogs WHERE Id = @Id
    )
"@

    # Loop through the sign-in logs and execute the SQL query for each record
    foreach ($log in $signInLogs.value) {
        $params = @{
            "@Id"                       = $log.id
            "@CreatedDateTime"           = $log.createdDateTime
            "@UserDisplayName"           = $log.userDisplayName
            "@UserPrincipalName"         = $log.userPrincipalName
            "@UserId"                   = $log.userId
            "@AppId"                    = $log.appId
            "@AppDisplayName"           = $log.appDisplayName
            "@IpAddress"                = $log.ipAddress
            "@ClientAppUsed"           = $log.clientAppUsed
            "@CorrelationId"             = $log.correlationId
            "@ConditionalAccessStatus"  = $log.conditionalAccessStatus
            "@IsInteractive"            = $log.isInteractive
            "@RiskDetail"               = $log.riskDetail
            "@RiskLevelAggregated"      = $log.riskLevelAggregated
            "@RiskLevelDuringSignIn"    = $log.riskLevelDuringSignIn
            "@RiskState"                = $log.riskState
            "@RiskEventTypes"           = $log.riskEventTypes -join ", "
            "@RiskEventTypes_v2"        = $log.riskEventTypes_v2 -join ", "
            "@ResourceDisplayName"      = $log.resourceDisplayName
            "@ResourceId"               = $log.resourceId
            "@StatusCode"               = $log.status.errorCode
            "@StatusFailureReason"      = $log.status.failureReason
            "@StatusAdditionalDetails"  = $log.status.additionalDetails
            "@DeviceId"                 = $log.deviceDetail.deviceId
            "@DeviceDisplayName"        = $log.deviceDetail.displayName
            "@DeviceOperatingSystem"    = $log.deviceDetail.operatingSystem
            "@DeviceBrowser"            = $log.deviceDetail.browser
            "@DeviceIsCompliant"        = $log.deviceDetail.isCompliant
            "@DeviceIsManaged"          = $log.deviceDetail.isManaged
            "@DeviceTrustType"          = $log.deviceDetail.trustType
            "@LocationCity"             = $log.location.city
            "@LocationState"            = $log.location.state
            "@LocationCountryOrRegion"  = $log.location.countryOrRegion
            "@LocationLatitude"         = $log.location.geoCoordinates.latitude
            "@LocationLongitude"        = $log.location.geoCoordinates.longitude
        }

        # Check if a record with the same ID already exists in the SignInLogs table
        $recordExistsQuery = "SELECT 1 FROM SignInLogs WHERE Id = @Id"
        $recordExists = Invoke-SqlQuery -Query $recordExistsQuery -Parameters $params

        if ($recordExists -eq $null) {
            # The record doesn't exist, so insert it
            Write-Host "Inserting data into the SQL table"

            try {
                # Execute the SQL query with parameters
                Invoke-SqlUpdate -Query $query -Parameters $params
                Write-Host "Data successfully inserted into the $databaseTable table."
            }
            catch {
                Write-Host "Error inserting data: $_"
                # You can log the error to a file or perform other error handling actions here
            }
        }
        else {
            Write-Host "Data with Id $($params['@Id']) already exists in the $databaseTable table. Skipping insertion."
        }
    }

    # Close the SQL connection
    Close-SqlConnection

    Write-Host "Data successfully written to SQL Server."
}
catch {
    Write-Host "Error: $_"
}
