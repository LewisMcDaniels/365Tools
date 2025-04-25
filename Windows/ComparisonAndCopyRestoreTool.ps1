# Define the two directories to compare for restore purposes when unknown data is missing.
Write-Host "This script compares two directories and identifies files that are missing in one of them based on name. 
It can also copy the missing files from restore directory to the live directory, preserving the folder structure." -ForegroundColor Green

$directory1 = Read-Host "Enter the path to the live directory"
$directory2 = Read-Host "Enter the path to the restore directory"
write-host "Comparing files in $directory1 and $directory2..." -ForegroundColor Yellow

# Get all files from both directories recursively
$files1 = Get-ChildItem -Path $directory1 -Recurse -File
$files2 = Get-ChildItem -Path $directory2 -Recurse -File

# Create a hashtable to store relative paths for comparison
$relativeFiles1 = @{}
$relativeFiles2 = @{}

foreach ($file in $files1) {
    $relativePath = $file.FullName.Substring($directory1.Length).TrimStart('\')
    $relativeFiles1[$relativePath] = $file
}

foreach ($file in $files2) {
    $relativePath = $file.FullName.Substring($directory2.Length).TrimStart('\')
    $relativeFiles2[$relativePath] = $file
}

# Find files that are only in the second directory (missing from the first directory)
$missingInDirectory1 = $relativeFiles2.Keys | Where-Object { $_ -notin $relativeFiles1.Keys }

# Output the results with file sizes
Write-Output "`nFiles missing in ${directory1} but present in ${directory2}:"
$totalSize = 0
foreach ($relativePath in $missingInDirectory1) {
    $file = $relativeFiles2[$relativePath]
    $fileSize = $file.Length
    $totalSize += $fileSize
    Write-Output "$relativePath - Size: $([math]::Round($fileSize / 1KB, 2)) KB"
}

# Output the total size of missing files
Write-Output "`nTotal size of missing files: $([math]::Round($totalSize / 1MB, 2)) MB"

write-host "Choose from the following options:" -ForegroundColor Green
Write-Host "1. Exit the script" -ForegroundColor Red
Write-Host "9. Copy files from $directory2 to $directory1 where missing" -ForegroundColor Yellow
$option = Read-Host "Enter your choice (1 or 9)"

switch ($option) {
   9 {# Copy files from the second directory to the first directory, preserving folder structure recursively
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
    }
   
   
   1 {
       Write-Host "Exiting the script." -ForegroundColor Red
       exit
   }
   default {
       Write-Host "Invalid option. Please enter 1 or 9." -ForegroundColor Red
   } 
   catch {
       Write-Host "An error occurred: $_" -ForegroundColor Red
   }
}
   