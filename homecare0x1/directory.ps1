# Output file
$output = "directory.txt"

# Clear or create the output file
Set-Content -Path $output -Value $null
$contentAdded = $false

Write-Output "Script started. Current directory: $(Get-Location)"

# Find all directories containing .dart or .yaml files
Get-ChildItem -Directory -Recurse | ForEach-Object {
    $dir = $_
    Write-Output "Checking directory: $($dir.FullName)"
    # Find matching files in this directory and subdirectories
    $files = Get-ChildItem -Path $dir.FullName -File -Include *.dart,*.yaml -Recurse | 
             Select-Object -ExpandProperty Name | 
             Sort-Object
    Write-Output "Found files: $($files -join ', ')"

    # If there are matching files in this directory
    if ($files) {
        # Print directory header (removing './' equivalent)
        $relativePath = $dir.FullName.Substring((Get-Location).Path.Length + 1)
        Add-Content -Path $output -Value "directory: $relativePath"

        # Print each file with indentation
        $files | ForEach-Object {
            Add-Content -Path $output -Value "    |---$_"
        }

        # Add empty line between directories
        Add-Content -Path $output -Value ""
        $contentAdded = $true
    }
}

if ($contentAdded) {
    Write-Output "Directory structure has been saved to $output"
} else {
    Write-Output "No .dart or .yaml files found, nothing written to $output"
}