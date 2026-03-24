Get-Service -Name "MSSQL*" | Select-Object Name, DisplayName, Status | Format-Table -AutoSize | Out-String -Width 4096
Get-Service -Name "*SQLEXPRESS*" | Select-Object Name, DisplayName, Status | Format-Table -AutoSize | Out-String -Width 4096
