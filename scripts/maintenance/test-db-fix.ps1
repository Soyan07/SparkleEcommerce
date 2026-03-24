$connString = "Server=localhost\SQLEXPRESS02;Database=master;Integrated Security=True;TrustServerCertificate=True;Connection Timeout=5"
Write-Host "Testing connection to: localhost\SQLEXPRESS02"
try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connString
    $conn.Open()
    Write-Host "Success! Connected to localhost\SQLEXPRESS02" -ForegroundColor Green
    $conn.Close()
} catch {
    Write-Host "Failed to connect to localhost\SQLEXPRESS02: $_" -ForegroundColor Red
}
