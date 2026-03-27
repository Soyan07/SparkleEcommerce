# SparkleEcommerce Deployment Guide

## Prerequisites
- GitHub account with repository pushed
- Docker installed (for local testing)
- Hosting platform account (Render, Railway, etc.)

## Database Configuration

**SQL Server Connection:**
- Server: `db45876.databaseasp.net,1433`
- Database: `SparkleEcommerce`
- User: `db45876`
- Password: `22103379`

## Deployment Options

### Option 1: Render (Recommended)

1. **Connect GitHub Repository**
   - Go to [Render Dashboard](https://dashboard.render.com)
   - Click "New +" → "Web Service"
   - Connect your GitHub repository

2. **Configure Service**
   - Name: `sparkle-ecommerce`
   - Region: Oregon (or closest to you)
   - Branch: `main`
   - Runtime: Docker
   - Plan: Starter ($7/month)

3. **Set Environment Variables**
   - Click "Environment" tab
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
   - Click "Create Web Service"
   - Wait for deployment to complete

### Option 2: Railway

1. **Create Project**
   - Go to [Railway](https://railway.app)
   - Create new project
   - Connect GitHub repository

2. **Add Variables**
   - Go to Variables section
   - Add all environment variables from above

3. **Deploy**
   - Railway will auto-detect Dockerfile
   - Deploy will start automatically

### Option 3: Local Docker

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
