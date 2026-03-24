# Database Consolidation and Cleanup Script
# Author: Antigravity
# Purpose: Safely backup all SparkleEcommerce databases and remove obsolete versions.

$server = "localhost\SQLEXPRESS"
$backupDir = "C:\Sparkle_DB_Backups"
$mainDB = "SparkleEcommerce"

# Ensure backup directory exists
if (-not (Test-Path -Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
    Write-Host "Created backup directory: $backupDir" -ForegroundColor Cyan
}

# Get list of databases
$query = "SELECT name FROM sys.databases WHERE name LIKE 'SparkleEcommerce%'"
$databases = sqlcmd -S $server -Q $query -h -1 -W | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }

Write-Host "Found databases: $($databases -join ', ')" -ForegroundColor Yellow

foreach ($db in $databases) {
    if ($db -eq $mainDB) {
        Write-Host "Skipping main database: $db (Active)" -ForegroundColor Green
        continue
    }

    $backupFile = "$backupDir\$db.bak"
    Write-Host "Backing up: $db..." -NoNewline
    
    # Backup Command
    $backupCmd = "BACKUP DATABASE [$db] TO DISK = '$backupFile' WITH FORMAT, INIT, NAME = '$db-Full Database Backup', SKIP, NOREWIND, NOUNLOAD, STATS = 10"
    sqlcmd -S $server -Q $backupCmd | Out-Null
    
    if (Test-Path $backupFile) {
        Write-Host " DONE. Saved to $backupFile" -ForegroundColor Green
        
        Write-Host "Dropping database: $db..." -NoNewline
        # Drop Command (Force close connections)
        $dropCmd = "ALTER DATABASE [$db] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$db];"
        sqlcmd -S $server -Q $dropCmd | Out-Null
        Write-Host " DROPPED." -ForegroundColor Red
    } else {
        Write-Host " FAILED TO BACKUP. Skipping drop for safety." -ForegroundColor Red
    }
}

Write-Host "`nAll operations completed. Only '$mainDB' remains active." -ForegroundColor Cyan
