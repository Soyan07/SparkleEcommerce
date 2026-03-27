# SparkleEcommerce Deployment Guide

## Railway Deployment

### 1. Create Project
1. Go to [Railway](https://railway.app)
2. Sign up with GitHub
3. Click "New Project" → "Deploy from GitHub repo"
4. Select `SparkleEcommerce` repository

### 2. Set Environment Variables
1. Go to your project → **Variables** tab
2. Add these variables:

```
ASPNETCORE_ENVIRONMENT=Production
ASPNETCORE_URLS=http://+:5000
ConnectionStrings__DefaultConnection=Server=db45876.databaseasp.net,1433;Database=SparkleEcommerce;User Id=db45876;Password=22103379;TrustServerCertificate=True;MultipleActiveResultSets=true;Encrypt=False;Command Timeout=180;Connect Timeout=60
JWT__Key=YourSecureJWTSecretKeyAtLeast32Characters!
JWT__Issuer=Sparkle
JWT__Audience=SparkleClient
```

### 3. Deploy
- Railway auto-detects Dockerfile
- Deployment starts automatically
- Get URL from **Settings** → **Networking** → **Public Networking**

## Test Accounts
- **Admin:** `admin@sparkle.local` / `Admin@123`
- **User:** `user@sparkle.local` / `User@123`

## Troubleshooting

### Database Connection Error
- Verify SQL Server credentials are correct
- Check if database server allows external connections

### Build Failed
- Check Dockerfile syntax
- Verify .NET 8 SDK compatibility

### Application Not Loading
- Check logs in Railway dashboard
- Verify environment variables are set correctly
