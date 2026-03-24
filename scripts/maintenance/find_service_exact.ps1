Get-Service | Where-Object { $_.Name -like "MSSQL$*" } | Select-Object Name, Status | Format-Table -AutoSize | Out-String -Width 4096
