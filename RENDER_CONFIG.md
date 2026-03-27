# SparkleEcommerce - Render Deployment Configuration

## Summary of Changes

The following files have been created to enable deployment on Render:

### Core Files
| File | Purpose |
|------|---------|
| `Dockerfile` | Multi-stage Docker build for .NET 8 application |
| `docker-compose.yml` | Local development with SQL Server and app services |
| `.dockerignore` | Optimizes Docker build by excluding unnecessary files |
| `.env.example` | Template for environment variables |

### Documentation
| File | Purpose |
|------|---------|
| `DEPLOYMENT.md` | Complete deployment guide for Render |
| `README.md` | Project overview |

### Scripts
| File | Purpose |
|------|---------|
| `deploy.sh` | Bash deployment helper script |
| `Deploy.ps1` | PowerShell deployment helper script |

### CI/CD
| File | Purpose |
|------|---------|
| `.github/workflows/deploy.yml` | GitHub Actions for automated testing and deployment |

---

## Quick Start for Render Deployment

### Step 1: Prepare Your Code
```bash
# Update appsettings for production
# Make sure connection strings use environment variables
# Push to GitHub
git add .
git commit -m "Add deployment configuration for Render"
git push origin main
```

### Step 2: Create Services on Render

**Create Web Service:**
1. Go to https://dashboard.render.com
2. Click "New +" ? "Web Service"
3. Connect your GitHub repository
4. Configure:
   - **Name**: `sparkle-api`
   - **Environment**: `Docker`
   - **Build Command**: (Leave empty, uses Dockerfile)
   - **Start Command**: (Leave empty, uses Dockerfile ENTRYPOINT)
   - **Instance Type**: Free (or paid for production)

**Create PostgreSQL Database** (if using free tier):
1. Click "New +" ? "PostgreSQL"
2. Configure:
   - **Name**: `sparkle-db`
   - **Database**: `sparkledb`
   - **Instance Type**: Free

### Step 3: Set Environment Variables

In your Web Service settings, add:

```
ASPNETCORE_ENVIRONMENT=production
ASPNETCORE_URLS=http://+:5000
ConnectionStrings__DefaultConnection=<your-postgres-connection-string>
```

### Step 4: Deploy

1. Render will automatically deploy when you push to `main`
2. Monitor the build in the Render dashboard
3. Check logs if issues occur

---

## Database Considerations

### Free Tier (PostgreSQL)
- **Best for**: Demo, testing, hobby projects
- **Limitations**: Limited resources, may sleep if no activity
- **Cost**: $0/month
- **Action Required**: Migrate from SQL Server to PostgreSQL

### Production (SQL Server)
- **Option 1**: Use Azure SQL Database (paid)
- **Option 2**: Use AWS RDS for SQL Server (paid)
- **Option 3**: Upgrade to Render paid tier (supports private databases)

---

## Verify Deployment

After deployment, test these endpoints:

```bash
# Health check endpoint (adjust based on your app)
curl https://your-service.onrender.com/health

# Test API endpoints
curl https://your-service.onrender.com/api/your-endpoint
```

---

## Troubleshooting

### Build Fails
- Check build logs in Render dashboard
- Ensure Dockerfile references correct project files
- Verify .NET 8 SDK compatibility

### App Crashes After Deploy
- Check application logs in Render
- Verify database connection string
- Ensure all required environment variables are set

### Slow Performance
- Render free tier has limited resources (0.5 CPU, 512 MB RAM)
- Upgrade to paid instance for production
- Use caching strategies in your application

---

## Local Testing

Test your Docker setup locally:

```bash
# Build and run with Docker Compose
docker-compose up -d

# Access your app at http://localhost:5000

# View logs
docker-compose logs -f sparkle-api

# Stop services
docker-compose down
```

---

## Security Notes

1. **Never commit secrets**: Keep passwords and API keys in `.env` and environment variables
2. **Use .dockerignore**: Prevents sensitive files from being included in Docker image
3. **Set strong SA password**: For SQL Server (if using locally)
4. **Enable HTTPS**: Configure SSL certificates in production
5. **Environment-specific configs**: Use different settings for dev/prod

---

## Useful Commands

```bash
# Build Docker image locally
docker build -t sparkle-api:latest .

# Run Docker image
docker run -p 5000:5000 -e "ASPNETCORE_ENVIRONMENT=Development" sparkle-api:latest

# Check logs
docker logs <container-id>

# Push to GitHub and trigger Render deploy
git push origin main
```

---

## Next Steps

1. ? Update `appsettings.json` to use environment variables
2. ? Test locally with `docker-compose up`
3. ? Push to GitHub
4. ? Create services on Render
5. ? Monitor deployment in Render dashboard
6. ? Test live endpoints
7. ? Set up monitoring and alerts

---

## Support Resources

- Render Documentation: https://render.com/docs
- .NET Docker Docs: https://docs.microsoft.com/en-us/dotnet/architecture/containerized-lifecycle-framework/
- GitHub Actions: https://docs.github.com/en/actions

---

**Last Updated**: 2026-03-27
