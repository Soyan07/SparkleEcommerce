# SparkleEcommerce Deployment Guide for Render

## Prerequisites

1. GitHub account with your repository pushed
2. Render account (https://render.com) - free tier available
3. Docker installed locally (for testing)

## Important Note: SQL Server on Render

Render's **free tier does NOT support SQL Server**. Options:

### Option 1: Use PostgreSQL (Recommended for Free Tier)
- Easiest deployment on Render free tier
- Requires updating your connection string and EF Core provider
- Best for free hosting

### Option 2: Use External SQL Server
- Keep SQL Server in Azure or AWS RDS (paid, but affordable)
- Better for production-grade applications

### Option 3: Use Render's Paid Tier
- Render supports private databases on paid plans
- More expensive option

---

## Recommended: Deploy with PostgreSQL on Render

### Step 1: Prepare Your Application for PostgreSQL

You'll need to update your `Sparkle.Infrastructure` project to use PostgreSQL instead of SQL Server.

**In your `Sparkle.Infrastructure.csproj`, replace:**
```xml
<!-- Remove SQL Server package -->
<!-- Add PostgreSQL package -->
<PackageReference Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="8.0.0" />
```

**In your DbContext configuration (appsettings.json), update connection string format:**
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=your-render-db.onrender.com;Database=sparkledb;Username=postgres;Password=yourpassword"
  }
}
```

### Step 2: Deploy to Render

1. **Push your code to GitHub**
   ```bash
   git add .
   git commit -m "Add Dockerfile and deployment configs for Render"
   git push origin main
   ```

2. **Create a new Web Service on Render**
   - Go to https://dashboard.render.com
   - Click "New +" ? "Web Service"
   - Connect your GitHub repository
   - Select `SparkleEcommerce` repository
   - Set Environment to "Docker"
   - Free plan is available

3. **Create PostgreSQL Database on Render**
   - Click "New +" ? "PostgreSQL"
   - Choose free tier
   - Copy the database connection string
   - Add to Web Service environment variables

4. **Set Environment Variables in Render**
   - `ASPNETCORE_ENVIRONMENT`: `Production`
   - `ASPNETCORE_URLS`: `http://+:5000`
   - `ConnectionStrings__DefaultConnection`: Your PostgreSQL connection string

5. **Deploy**
   - Render will automatically build and deploy when you push to main

---

## Alternative: Local Docker Testing

Test your Dockerfile locally before deploying to Render:

```bash
# Build image
docker build -t sparkle-api .

# Run with docker-compose (includes SQL Server for local testing)
docker-compose up -d

# Application will be available at http://localhost:5000
```

To stop:
```bash
docker-compose down
```

---

## Render Deployment Quick Checklist

- [ ] Repository pushed to GitHub
- [ ] Dockerfile in root directory
- [ ] appsettings.json configured for your database
- [ ] Environment variables set in Render dashboard
- [ ] Health check endpoint available (or modify healthCheckPath)
- [ ] No hardcoded secrets in code

---

## Troubleshooting

### "Build Failed" on Render
- Check build logs in Render dashboard
- Ensure all NuGet packages restore correctly
- Verify .NET 8 SDK is compatible

### "Connection to Database Failed"
- Verify connection string format for PostgreSQL
- Check database credentials in Render
- Ensure firewall allows connections

### Application Crashes After Deploy
- Check Render logs: Dashboard ? Select Service ? Logs
- Common issue: Wrong connection string format
- Make sure `ASPNETCORE_ENVIRONMENT` is set

---

## Cost Estimates

- **Render Free Tier**: $0/month (limited resources)
  - 0.5 CPU, 512 MB RAM
  - Free PostgreSQL database (limited)
  - Good for testing/demo

- **Small Instance + DB**: ~$10-20/month
  - Recommended for production use

---

## Next Steps

1. Update your application for PostgreSQL (if using free tier)
2. Test locally with docker-compose
3. Deploy to Render
4. Monitor logs and performance
5. Set up CI/CD for automatic deployments

For questions, check Render documentation: https://render.com/docs
