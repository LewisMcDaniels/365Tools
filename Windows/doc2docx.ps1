$sourcePath = Read-Host "Enter the source directory path"
# Create a new folder called "converted2docx" in the source directory
$convertedFolderPath = Join-Path -Path $sourcePath -ChildPath "converted2docx"
New-Item -ItemType Directory -Path $convertedFolderPath -Force
# Get all .doc files in the source directory
$docFiles = Get-ChildItem -Path $sourcePath -Filter "*.doc" -Recurse

foreach ($file in $docFiles) {
    # Construct the new .docx file path
    $newFilePath = $file.FullName -replace ".doc$", ".docx"

    # Convert the .doc file to .docx using Microsoft Word
    $word = New-Object -ComObject Word.Application
    $doc = $word.Documents.Open($file.FullName)
    $doc.SaveAs([ref]$newFilePath, [ref]16)
    $doc.Close()
    $word.Quit()

    # Output the location of the new file
    Write-Host "Converted file saved at: $newFilePath"
}
# Move all converted files into the converted2docx folder
$convertedFiles = Get-ChildItem -Path $sourcePath -Filter "*.docx" -Recurse
foreach ($file in $convertedFiles) {
    $destinationPath = Join-Path -Path $convertedFolderPath -ChildPath $file.Name
    Move-Item -Path $file.FullName -Destination $destinationPath
}
Write-Host "Conversion complete!"