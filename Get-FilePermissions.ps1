param (
    [string]$FolderPath
)

# Function to get permissions of a file or directory
function Get-Permissions {
    param (
        [string]$Path
    )
    $acl = Get-Acl -Path $Path
    $permissions = $acl.Access | ForEach-Object {
        [PSCustomObject]@{
            Path = $Path
            Identity = $_.IdentityReference
            Permissions = $_.FileSystemRights
        }
    }
    return $permissions
}

# Function to recursively iterate through folders and files
function Get-FolderPermissions {
    param (
        [string]$FolderPath
    )
    $items = Get-ChildItem -Path $FolderPath -Recurse
    $totalItems = $items.Count
    $progress = 0
    $items | ForEach-Object {
        $progress++
        Write-Progress -Activity "Getting Permissions" -Status "Progress: $($progress * 100 / $totalItems)%" -PercentComplete ($progress * 100 / $totalItems)
        Get-Permissions -Path $_.FullName
    }
}

# Get permissions for each file and folder recursively
$Permissions = Get-FolderPermissions -FolderPath $FolderPath

# Export to CSV
$Permissions | Select-Object -Property Path, Identity, Permissions | Export-Csv -Path "Permissions.csv" -NoTypeInformation
