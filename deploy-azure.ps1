# ============================================================
# Sparkle Ecommerce - Azure Free Tier Deployment Script
# ============================================================
# Prerequisites:
#   1. Azure CLI installed: https://aka.ms/installazurecliwindows
#   2. Run: az login
#   3. Run this script: .\deploy-azure.ps1
#
# Free Tier Limits (F1):
#   - App Service: 1 GB RAM, 60 min compute/day, 1 GB storage
#   - SQL Database: 100,000 vCore seconds/month free
#   - No custom domain on free tier (uses azurewebsites.net)
# ============================================================

param(
    [string]$ResourceGroup = "sparkle-rg",
    [string]$Location = "southeastasia",
    [string]$AppName = "sparkle-ecommerce-$(Get-Random -Maximum 9999)",
    [string]$SqlServerName = "sparkle-sql-$(Get-Random -Maximum 9999)",
    [string]$SqlAdmin = "sparkleadmin",
    [string]$SqlPassword = "Sparkle@Secure123!",
    [string]$DatabaseName = "SparkleEcommerce"
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  Sparkle Ecommerce - Azure Free Tier Deployment" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Resource Group : $ResourceGroup"
Write-Host "  Location       : $Location"
Write-Host "  App Name       : $AppName"
Write-Host "  SQL Server     : $SqlServerName"
Write-Host "  Database       : $DatabaseName"
Write-Host "========================================================"
Write-Host ""

# Check Azure CLI login
$account = az account show 2>$null | ConvertFrom-Json
if (-not $account) {
    Write-Host "ERROR: Not logged in. Run 'az login' first." -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Logged in as: $($account.user.name)" -ForegroundColor Green

# 1. Create Resource Group
Write-Host "`n[1/6] Creating Resource Group..." -ForegroundColor Yellow
az group create --name $ResourceGroup --location $Location --output none
Write-Host "[OK] Resource group created." -ForegroundColor Green

# 2. Create Azure SQL Server (Free tier eligible)
Write-Host "`n[2/6] Creating Azure SQL Server..." -ForegroundColor Yellow
az sql server create `
    --name $SqlServerName `
    --resource-group $ResourceGroup `
    --location $Location `
    --admin-user $SqlAdmin `
    --admin-password $SqlPassword `
    --output none

# Allow Azure services (App Service) to connect
az sql server firewall-rule create `
    --resource-group $ResourceGroup `
    --server $SqlServerName `
    --name "AllowAzureServices" `
    --start-ip-address 0.0.0.0 `
    --end-ip-address 0.0.0.0 `
    --output none

# Allow all IPs for initial setup (remove after deployment)
az sql server firewall-rule create `
    --resource-group $ResourceGroup `
    --server $SqlServerName `
    --name "AllowAll" `
    --start-ip-address 0.0.0.0 `
    --end-ip-address 255.255.255.255 `
    --output none

Write-Host "[OK] SQL Server created." -ForegroundColor Green

# 3. Create SQL Database (Free tier: Basic DTU, 5 DTUs, 2GB)
Write-Host "`n[3/6] Creating SQL Database (Basic - Free Tier)..." -ForegroundColor Yellow
az sql db create `
    --resource-group $ResourceGroup `
    --server $SqlServerName `
    --name $DatabaseName `
    --edition Basic `
    --capacity 5 `
    --max-size 2GB `
    --output none

Write-Host "[OK] Database created (Basic, 2GB max)." -ForegroundColor Green

# 4. Create App Service Plan (F1 Free)
Write-Host "`n[4/6] Creating App Service Plan (F1 Free)..." -ForegroundColor Yellow
az appservice plan create `
    --name "$AppName-plan" `
    --resource-group $ResourceGroup `
    --sku F1 `
    --is-linux false `
    --output none

Write-Host "[OK] App Service Plan created (F1 Free)." -ForegroundColor Green

# 5. Create Web App
Write-Host "`n[5/6] Creating Web App..." -ForegroundColor Yellow
az webapp create `
    --name $AppName `
    --resource-group $ResourceGroup `
    --plan "$AppName-plan" `
    --runtime "DOTNETCORE:8.0" `
    --output none

# Configure connection string
$ConnectionString = "Server=tcp:$SqlServerName.database.windows.net,1433;Database=$DatabaseName;User ID=$SqlAdmin;Password=$SqlPassword;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;MultipleActiveResultSets=true;"

az webapp config connection-string set `
    --resource-group $ResourceGroup `
    --name $AppName `
    --connection-string-type SQLAzure `
    --settings DefaultConnection="$ConnectionString" `
    --output none

# Configure app settings
$JwtKey = [System.Guid]::NewGuid().ToString() + "-Sparkle-JWT-2024"
az webapp config appsettings set `
    --resource-group $ResourceGroup `
    --name $AppName `
    --settings `
        "DOTNET_ENVIRONMENT=Production" `
        "PORT=8080" `
        "App__BaseUrl=https://$AppName.azurewebsites.net" `
        "Jwt__Issuer=Sparkle" `
        "Jwt__Audience=SparkleClient" `
        "Jwt__Key=$JwtKey" `
    --output none

# Enable HTTPS only
az webapp update `
    --resource-group $ResourceGroup `
    --name $AppName `
    --set httpsOnly=true `
    --output none

Write-Host "[OK] Web App configured." -ForegroundColor Green

# 6. Deploy from local project
Write-Host "`n[6/6] Deploying application..." -ForegroundColor Yellow

# Publish locally first
Write-Host "  Publishing project..."
dotnet publish Sparkle.Api/Sparkle.Api.csproj -c Release -o ./publish --nologo -v quiet

# Create zip for deployment
Write-Host "  Creating deployment package..."
if (Test-Path "./deploy.zip") { Remove-Item "./deploy.zip" }
Compress-Archive -Path "./publish/*" -DestinationPath "./deploy.zip" -Force

# Deploy using az webapp deploy
Write-Host "  Uploading to Azure..."
az webapp deploy `
    --resource-group $ResourceGroup `
    --name $AppName `
    --src-path "./deploy.zip" `
    --type zip `
    --output none

# Cleanup
Remove-Item -Recurse -Force "./publish" -ErrorAction SilentlyContinue
Remove-Item "./deploy.zip" -ErrorAction SilentlyContinue

Write-Host "[OK] Application deployed!" -ForegroundColor Green

# Remove the AllowAll firewall rule for security
az sql server firewall-rule delete `
    --resource-group $ResourceGroup `
    --server $SqlServerName `
    --name "AllowAll" `
    --output none 2>$null

# Summary
Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "  DEPLOYMENT COMPLETE!" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  App URL    : https://$AppName.azurewebsites.net" -ForegroundColor Cyan
Write-Host "  Swagger    : https://$AppName.azurewebsites.net/api-docs" -ForegroundColor Cyan
Write-Host "  Health     : https://$AppName.azurewebsites.net/health" -ForegroundColor Cyan
Write-Host "  SQL Server : $SqlServerName.database.windows.net" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Admin Login:" -ForegroundColor Yellow
Write-Host "    Email    : admin@sparkle.local" -ForegroundColor White
Write-Host "    Password : Admin@123" -ForegroundColor White
Write-Host ""
Write-Host "  NOTE: First load may take 30-60s (cold start + seeding)." -ForegroundColor Yellow
Write-Host "  Free tier: 60 min compute/day, 1 GB RAM." -ForegroundColor Yellow
Write-Host ""
Write-Host "  To clean up: az group delete --name $ResourceGroup --yes" -ForegroundColor Gray
Write-Host "========================================================" -ForegroundColor Green
