# Define the output file
$output = "state.txt"

# Clear or create the output file
Set-Content -Path $output -Value $null

# Default to the current working directory
$directory = Get-Location

# Check if the directory exists (though Get-Location should always return a valid directory)
if (-not (Test-Path -Path $directory -PathType Container)) {
    Write-Error "Error: '$directory' is not a valid directory"
    exit 1
}

# Define the files to process
$source_extensions = @("*.dart", "pubspec.yaml")

# Iterate through source file extensions
foreach ($ext in $source_extensions) {
    if ($ext -eq "pubspec.yaml") {
        # Specifically handle pubspec.yaml in the root directory
        $file = Join-Path -Path $directory -ChildPath "pubspec.yaml"
        if (Test-Path -Path $file -PathType Leaf) {
            Add-Content -Path $output -Value "===== $file ====="
            Get-Content -Path $file | Add-Content -Path $output
            Add-Content -Path $output -Value "`n"
        }
    } else {
        # Find and process .dart files in the lib folder recursively
        $libPath = Join-Path -Path $directory -ChildPath "lib"
        if (Test-Path -Path $libPath -PathType Container) {
            Get-ChildItem -Path $libPath -File -Recurse -Include $ext | ForEach-Object {
                Add-Content -Path $output -Value "===== $($_.FullName) ====="
                Get-Content -Path $_.FullName | Add-Content -Path $output
                Add-Content -Path $output -Value "`n"
            }
        }
    }
}

Write-Output "File contents have been saved to $output"