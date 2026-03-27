#!/bin/bash
# deploy.sh - Helper script for deploying to Render

set -e

echo "??????????????????????????????????????????????????????????????????"
echo "?     SparkleEcommerce Deployment Helper for Render              ?"
echo "??????????????????????????????????????????????????????????????????"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "??  .env file not found. Creating from .env.example..."
    cp .env.example .env
    echo "? Created .env file. Please update it with your database password."
    exit 1
fi

echo "?? Testing Docker build..."
docker build -t sparkle-api:latest . || { echo "? Docker build failed"; exit 1; }
echo "? Docker build successful"

echo ""
echo "?? Checking for sensitive data in code..."
if grep -r "password\|secret\|key" .github/workflows/ 2>/dev/null | grep -v "example"; then
    echo "??  Warning: Found potential hardcoded secrets in workflows"
fi

echo ""
echo "?? Deployment Checklist:"
echo "  ? Repository pushed to GitHub"
echo "  ? Dockerfile created"
echo "  ? Docker image builds successfully"
echo ""
echo "Next Steps for Render Deployment:"
echo "  1. Go to https://dashboard.render.com"
echo "  2. Create new Web Service from GitHub"
echo "  3. Connect to SparkleEcommerce repository"
echo "  4. Set Environment to 'Docker'"
echo "  5. Add environment variables:"
echo "     - ASPNETCORE_ENVIRONMENT=production"
echo "     - ConnectionStrings__DefaultConnection=your_database_url"
echo "  6. Deploy"
echo ""
echo "For local testing with docker-compose:"
echo "  docker-compose up -d"
echo ""
