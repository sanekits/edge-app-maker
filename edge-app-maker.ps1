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

# Function to get webpage title
function Get-WebpageTitle {
    param ([string]$Url)
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing
        $title = $response.ParsedHtml.title
        return $title.Trim()
    } catch {
        return $null
    }
}

# Main script
$url = Read-Host "Enter a valid URL (e.g., https://www.example.com)"
$url = Format-Url $url

# Get the default name for the shortcut
$defaultName = Get-WebpageTitle $url
if (-not $defaultName) {
    $defaultName = ([System.Uri]$url).Host
}

# Prompt the user for the shortcut name with the default value
$shortcutName = Read-Host "Enter a name for the shortcut (default: $defaultName)"
if (-not $shortcutName) {
    $shortcutName = $defaultName
}

# Create shortcut
$WshShell = New-Object -ComObject WScript.Shell
$DesktopPath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath("Desktop"))
$Shortcut = $WshShell.CreateShortcut("$DesktopPath\$shortcutName.lnk")
$Shortcut.TargetPath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$Shortcut.Arguments = "--app=`"$url`""
$Shortcut.WorkingDirectory = "C:\Program Files (x86)\Microsoft\Edge\Application"

# Set icon if favicon was found
$faviconPath = Get-Favicon $url
if ($faviconPath -and (Test-Path $faviconPath)) {
    $Shortcut.IconLocation = $faviconPath
}

$Shortcut.Save()

Write-Host "Shortcut created: $shortcutName"
