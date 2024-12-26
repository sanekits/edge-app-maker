# Function to validate and format URL
function Format-Url {
    param ([string]$Url)
    if (-not ($Url -match '^https?://')) {
        $Url = "https://$Url"
    }
    return $Url
}

# Function to get favicon
function Get-Favicon {
    param ([string]$Url)
    $faviconPath = [System.IO.Path]::Combine($env:LOCALAPPDATA, "WebAppShortcuts", "Favicons")
    if (-not (Test-Path $faviconPath)) {
        New-Item -ItemType Directory -Path $faviconPath -Force | Out-Null
    }
    
    $domain = ([System.Uri]$Url).Host
    $faviconFile = [System.IO.Path]::Combine($faviconPath, "$domain.ico")
    
    try {
        $faviconUrl = "$Url/favicon.ico"
        Invoke-WebRequest -Uri $faviconUrl -OutFile $faviconFile -ErrorAction Stop
        return $faviconFile
    } catch {
        Write-Host "Favicon not found or couldn't be downloaded."
        return $null
    }
}

# Get URL from clipboard and format it
$url = Get-Clipboard -Raw
$url = Format-Url $url

# If URL is still invalid, prompt the user
if (-not ([System.Uri]::IsWellFormedUriString($url, [System.UriKind]::Absolute))) {
    $url = Read-Host "Enter a valid URL (e.g., example.com)"
    $url = Format-Url $url
}

# Get favicon
$faviconPath = Get-Favicon $url

# Create WScript.Shell object
$WshShell = New-Object -ComObject WScript.Shell

# Get desktop path
$DesktopPath = [Environment]::GetFolderPath("Desktop")

# Generate shortcut name from URL
$ShortcutName = ([System.Uri]$url).Host -replace '^www\.'

# Create shortcut
$Shortcut = $WshShell.CreateShortcut("$DesktopPath\$ShortcutName.lnk")
$Shortcut.TargetPath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$Shortcut.Arguments = "--app=`"$url`""
$Shortcut.WorkingDirectory = "C:\Program Files (x86)\Microsoft\Edge\Application"

# Set icon if favicon was found
if ($faviconPath -and (Test-Path $faviconPath)) {
    $Shortcut.IconLocation = $faviconPath
}

$Shortcut.Save()

Write-Host "Shortcut created: $ShortcutName"
