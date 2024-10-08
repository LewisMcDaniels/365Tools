# List all certificates installed on the local machine affected by CVE-2019-35291
$algorithms = @("md5RSA", "md2RSA", "sha1RSA", "md5ECDSA", "md2ECDSA", "sha1ECDSA")
$results = @()

foreach ($algorithm in $algorithms) {
    Get-ChildItem -Path Cert:\ -Recurse |
    Where-Object { $_.SignatureAlgorithm.FriendlyName -eq $algorithm } |
    ForEach-Object {
        if ($_.NotAfter -gt (Get-Date)) {
            $results += [PSCustomObject]@{
                Algorithm       = $algorithm
                CertificateName = $_.Subject
                NotAfter        = $_.NotAfter
                Thumbprint      = $_.Thumbprint
                Issuer          = $_.Issuer
            }
        }
    }
}

# Export results to CSV
$CSVpath = Read-Host "Enter the path to save the results to"
$results | Export-Csv -Path $CSVpath -NoTypeInformation

if ($?) {
    Write-Host "Results successfully exported to $CSVpath" -ForegroundColor Green
} else {
    Write-Host "Failed to export results" -ForegroundColor Red
}