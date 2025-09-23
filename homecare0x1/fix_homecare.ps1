# fix_homecare.ps1
param(
    [string]$RepoRoot = "C:\Users\Administrator\Desktop\HOMECARE\homecare0x1",
    [string]$ProjectId = "arandomtestproject"
)

Write-Host "=== Starting Firebase Hosting Fixer for Flutter Web ==="

$BuildWeb = Join-Path $RepoRoot "build\web"
$BackupZip = Join-Path $RepoRoot "build-web-fix-backup_$(Get-Date -Format yyyyMMdd-HHmmss).zip"

# 1) Backup build/web again (safe copy before deletion)
if (Test-Path $BuildWeb) {
    Write-Host "Backing up $BuildWeb to $BackupZip ..."
    Add-Type -AssemblyName 'System.IO.Compression.FileSystem'
    [System.IO.Compression.ZipFile]::CreateFromDirectory($BuildWeb, $BackupZip)
} else {
    Write-Warning "build/web not found. Skipping backup."
}

# 2) Delete scaffolded Flutter project inside build/web
$ScaffoldItems = @("pubspec.yaml", "pubspec.lock", "analysis_options.yaml", "README.md", "lib", "test", ".idea", ".dart_tool", "web")
foreach ($item in $ScaffoldItems) {
    $Target = Join-Path $BuildWeb $item
    if (Test-Path $Target) {
        Write-Host "Removing scaffolded item: $Target"
        Remove-Item $Target -Recurse -Force
    }
}

# 3) Fix firebase.json
$FirebaseJson = Join-Path $RepoRoot "firebase.json"
if (Test-Path $FirebaseJson) {
    Write-Host "Patching firebase.json hosting.public..."
    $json = Get-Content $FirebaseJson | Out-String | ConvertFrom-Json
    
    # Force hosting.public to correct path
    if (-not $json.hosting) {
        $json | Add-Member -MemberType NoteProperty -Name hosting -Value @{}
    }
    $json.hosting.public = "homecare0x1/build/web"
    
    $json | ConvertTo-Json -Depth 10 | Out-File -Encoding UTF8 $FirebaseJson
} else {
    Write-Warning "firebase.json not found at $FirebaseJson. Skipping patch."
}

# 4) Create .firebaserc if missing
$Firebaserc = Join-Path $RepoRoot ".firebaserc"
if (-not (Test-Path $Firebaserc)) {
    Write-Host "Creating .firebaserc with project $ProjectId ..."
    $rc = @{
        projects = @{
            default = $ProjectId
        }
    }
    $rc | ConvertTo-Json -Depth 10 | Out-File -Encoding UTF8 $Firebaserc
} else {
    Write-Host ".firebaserc already exists. Skipping creation."
}

# 5) Stage changes in Git
Set-Location $RepoRoot
git add firebase.json .firebaserc build\web

Write-Host "=== Fixes applied successfully ==="
Write-Host "Next steps:"
Write-Host "  1) flutter clean && flutter build web"
Write-Host "  2) firebase deploy --only hosting"
Write-Host "  3) git commit -m 'Fix Firebase Hosting setup' && git push"
