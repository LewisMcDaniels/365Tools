# Define the two directories to compare for restore purposes when unknown data is missing.
Write-Host "This script compares two directories and identifies files that are missing in one of them. 
It also copies the missing files from one directory to another, preserving the folder structure." -ForegroundColor Green

$directory1 = Read-Host "Enter the path to the live directory"
$directory2 = Read-Host "Enter the path to the restore directory"

# Get the file names from both directories
$files1 = Get-ChildItem -Path $directory1 -File | Select-Object -ExpandProperty Name
$files2 = Get-ChildItem -Path $directory2 -File | Select-Object -ExpandProperty Name

# Find files that are only in the first directory
$onlyInDirectory1 = $files1 | Where-Object { $_ -notin $files2 }

# Find files that are only in the second directory
$onlyInDirectory2 = $files2 | Where-Object { $_ -notin $files1 }

# Output the results
Write-Output "Files only in $directory1"
$onlyInDirectory1

Write-Output "`nFiles only in $directory2"
$onlyInDirectory2

# Copy files from the second directory to the first directory, preserving folder structure recursively
$filesToCopy = Get-ChildItem -Path $directory2 -Recurse -File | Where-Object {
    $relativePath = $_.FullName.Substring($directory2.Length).TrimStart('\')
    -not (Test-Path -Path (Join-Path -Path $directory1 -ChildPath $relativePath))
}

foreach ($file in $filesToCopy) {
    $relativePath = $file.FullName.Substring($directory2.Length).TrimStart('\')
    $sourcePath = $file.FullName
    $destinationPath = Join-Path -Path $directory1 -ChildPath $relativePath

    # Ensure the destination directory exists
    $destinationDir = Split-Path -Path $destinationPath -Parent
    if (-not (Test-Path -Path $destinationDir)) {
        New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
    }

    # Copy the file
    Copy-Item -Path $sourcePath -Destination $destinationPath -Force
}

    # Copy the file
    Copy-Item -Path $sourcePath -Destination $destinationPath -Force
Write-Output "`nFiles from $directory2 copied to $directory1 where missing."