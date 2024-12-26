# Function to validate URL
function Is-ValidUrl {
    param ([string]$Url)
    $Uri = $Url -as [System.Uri]
    return ($Uri.AbsoluteUri -ne $null -and $Uri.Scheme -match '^https?$')
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

# Get URL from clipboard
$url = Get-Clipboard -Raw

# If clipboard doesn't contain a valid URL, prompt the user
if (-not (Is-ValidUrl $url)) {
    $url = Read-Host "Enter a valid URL (e.g., https://www.example.com)"
    while (-not (Is-ValidUrl $url)) {
        $url = Read-Host "Invalid URL. Please enter a valid URL"
    }
}

# Get webpage title
$defaultName = Get-WebpageTitle $url
if (-not $defaultName) {
    $defaultName = ($url -replace '^https?://|www\.|\.[^.]+$') + " App"
}

# Prompt user for name, defaulting to webpage title
$shortcutName = Read-Host "Enter a name for the shortcut (default: $defaultName)"
if ([string]::IsNullOrWhiteSpace($shortcutName)) {
    $shortcutName = $defaultName
}

# Create WScript.Shell object
$WshShell = New-Object -ComObject WScript.Shell

# Get desktop path
$DesktopPath = [Environment]::GetFolderPath("Desktop")

# Create shortcut
$Shortcut = $WshShell.CreateShortcut("$DesktopPath\$shortcutName.lnk")
$Shortcut.TargetPath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$Shortcut.Arguments = "--app=`"$url`""
$Shortcut.WorkingDirectory = "C:\Program Files (x86)\Microsoft\Edge\Application"
$Shortcut.Save()

Write-Host "Shortcut created: $shortcutName"

