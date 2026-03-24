Get-Service | Where-Object { $_.DisplayName -like "*SQL*" -or $_.Name -like "*MSSQL*" } | Select-Object Name, DisplayName, Status | Format-Table -AutoSize | Out-String -Width 4096
