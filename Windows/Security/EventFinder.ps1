# Description: This script retrieves specific security events from the Windows Event Log.
$SearchID = read-host "Enter the Event ID to search for (e.g., 4624 for logon events): 
$StringToSearch = read-host "Enter a string to search for in the event messages (optional):
# Ask user for the source of events
$eventSource = Read-Host "Search in [L]ive event log or [F]ile (.evtx)? (L/F)"

# Set up filter based on source selection
$filter = @{
    ID = $SearchID
}

if ($eventSource -eq "L" -or $eventSource -eq "l") {
    $logName = Read-Host "Enter the log name (e.g., Security, Application, System)"
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
        if ($StringToSearch) {
            $_.Message -like "*$StringToSearch*"
        } else {
            $true
        }
    } |

$events | Format-Table -AutoSize
Write-Host "Found $($events.Count) events with ID $SearchID.

$events | Out-File -FilePath "Events_$SearchID.txt" -Encoding UTF8