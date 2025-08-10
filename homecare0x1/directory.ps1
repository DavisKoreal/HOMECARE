# Output file
$output = "directory.txt"

# Clear or create the output file
Set-Content -Path $output -Value $null

# Find all directories containing .dart or .yaml files
Get-ChildItem -Directory -Recurse | ForEach-Object {
    $dir = $_
    # Find matching files in this directory
    $files = Get-ChildItem -Path $dir.FullName -File -Include *.dart,*.yaml | 
             Select-Object -ExpandProperty Name | 
             Sort-Object

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
    }
}

Write-Output "Directory structure has been saved to $output"