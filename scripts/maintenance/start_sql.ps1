try {
    Write-Host "Attempting to start MSSQL`$SQLEXPRESS..."
    Start-Service -Name 'MSSQL$SQLEXPRESS' -ErrorAction Stop
    Write-Host "Service started successfully." -ForegroundColor Green
} catch {
    Write-Host "Failed to start service: $_" -ForegroundColor Red
    Write-Host "Try running this script as Administrator." -ForegroundColor Yellow
}
