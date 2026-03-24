# Security Best Practices for Sparkle Ecommerce

## Overview

This document outlines security best practices for deploying and maintaining the Sparkle Ecommerce application in production environments.

---

## 1. Secret Management

### ⚠️ CRITICAL: Never Commit Secrets to Version Control

**Current Development Setup:**
- `appsettings.json` contains development credentials
- JWT secret key is a placeholder
- Google OAuth credentials are in plain text

**Production Requirements:**

#### Option A: User Secrets (Development Only)
```powershell
# Store secrets locally for development
dotnet user-secrets init --project Sparkle.Api
dotnet user-secrets set "Jwt:Key" "your-long-random-secret-key-here" --project Sparkle.Api
dotnet user-secrets set "Google:ClientId" "your-google-client-id" --project Sparkle.Api
dotnet user-secrets set "Google:ClientSecret" "your-google-client-secret" --project Sparkle.Api
```

#### Option B: Environment Variables (Production)
Set these environment variables on your production server:
- `DB_CONNECTION_STRING`: SQL Server connection string
- `JWT_SECRET_KEY`: Strong random key (min 32 characters)
- `JWT_ISSUER`: Your application domain
- `JWT_AUDIENCE`: Your client application identifier
- `GOOGLE_CLIENT_ID`: Google OAuth client ID
- `GOOGLE_CLIENT_SECRET`: Google OAuth client secret

#### Option C: Azure Key Vault (Recommended for Production)
```csharp
// In Program.cs, add before building the app:
if (builder.Environment.IsProduction())
{
    var keyVaultUrl = builder.Configuration["KeyVaultUrl"];
    var credential = new DefaultAzureCredential();
    builder.Configuration.AddAzureKeyVault(new Uri(keyVaultUrl), credential);
}
```

---

## 2. Connection Strings

### Development
Current setup uses Integrated Security which works for local SQL Server.

### Production Options

#### SQL Authentication
```json
"DefaultConnection": "Data Source=your-server.database.windows.net;Initial Catalog=SparkleEcommerce;User ID=sa;Password=${DB_PASSWORD};TrustServerCertificate=False;Encrypt=True"
```

#### Azure SQL Database
```json
"DefaultConnection": "Server=tcp:your-server.database.windows.net,1433;Database=SparkleEcommerce;User ID=your-admin;Password=${DB_PASSWORD};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
```

---

## 3. JWT Configuration

### Generate Strong Secret Key
```powershell
# PowerShell: Generate a secure random key
$bytes = New-Object byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($bytes)
[Convert]::ToBase64String($bytes)
```

### Best Practices
- **Key Length**: Minimum 256 bits (32 bytes)
- **Access Token Expiry**: 60 minutes (current)
- **Refresh Token Expiry**: 7 days (current)
- **Algorithm**: HS256 (current implementation)

---

## 4. Google OAuth Security

### Setup Instructions
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google+ API
4. Configure OAuth consent screen
5. Create OAuth 2.0 credentials
6. Add authorized redirect URIs:
   - `https://yourdomain.com/signin-google`
   - `https://localhost:5279/signin-google` (development)

### Security Checklist
- ✅ Never commit client secret to Git
- ✅ Restrict authorized domains
- ✅ Enable only necessary scopes (profile, email)
- ✅ Monitor OAuth usage in Google Console

---

## 5. Redis Security

### Development
Current setup: No authentication (localhost only)

### Production
```csharp
builder.Services.AddStackExchangeRedisCache(options =>
{
    options.Configuration = "your-redis-server:6379,password=your-redis-password,ssl=true";
    options.InstanceName = "Sparkle_";
});
```

### Security Checklist
- ✅ Enable password authentication
- ✅ Use SSL/TLS in production
- ✅ Restrict network access to trusted servers
- ✅ Regularly update Redis version

---

## 6. HTTPS Enforcement

### Current Setup
- Development: HTTPS optional
- Production: HTTPS redirect enabled (line 447 in Program.cs)

### Additional Security Headers
Add to `Program.cs` before `app.Run()`:

```csharp
if (!app.Environment.IsDevelopment())
{
    app.Use(async (context, next) =>
    {
        context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
        context.Response.Headers.Add("X-Frame-Options", "DENY");
        context.Response.Headers.Add("X-XSS-Protection", "1; mode=block");
        context.Response.Headers.Add("Referrer-Policy", "no-referrer");
        context.Response.Headers.Add("Content-Security-Policy", 
            "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'");
        await next();
    });
}
```

---

## 7. Database Security

### Entity Framework
- ✅ Parameterized queries (automatic with EF Core)
- ✅ No raw SQL concatenation
- ✅ Proper input validation

### SQL Server Recommendations
- Enable encryption at rest
- Use strong SA password
- Restrict database user permissions
- Regular security patches
- Enable auditing for sensitive operations

---

## 8. Authentication Security

### Password Requirements (Current)
```csharp
options.Password.RequireDigit = false;           // ⚠️ Consider enabling
options.Password.RequireLowercase = false;       // ⚠️ Consider enabling
options.Password.RequireUppercase = false;       // ⚠️ Consider enabling
options.Password.RequireNonAlphanumeric = false; // ⚠️ Consider enabling
options.Password.RequiredLength = 4;             // ⚠️ Increase to 8
```

### Recommended Production Settings
```csharp
options.Password.RequireDigit = true;
options.Password.RequireLowercase = true;
options.Password.RequireUppercase = true;
options.Password.RequireNonAlphanumeric = true;
options.Password.RequiredLength = 8;
options.Lockout.MaxFailedAccessAttempts = 5;
options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(15);
```

---

## 9. Session Security

### Current Configuration
```csharp
options.Cookie.HttpOnly = true;        // ✅ Good
options.Cookie.IsEssential = true;     // ✅ Good
options.IdleTimeout = TimeSpan.FromMinutes(30);  // ✅ Reasonable
```

### Additional Recommendations
```csharp
options.Cookie.SecurePolicy = CookieSecurePolicy.Always; // HTTPS only in production
options.Cookie.SameSite = SameSiteMode.Strict;
```

---

## 10. Deployment Checklist

### Before Going Live
- [ ] Replace JWT secret key with strong random value
- [ ] Move all secrets to environment variables or Key Vault
- [ ] Enable HTTPS enforcement
- [ ] Configure security headers
- [ ] Set up database backup strategy
- [ ] Enable application logging and monitoring
- [ ] Configure Redis authentication
- [ ] Review and update password requirements
- [ ] Set up rate limiting for APIs
- [ ] Configure CORS properly
- [ ] Enable Application Insights or equivalent
- [ ] Test disaster recovery procedures

---

## 11. Monitoring & Incident Response

### Recommended Tools
- **Application Insights**: Performance and error tracking
- **Azure Monitor**: Infrastructure monitoring
- **Serilog**: Structured logging
- **Health Checks**: Endpoint monitoring

### Logging Best Practices
- ✅ Log authentication failures
- ✅ Log authorization violations
- ✅ Log data access patterns
- ⚠️ Never log sensitive data (passwords, tokens, credit cards)

---

## 12. Regular Maintenance

### Weekly
- Review authentication logs
- Check for failed login attempts
- Monitor application performance

### Monthly
- Update NuGet packages
- Review security advisories
- Update SSL certificates if needed

### Quarterly
- Review access controls
- Audit user permissions
- Penetration testing

---

## Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [ASP.NET Core Security Best Practices](https://docs.microsoft.com/en-us/aspnet/core/security/)
- [Azure Security Best Practices](https://docs.microsoft.com/en-us/azure/security/fundamentals/best-practices-and-patterns)

---

**Last Updated**: December 8, 2025  
**Version**: 1.0
