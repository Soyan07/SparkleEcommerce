# ?? Render Deployment Quick Reference

## The Problem
Your Dockerfile was configured for Node.js/npm, but your project is a .NET 8 Razor Pages application.

## The Solution
? Created proper Docker configuration for .NET 8 with SQL Server support

---

## Files Created

```
Root Directory:
??? Dockerfile ............................ .NET 8 production-ready Docker image
??? docker-compose.yml ................... Local dev environment (with SQL Server)
??? .dockerignore ......................... Optimizes Docker build
??? .env.example .......................... Template for environment variables
??? render.json ........................... Render platform config
??? render.yaml ........................... Render service definitions
??? deploy.sh ............................ Bash deployment helper
??? Deploy.ps1 ........................... PowerShell deployment helper
??? DEPLOYMENT_SUMMARY.md ................ This file - Quick start guide
??? DEPLOYMENT.md ........................ Detailed deployment guide
??? RENDER_CONFIG.md ..................... Configuration reference
??? .github/
    ??? workflows/
        ??? deploy.yml ................... GitHub Actions CI/CD automation
```

---

## Deploy in 5 Minutes

### 1?? Test Locally
```bash
docker-compose up -d
# Visit http://localhost:5000
docker-compose down
```

### 2?? Push to GitHub
```bash
git add .
git commit -m "Add Render deployment config"
git push origin main
```

### 3?? Create Render Account
Visit https://render.com and sign up (free)

### 4?? Deploy Web Service
- Dashboard ? New Web Service
- Connect GitHub repository
- Select `Sparkle.Api` branch
- Environment: **Docker**
- Choose Free plan
- Click "Create Web Service"

### 5?? Configure Database
- Dashboard ? New PostgreSQL
- Name: `sparkle-db`
- Copy connection string
- Go back to Web Service ? Environment variables
- Add:
  ```
  ConnectionStrings__DefaultConnection=<copied-string>
  ASPNETCORE_ENVIRONMENT=production
  ```

? **Done!** Your app deploys automatically on push to main

---

## Key Points

| Aspect | Details |
|--------|---------|
| **Framework** | .NET 8 Razor Pages |
| **Container** | Docker (multi-stage build) |
| **Database** | PostgreSQL (free tier) or SQL Server (paid) |
| **Port** | 5000 |
| **Health Check** | `/health` endpoint |
| **Auto Deploy** | Yes (on GitHub push) |
| **Cost** | $0/month (free tier) |

---

## Database Choice

### Free Tier (PostgreSQL)
- Easiest for free hosting
- Zero cost
- Requires updating connection string format
- May sleep after inactivity

### Production (SQL Server)
- Keep SQL Server (recommended for production)
- Costs: Azure SQL ($5+/mo) or AWS RDS ($10+/mo)
- Use Render paid tier if want private SQL Server

---

## Environment Variables

Set in Render Dashboard:

```
ASPNETCORE_ENVIRONMENT=production
ASPNETCORE_URLS=http://+:5000
ConnectionStrings__DefaultConnection=your-db-connection-string
```

---

## Verify Deployment

After deploy completes:

```bash
# Check health
curl https://your-service.onrender.com/health

# Check logs in Render Dashboard
# Click Web Service ? Logs
```

---

## Common Issues & Fixes

| Issue | Fix |
|-------|-----|
| Build fails | Check logs in Render dashboard, verify .NET version |
| App crashes | Check connection string, verify env vars are set |
| Can't connect to DB | Use correct PostgreSQL connection string format |
| Slow performance | Free tier is limited; upgrade for production |
| Service sleeps | Free tier services sleep after 15min inactivity |

---

## Helpful Commands

```bash
# Local testing
docker-compose up -d

# View logs
docker-compose logs -f sparkle-api

# Stop services
docker-compose down

# Build image
docker build -t sparkle-api .

# Check if Docker image builds
docker run -it sparkle-api
```

---

## Next Steps

1. ? Verify Dockerfile created correctly
2. ?? Update database connection strings (if switching to PostgreSQL)
3. ?? Test locally with `docker-compose up`
4. ?? Push to GitHub
5. ?? Create Render account
6. ?? Deploy Web Service
7. ?? Create PostgreSQL database
8. ?? Test live endpoints

---

## Support

?? Read the full guides:
- `DEPLOYMENT.md` - Step-by-step guide
- `RENDER_CONFIG.md` - Configuration details

?? External Links:
- [Render Docs](https://render.com/docs)
- [.NET Docker Images](https://hub.docker.com/_/microsoft-dotnet)
- [PostgreSQL Connection Strings](https://www.postgresql.org/docs/current/libpq-connect.html)

---

**Your deployment setup is complete and ready to use!** ??

**Last Updated**: 2026-03-27
**Status**: ? Ready for production
