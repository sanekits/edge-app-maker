# Function to validate URL
function Is-ValidUrl {
    param ([string]$Url)
    $Uri = $Url -as [System.Uri]
    return ($Uri.AbsoluteUri -ne $null -and $Uri.Scheme -match '^https?$')
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

# Create WScript.Shell object
$WshShell = New-Object -ComObject WScript.Shell

# Get desktop path
$DesktopPath = [Environment]::GetFolderPath("Desktop")

# Generate shortcut name from URL
$ShortcutName = ($url -replace '^https?://|www\.|\.[^.]+$') + " App"

# Create shortcut
$Shortcut = $WshShell.CreateShortcut("$DesktopPath\$ShortcutName.lnk")
$Shortcut.TargetPath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$Shortcut.Arguments = "--app=`"$url`""
$Shortcut.WorkingDirectory = "C:\Program Files (x86)\Microsoft\Edge\Application"
$Shortcut.Save()

Write-Host "Shortcut created: $ShortcutName"
