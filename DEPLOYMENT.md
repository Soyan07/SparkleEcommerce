# SparkleEcommerce Deployment Guide

## Prerequisites
- GitHub account with repository pushed
- Docker installed (for local testing)
- Railway account (https://railway.app)

## Database Configuration

**SQL Server Connection:**
- Server: `db45876.databaseasp.net,1433`
- Database: `SparkleEcommerce`
- User: `db45876`
- Password: `22103379`

## Deployment Options

### Option 1: Railway (Recommended)

1. **Create Project**
   - Go to [Railway](https://railway.app)
   - Sign up/login with GitHub
   - Click "New Project" → "Deploy from GitHub repo"
   - Select your repository

2. **Configure Deployment**
   - Railway auto-detects Dockerfile
   - Add environment variables

3. **Set Environment Variables**
   - Go to your project → Variables
   - Add these variables:

   ```env
   ASPNETCORE_ENVIRONMENT=Production
   ASPNETCORE_URLS=http://+:5000
   ConnectionStrings__DefaultConnection=Server=db45876.databaseasp.net,1433;Database=SparkleEcommerce;User Id=db45876;Password=22103379;TrustServerCertificate=True;MultipleActiveResultSets=true;Encrypt=False;Command Timeout=180;Connect Timeout=60
   JWT__Key=YourSecureRandomKeyAtLeast32Characters!
   JWT__Issuer=Sparkle
   JWT__Audience=SparkleClient
   ```

4. **Deploy**
   - Railway will auto-deploy
   - Get URL from deployment settings

### Option 2: Azure App Service

1. **Create Web App**
   - Go to [Azure Portal](https://portal.azure.com)
   - Create Web App → Docker Container
   - Configure with Dockerfile from GitHub

2. **Set Environment Variables**
   - Application settings → Advanced
   - Add all environment variables

### Option 3: DigitalOcean App Platform

1. **Create App**
   - Go to [DigitalOcean](https://www.digitalocean.com)
   - Create App → GitHub
   - Configure with Dockerfile

2. **Add Environment Variables**
   - App Settings → Environment Variables
   - Add all variables

### Option 4: Local Docker

```bash
# Build and run locally
docker-compose up -d

# Access at http://localhost:5000
```

## Test Accounts

- **Admin:** `admin@sparkle.local` / `Admin@123`
- **User:** `user@sparkle.local` / `User@123`

## Troubleshooting

### Database Connection Error
- Verify SQL Server credentials
- Check firewall settings
- Ensure database exists

### Build Failed
- Check Dockerfile syntax
- Verify .NET 8 SDK compatibility
- Check NuGet package restore

### Application Not Loading
- Check logs in hosting dashboard
- Verify environment variables are set
- Test database connection
