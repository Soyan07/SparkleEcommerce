# Deploy.ps1 - Helper script for deploying to Render

Write-Host "??????????????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "?     SparkleEcommerce Deployment Helper for Render              ?" -ForegroundColor Cyan
Write-Host "??????????????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

# Check if .env file exists
if (-not (Test-Path ".env")) {
    Write-Host "??  .env file not found. Creating from .env.example..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "? Created .env file. Please update it with your secure password." -ForegroundColor Green
    exit 1
}

Write-Host "?? Testing Docker build..." -ForegroundColor Yellow
docker build -t sparkle-api:latest .
if ($LASTEXITCODE -ne 0) {
    Write-Host "? Docker build failed" -ForegroundColor Red
    exit 1
}
Write-Host "? Docker build successful" -ForegroundColor Green

Write-Host ""
Write-Host "?? Checking project structure..." -ForegroundColor Yellow

$projects = @(
    "Sparkle.Api/Sparkle.Api.csproj",
    "Sparkle.Domain/Sparkle.Domain.csproj",
    "Sparkle.Infrastructure/Sparkle.Infrastructure.csproj"
)

foreach ($project in $projects) {
    if (Test-Path $project) {
        Write-Host "  ? Found: $project" -ForegroundColor Green
    } else {
        Write-Host "  ? Missing: $project" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "?? Deployment Checklist:" -ForegroundColor Cyan
Write-Host "  ? Repository ready for GitHub" -ForegroundColor Green
Write-Host "  ? Dockerfile created" -ForegroundColor Green
Write-Host "  ? Docker image builds successfully" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps for Render Deployment:" -ForegroundColor Yellow
Write-Host "  1. Push to GitHub: git push origin main"
Write-Host "  2. Go to https://dashboard.render.com"
Write-Host "  3. Create new Web Service from GitHub"
Write-Host "  4. Connect to SparkleEcommerce repository"
Write-Host "  5. Set Environment to 'Docker'"
Write-Host "  6. Add environment variables:"
Write-Host "     - ASPNETCORE_ENVIRONMENT=production"
Write-Host "     - ConnectionStrings__DefaultConnection=your_database_url"
Write-Host "  7. Deploy"
Write-Host ""
Write-Host "For local testing with docker-compose:" -ForegroundColor Cyan
Write-Host "  docker-compose up -d" -ForegroundColor Gray
Write-Host ""
