# This script checks for misconfigured file permissions and services that can be exploited for privilege escalation on a Windows 10 system.

# Check for misconfigured file permissions
$folders = "C:\Program Files", "C:\Windows"
foreach ($folder in $folders) {
    $acl = Get-Acl $folder
    foreach ($access in $acl.Access) {
        if (($access.IdentityReference -eq "BUILTIN\Users") -and ($access.FileSystemRights -like "*Write*")) {
            Write-Host "Misconfigured file permission found: $($access.FileSystemRights) access granted to $($access.IdentityReference) on $($folder)"
        }
    }
}

# Check for services with unquoted paths
$services = Get-WmiObject -Class Win32_Service | Where-Object {$_.StartName -notmatch "LocalSystem" -and $_.StartName -notmatch "NT Authority\LocalService" -and $_.StartName -notmatch "NT Authority\NetworkService"}
foreach ($service in $services) {
    if ($service.PathName -notmatch '^".*"$') {
        Write-Host "Service $($service.Name) has unquoted path: $($service.PathName)"
    }
}
