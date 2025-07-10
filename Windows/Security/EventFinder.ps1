# Description: This script retrieves specific security events from the Windows Event Log.
$SearchID = Read-Host "Enter the Event ID to search for (e.g., 4624 for logon events, or comma-separated IDs like 4624,4625): "
$StringToSearch = read-host "Enter a string to search for in the event messages (optional, use * for wildcard): "
# Ask user for the source of events
$eventSource = Read-Host "Search in [L]ive event log or [F]ile (.evtx)? (L/F)"

# Set up filter based on source selection
$filter = @{}

# Handle Event ID(s)
if ($SearchID -match ',') {
    # Handle multiple IDs separated by commas
    $IDs = $SearchID -split ',' | ForEach-Object { $_.Trim() -as [int] } | Where-Object { $_ -ne $null }
    $filter.ID = $IDs
} else {
    # Single ID case
    $filter.ID = $SearchID -as [int]
}

# Handle event source
if ($eventSource -eq "L" -or $eventSource -eq "l") {
    $logName = Read-Host "Enter the log name (e.g., Security, Application, System)"
    
    # Validate that the log name exists
    $availableLogs = Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | Select-Object -ExpandProperty LogName
    if ($availableLogs -notcontains $logName) {
        Write-Host "Error: '$logName' is not a valid event log name." -ForegroundColor Red
        Write-Host "Available logs include: Security, Application, System, etc." -ForegroundColor Yellow
        exit
    }
    $filter.LogName = $logName
} elseif ($eventSource -eq "F" -or $eventSource -eq "f") {
    $filePath = Read-Host "Enter the full path to the .evtx file"
    $filter.Path = $filePath
} else {
    Write-Host "Invalid selection. Exiting script."
    exit
}

$events = Get-WinEvent -FilterHashtable $filter -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, Id, LevelDisplayName, Message, Properties |
    Where-Object {
        if ($StringToSearch -and $StringToSearch -ne "*") {
            $_.Message -like "*$StringToSearch*"
        } else {
            $true
        }
    }

Write-Host "Found $($events.Count) events with ID $SearchID."

$SaveLocation = Read-Host "Do you want to save the results to a file? (Y/N)"
if ($SaveLocation -eq "Y" -or $SaveLocation -eq "y") {
    $filePath = Read-Host "Enter the file path to save the results (e.g., C:\Events.txt, default is C:\Temp\EventOutput.txt)"
    if ([string]::IsNullOrWhiteSpace($filePath)) {
        $filePath = "C:\Temp\EventOutput.txt"
    }
    $events | Out-File -FilePath $filePath -Encoding UTF8
    Write-Host "Results saved to $filePath" -ForegroundColor Green
} else {
    Write-Host "Results not saved."
}

# Display results
$events | Format-Table -AutoSize
Write-Host "Script completed." -ForegroundColor Green
Write-Host "Press any key to exit..."