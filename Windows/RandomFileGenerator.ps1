# Prompt the user for the file amount and total size limits
$fileAmount = [long](Read-Host "Enter the maximum number of files to create")
$minTotalSizeLimit = [long](Read-Host "Enter the minimum total size limit in MB") * 1MB
$totalSizeLimit = [long](Read-Host "Enter the maximum total size limit in MB") * 1MB
$minFileSize = [long](Read-Host "Enter the minimum individual file size in MB") * 1MB
$MaxFileSize = [long](Read-Host "Enter the maximum individual file size in MB") * 1MB 


$ErrorActionPreference= 'silentlycontinue'

# Get the location to write the files to
$location = Read-Host "Enter the location to write the files to"

# Get the available disk space
$diskSpace = (Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -eq (Get-Item $location).PSDrive.Root }).Free

# Debugging information
Write-Host "Disk space available: $([math]::Round($diskSpace / 1MB, 2)) MB" -ForegroundColor DarkGreen
Write-Host "Total size limit: $([math]::Round($totalSizeLimit / 1MB, 2)) MB" -ForegroundColor DarkGreen
Write-Host "Minimum total size limit: $([math]::Round($minTotalSizeLimit / 1MB, 2)) MB" -ForegroundColor DarkGreen
Write-Host "Min file size: $([math]::Round($minFileSize / 1MB, 2)) MB" -ForegroundColor DarkGreen
Write-Host "Max file size: $([math]::Round($MaxFileSize / 1MB, 2)) MB" -ForegroundColor DarkGreen
Write-Host "Location: $location" -ForegroundColor Green

# Loop until the total size limit, minimum total size limit, or disk space threshold is reached
$totalSize = 0
$counter = 1
while (($totalSize -lt $totalSizeLimit -or $totalSize -lt $minTotalSizeLimit) -and $counter -le $fileAmount) {
    # Update the threshold for stopping the script
    $threshold = $diskSpace * 0.85 # 85% of available disk space

    # Check if the remaining disk space is below the threshold
    if ($diskSpace -le $threshold) {
        Write-Host "Remaining disk space is below the threshold. Stopping file creation." -ForegroundColor Red
        break
    }

    # Generate a random file size between minFileSize and MaxFileSize
    if ($minFileSize -eq $MaxFileSize) {
        $fileSize = $minFileSize
    } else {
        $fileSize = Get-Random -Minimum $minFileSize -Maximum $MaxFileSize
    }

    # Debugging information
    Write-Host "Attempting to create Random file $counter with size $([math]::Round($fileSize / 1MB, 2)) MB" -ForegroundColor Yellow

    # Check if the file size exceeds the remaining disk space
    if ($fileSize -gt $diskSpace) {
        Write-Host "Not enough disk space for Random file of size $([math]::Round($fileSize / 1MB, 2)) MB" -ForegroundColor Red
        break
    }

    # Create a random file with the specified size
    $fileName = Join-Path -Path $location -ChildPath "RandomFile$counter.txt"
    
    # Write the file in chunks if the size is larger than Int32.MaxValue
    $chunkSize = [int][Math]::Min($fileSize, [int][Math]::Min([int]::MaxValue, 1MB))
    $remainingSize = $fileSize
    $fileStream = [System.IO.File]::Create($fileName)
    $bufferedStream = New-Object System.IO.BufferedStream($fileStream, $chunkSize) -ErrorAction SilentlyContinue
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    
    try {
        while ($remainingSize -gt 0) {
            $currentChunkSize = [int][Math]::Min($remainingSize, $chunkSize)
            $buffer = New-Object byte[] $currentChunkSize -ErrorAction SilentlyContinue
            $rng.GetBytes($buffer)
            $bufferedStream.Write($buffer, 0, $currentChunkSize)
            $remainingSize -= $currentChunkSize
        }
    } finally {
        $bufferedStream.Close()
        $fileStream.Close()
    }

    # Update the total size and disk space
    $totalSize += $fileSize
    $diskSpace -= $fileSize

    # Increment the counter
    $counter++

    # Debugging information
    Write-Host "Created file: $fileName of size $([math]::Round($fileSize / 1MB, 2)) MB"
    Write-Host "Total size so far: $([math]::Round($totalSize / 1MB, 2)) MB"
    Write-Host "Remaining disk space: $([math]::Round($diskSpace / 1GB, 2)) GB" -ForegroundColor Magenta

}

Write-Host
Write-Host
Write-Host
Write-Host

Write-Host "Files created: $($counter - 1)"
if ($totalSize -lt 1GB) {
    $totalSizeFormatted = "{0} MB" -f ($totalSize / 1MB)
} else {
    $totalSizeFormatted = "{0} GB" -f ($totalSize / 1GB)
}

Write-Host "Total size: $totalSizeFormatted"
# Get the available disk space
$diskSpace = (Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -eq (Get-Item $location).PSDrive.Root }).Free

# Display the total free space on the disk
Write-Host "Total free space on the disk: $([math]::Round($diskSpace / 1GB, 2)) GB" -ForegroundColor Cyan
