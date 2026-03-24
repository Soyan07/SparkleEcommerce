using Microsoft.Data.SqlClient;
using System.Data;

var connectionString = "Server=.\\SQLEXPRESS;Database=SparkleEcommerce;Trusted_Connection=True;TrustServerCertificate=True;";
Console.WriteLine("Checking Database State for Migration Conflict...");

try
{
    using var connection = new SqlConnection(connectionString);
    await connection.OpenAsync();
    
    // 1. Check if ActivityLog table exists
    var checkTableCmd = new SqlCommand("SELECT COUNT(*) FROM sys.tables t JOIN sys.schemas s ON t.schema_id = s.schema_id WHERE t.name = 'ActivityLog' AND s.name = 'dynamic'", connection);
    var tableExists = (int)await checkTableCmd.ExecuteScalarAsync() > 0;
    Console.WriteLine($"\n[dynamic].[ActivityLog] exists: {tableExists}");

    // 2. Check __EFMigrationsHistory
    Console.WriteLine("\nLast 10 Applied Migrations:");
    var historyCmd = new SqlCommand("SELECT TOP 10 MigrationId FROM __EFMigrationsHistory ORDER BY MigrationId DESC", connection);
    using var reader = await historyCmd.ExecuteReaderAsync();
    while (await reader.ReadAsync())
    {
        Console.WriteLine($"- {reader.GetString(0)}");
    }
}
catch (Exception ex)
{
    Console.WriteLine($"Error: {ex.Message}");
}
