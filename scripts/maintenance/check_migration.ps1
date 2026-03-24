$connectionString = "Server=.\SQLEXPRESS;Database=SparkleEcommerce;Trusted_Connection=True;TrustServerCertificate=True;"
$query = @"
SELECT 'Table Exists' as Type, COUNT(*) as Count FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE t.name = 'ActivityLog' AND s.name = 'dynamic'
UNION ALL
SELECT 'Migration', MigrationId FROM __EFMigrationsHistory ORDER BY MigrationId DESC
"@

try {
    $connection = New-Object Microsoft.Data.SqlClient.SqlConnection $connectionString
    $connection.Open()
    $command = $connection.CreateCommand()
    $command.CommandText = "SELECT COUNT(*) FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE t.name = 'ActivityLog' AND s.name = 'dynamic'"
    $tableExists = $command.ExecuteScalar()
    Write-Host "`n[dynamic].[ActivityLog] exists: $tableExists"

    $command.CommandText = "SELECT TOP 10 MigrationId FROM __EFMigrationsHistory ORDER BY MigrationId DESC"
    $reader = $command.ExecuteReader()
    Write-Host "`nLast 10 Applied Migrations:"
    while ($reader.Read()) {
        Write-Host "- $($reader.GetString(0))"
    }
    $connection.Close()
}
catch {
    Write-Error $_.Exception.Message
}
