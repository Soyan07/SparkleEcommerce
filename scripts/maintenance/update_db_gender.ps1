$connString = "Server=localhost\SQLEXPRESS;Database=SparkleEcommerce;Integrated Security=True;TrustServerCertificate=True;Connection Timeout=30"

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection $connString
    $conn.Open()
    
    $cmd = $conn.CreateCommand()
    $cmd.CommandText = "IF COL_LENGTH('dbo.AspNetUsers', 'Gender') IS NULL BEGIN ALTER TABLE [dbo].[AspNetUsers] ADD [Gender] nvarchar(max) NULL; PRINT 'Column added'; END ELSE BEGIN PRINT 'Column already exists'; END"
    
    $result = $cmd.ExecuteNonQuery()
    Write-Host "Command executed successfully."
    $conn.Close()
} catch {
    Write-Host "Error: $_" -ForegroundColor Red
    if ($_.Exception.Message -like "*Invalid object name*") {
        Write-Host "Retrying with 'users' schema..."
        try {
             $conn = New-Object System.Data.SqlClient.SqlConnection $connString
             $conn.Open()
             $cmd = $conn.CreateCommand()
             $cmd.CommandText = "IF COL_LENGTH('users.AspNetUsers', 'Gender') IS NULL BEGIN ALTER TABLE [users].[AspNetUsers] ADD [Gender] nvarchar(max) NULL; PRINT 'Column added to users schema'; END"
             $cmd.ExecuteNonQuery()
             Write-Host "Command executed successfully on users schema."
             $conn.Close()
        } catch {
             Write-Host "Failed on users schema too: $_" -ForegroundColor Red
        }
    }
}
