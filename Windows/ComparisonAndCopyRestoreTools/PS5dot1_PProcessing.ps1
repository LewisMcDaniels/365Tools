# Define the two directories to compare for restore purposes when unknown data is missing.
Write-Host "This script compares two directories and identifies files that are missing in one of them based on name. 
It can also copy the missing files from restore directory to the live directory, preserving the folder structure." -ForegroundColor Green

$directory1 = Read-Host "Enter the path to the live directory"
$directory2 = Read-Host "Enter the path to the restore directory"
Write-Host "Comparing files in $directory1 and $directory2..." -ForegroundColor Yellow

# Get all files from both directories recursively
Write-Host "Loading file lists..." -ForegroundColor Cyan
$files1 = Get-ChildItem -Path $directory1 -Recurse -File -ErrorAction SilentlyContinue
$files2 = Get-ChildItem -Path $directory2 -Recurse -File -ErrorAction SilentlyContinue

# Use HashSet for faster lookups
Write-Host "Building file comparison sets..." -ForegroundColor Cyan
$relativeFiles1 = [System.Collections.Generic.HashSet[string]]::new()
$relativeFiles2 = [System.Collections.Generic.HashSet[string]]::new()

foreach ($file in $files1) {
    $relativeFiles1.Add($file.FullName.Substring($directory1.Length).TrimStart('\'))
}

foreach ($file in $files2) {
    $relativeFiles2.Add($file.FullName.Substring($directory2.Length).TrimStart('\'))
}

# Find files that are only in the second directory (missing from the first directory)
Write-Host "Identifying missing files..." -ForegroundColor Cyan
$missingInDirectory1 = $relativeFiles2.Where({ -not $relativeFiles1.Contains($_) })

# Output the results with file sizes
Write-Host "`nFiles missing in ${directory1} but present in ${directory2}:" -ForegroundColor Green
$totalSize = 0
$missingFiles = @()

# Use jobs for parallel processing to calculate file sizes
$jobs = @()
foreach ($relativePath in $missingInDirectory1) {
    $jobs += Start-Job -ScriptBlock {
        param ($relativePath, $directory2)
        $file = Get-ChildItem -Path $directory2 -Recurse -File | Where-Object { $_.FullName.EndsWith($relativePath) }
        if ($file) {
            [PSCustomObject]@{
                Path = $relativePath
                SizeKB = [math]::Round($file.Length / 1KB, 2)
                FullPath = $file.FullName
            }
        }
    } -ArgumentList $relativePath, $directory2
}


# Wait for all jobs to complete
if ($jobs -and $jobs.Count -gt 0) {
    Wait-Job -Job $jobs
} else {
    Write-Host "No jobs to wait for, collecting results." -ForegroundColor Yellow
}

# Collect results after all jobs are finished
$missingFiles = $jobs | ForEach-Object {
    $jobResult = Receive-Job -Job $_
    Remove-Job -Job $_
    $jobResult
} | Where-Object { $_ -ne $null }

$totalSize = ($missingFiles | Measure-Object -Property SizeKB -Sum).Sum
$missingFiles | Format-Table -Property Path, SizeKB -AutoSize

# Output the total size of missing files
Write-Host "`nTotal size of missing files: $([math]::Round($totalSize / 1024, 2)) MB" -ForegroundColor Green

Write-Host "Choose from the following options:" -ForegroundColor Green
Write-Host "1. Exit the script" -ForegroundColor Red
Write-Host "9. Copy files from $directory2 to $directory1 where missing" -ForegroundColor Yellow
$option = Read-Host "Enter your choice (1 or 9)"

switch ($option) {
    9 {
        Write-Host "Copying missing files..." -ForegroundColor Yellow

        # Use jobs for parallel processing to copy files
        $copyJobs = @()
        foreach ($file in $missingFiles) {
            $copyJobs += Start-Job -ScriptBlock {
                param ($file, $directory1, $directory2)
                $sourcePath = Join-Path -Path $directory2 -ChildPath $file.Path
                $destinationPath = Join-Path -Path $directory1 -ChildPath $file.Path

                # Ensure the destination directory exists
                $destinationDir = Split-Path -Path $destinationPath -Parent
                if (-not (Test-Path -Path $destinationDir)) {
                    New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
                }

                # Copy the file
                Copy-Item -Path $sourcePath -Destination $destinationPath -Force
            } -ArgumentList $file, $directory1, $directory2
        }

        # Wait for all copy jobs to complete
        if ($copyJobs -and $copyJobs.Count -gt 0) {
            Wait-Job -Job $copyJobs
            $copyJobs | ForEach-Object {
                Receive-Job -Job $_
                Remove-Job -Job $_
            }
        } else {
            Write-Host "No files to copy, skipping job processing." -ForegroundColor Yellow
        }

        Write-Host "`nFiles from $directory2 copied to $directory1 where missing." -ForegroundColor Green

    }
    1 {
        Write-Host "Exiting the script." -ForegroundColor Red
        exit
    }
    default {
        Write-Host "Invalid option. Please enter 1 or 9." -ForegroundColor Red
    }
}