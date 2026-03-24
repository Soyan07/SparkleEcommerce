using Microsoft.Data.SqlClient;

// Simple tool to execute the chat tables SQL script
var connectionString = "Server=.\\SQLEXPRESS;Database=SparkleEcommerce;Trusted_Connection=True;TrustServerCertificate=True;";
var sqlScript = File.ReadAllText("create_chat_tables.sql");

Console.WriteLine("Executing Chat Tables SQL Script...");
Console.WriteLine("=====================================");

try
{
    using var connection = new SqlConnection(connectionString);
    await connection.OpenAsync();
    Console.WriteLine("✓ Connected to database");
    
    // Split by GO statements
    var batches = sqlScript.Split(new[] { "\r\nGO\r\n", "\nGO\n", "\r\nGO", "\nGO" }, StringSplitOptions.RemoveEmptyEntries);
    
    foreach (var batch in batches.Where(b => !string.IsNullOrWhiteSpace(b)))
    {
        using var command = new SqlCommand(batch.Trim(), connection);
        command.CommandTimeout = 60;
        await command.ExecuteNonQueryAsync();
    }
    
    Console.WriteLine("✓ All SQL batches executed successfully");
    Console.WriteLine("\n✓ Chat system tables created!");
    return 0;
}
catch (Exception ex)
{
    Console.WriteLine($"\n✗ Error: {ex.Message}");
    return 1;
}
