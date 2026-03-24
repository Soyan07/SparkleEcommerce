# Performance Optimization Guide

## Overview

This document provides performance optimization guidelines for the Sparkle Ecommerce application to ensure fast, scalable operation in production.

---

## Current Performance Features ✅

### 1. Response Compression
- **Brotli** and **Gzip** compression enabled
- Configured for HTTPS
- Compression level: Fastest (good balance)

### 2. Static File Caching
- 7-day cache duration
- Cache-Control headers properly set
- Reduces server load and bandwidth

### 3. Redis Caching
- Distributed cache for settings
- SignalR backplane for scaling
- 30-minute cache duration for site settings
- Graceful fallback to in-memory cache

### 4. Response Caching
- Middleware enabled
- Ready for `[ResponseCache]` attributes on controllers

### 5. Database Optimization
- Connection pooling (automatic with EF Core)
- 180-second command timeout for long-running queries
- AsNoTracking() queries for read-only data

---

## Recommended Optimizations

### 1. Database Indexing

#### High Priority Indexes

Add these indexes to improve query performance:

```sql
-- Products table indexes
CREATE NONCLUSTERED INDEX IX_Products_CategoryId_IsActive 
ON [catalog].[Products] (CategoryId, IsActive) INCLUDE (Title, BasePrice, DiscountPercent);

CREATE NONCLUSTERED INDEX IX_Products_SellerId_IsActive 
ON [catalog].[Products] (SellerId, IsActive);

CREATE NONCLUSTERED INDEX IX_Products_Slug 
ON [catalog].[Products] (Slug) WHERE IsActive = 1;

CREATE NONCLUSTERED INDEX IX_Products_Search 
ON [catalog].[Products] (Title, Description) WHERE IsActive = 1;

-- Orders table indexes
CREATE NONCLUSTERED INDEX IX_Orders_UserId_OrderDate 
ON [orders].[Orders] (UserId, OrderDate DESC);

CREATE NONCLUSTERED INDEX IX_Orders_Status 
ON [orders].[Orders] (Status) INCLUDE (OrderDate, TotalAmount);

-- ProductImages table index
CREATE NONCLUSTERED INDEX IX_ProductImages_ProductId_SortOrder 
ON [catalog].[ProductImages] (ProductId, SortOrder);

-- Reviews index
CREATE NONCLUSTERED INDEX IX_ProductReviews_ProductId_IsApproved 
ON [catalog].[ProductReviews] (ProductId, IsApproved) INCLUDE (Rating, CreatedAt);
```

### 2. Output Caching

Add to frequently accessed pages:

```csharp
// In HomeController.cs
[ResponseCache(Duration = 300, Location = ResponseCacheLocation.Any, VaryByHeader = "User-Agent")]
public async Task<IActionResult> Index()
{
    // ... existing code
}

// For product pages (5 minute cache)
[ResponseCache(Duration = 300, VaryByQueryKeys = new[] { "slug" })]
public async Task<IActionResult> Product(string slug)
{
    // ... existing code
}
```

### 3. Query Optimization

```csharp
// Use AsNoTracking for read-only queries
var products = await _db.Products
    .AsNoTracking()
    .Include(p => p.Images.OrderBy(i => i.SortOrder).Take(1))
    .Where(p => p.IsActive)
    .ToListAsync();

// Use Select to project only needed columns
var productList = await _db.Products
    .Where(p => p.IsActive)
    .Select(p => new {
        p.Id,
        p.Title,
        p.BasePrice,
        FirstImage = p.Images.OrderBy(i => i.SortOrder).FirstOrDefault().Url
    })
    .ToListAsync();
```

### 4. Lazy Loading Images

Update views to use lazy loading:

```html
<!-- Add loading="lazy" to images -->
<img src="@imageUrl" 
     alt="@product.Title" 
     loading="lazy" 
     class="card-img-top" />
```

### 5. CDN for Static Assets

In production, serve static files from CDN:

```csharp
// In Program.cs
app.UseStaticFiles(new StaticFileOptions
{
    OnPrepareResponse = ctx =>
    {
        const int durationInSeconds = 60 * 60 * 24 * 365; // 1 year for CDN
        ctx.Context.Response.Headers.Append("Cache-Control", $"public,max-age={durationInSeconds}");
        ctx.Context.Response.Headers.Append("Expires", 
            DateTime.UtcNow.AddYears(1).ToString("R"));
    }
});
```

### 6. Database Connection String Optimization

Update connection string for production:

```
Data Source=server;Initial Catalog=SparkleEcommerce;
User ID=user;Password=pass;
TrustServerCertificate=False;
Encrypt=True;
Min Pool Size=5;
Max Pool Size=100;
Pooling=true;
Connect Timeout=30;
Command Timeout=180;
```

### 7. SignalR Optimization

For high-traffic scenarios:

```csharp
builder.Services.AddSignalR(options =>
{
    options.EnableDetailedErrors = false; // Disable in production
    options.KeepAliveInterval = TimeSpan.FromSeconds(15);
    options.ClientTimeoutInterval = TimeSpan.FromSeconds(30);
})
.AddMessagePackProtocol(); // More efficient than JSON
```

---

## Performance Monitoring

### 1. Add Application Insights

```csharp
// In Program.cs
builder.Services.AddApplicationInsightsTelemetry();
```

### 2. Add Health Checks

```csharp
builder.Services.AddHealthChecks()
    .AddDbContextCheck<ApplicationDbContext>()
    .AddRedis(builder.Configuration.GetConnectionString("Redis"));

// Map health check endpoint
app.MapHealthChecks("/health");
```

### 3. Custom Performance Middleware

```csharp
app.Use(async (context, next) =>
{
    var sw = Stopwatch.StartNew();
    await next();
    sw.Stop();
    
    if (sw.ElapsedMilliseconds > 1000) // Log slow requests
    {
        var logger = context.RequestServices.GetRequiredService<ILogger<Program>>();
        logger.LogWarning($"Slow request: {context.Request.Path} took {sw.ElapsedMilliseconds}ms");
    }
});
```

---

## Frontend Optimization

### 1. Minimize CSS/JavaScript

Install build tools:
```powershell
npm install -D cssnano postcss-cli uglify-js
```

### 2. Bundle and Minify

Use WebOptimizer NuGet package:

```powershell
dotnet add package LigerShark.WebOptimizer.Core
```

```csharp
// In Program.cs
builder.Services.AddWebOptimizer(pipeline =>
{
    pipeline.MinifyCssFiles("css/**/*.css");
    pipeline.MinifyJsFiles("js/**/*.js");
});
```

### 3. Use Font Display Swap

Already implemented in site.css. For Google Fonts, add `&display=swap`:

```html
<link href="https://fonts.googleapis.com/css2?family=Inter&display=swap" rel="stylesheet">
```

---

## Scalability Recommendations

### 1. Horizontal Scaling

**Requirements for Multiple Servers:**
- ✅ Redis for distributed caching (already implemented)
- ✅ Redis for SignalR backplane (already implemented)
- ✅ Session state in distributed cache
- ✅ Shared storage for uploaded files (use Azure Blob Storage)

### 2. Database Scaling

**Read Replicas:**
- Configure read-only database replicas
- Route read queries to replicas
- Keep writes on primary database

**Example:**
```csharp
services.AddDbContext<ApplicationDbContext>(options =>
{
    if (isReadOperation)
        options.UseSqlServer(readReplicaConnectionString);
    else
        options.UseSqlServer(primaryConnectionString);
});
```

### 3. Load Balancing

Use Azure Application Gateway or similar:
- SSL termination
- URL-based routing
- Session affinity (if needed)

---

## Performance Testing

### 1. Load Testing Tools

**Recommended Tools:**
- **k6**: Modern load testing tool
- **JMeter**: Comprehensive testing suite
- **Azure Load Testing**: Cloud-based solution

### 2. Test Scenarios

```javascript
// k6 load test example
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '2m', target: 100 }, // Ramp up
    { duration: '5m', target: 100 }, // Stay at 100 users
    { duration: '2m', target: 0 },   // Ramp down
  ],
};

export default function () {
  const response = http.get('https://yourdomain.com/');
  check(response, { 'status is 200': (r) => r.status === 200 });
  sleep(1);
}
```

### 3. Performance Benchmarks

**Target Metrics:**
- Homepage load: < 2 seconds
- Product page load: < 1.5 seconds
- Search response: < 500ms
- API calls: < 200ms
- Database queries: < 100ms average

---

## Monitoring Dashboard

### Key Metrics to Track

1. **Response Times**
   - Average, 95th percentile, 99th percentile
   
2. **Throughput**
   - Requests per second
   - Concurrent users
   
3. **Error Rates**
   - HTTP 500 errors
   - Database connection failures
   - Redis connection failures
   
4. **Resource Utilization**
   - CPU usage
   - Memory usage
   - Database connections
   - Redis memory

---

## Query Performance Analysis

### Enable Query Statistics

```sql
-- Find slow queries
SELECT TOP 50
    qs.execution_count,
    qs.total_elapsed_time / qs.execution_count AS avg_elapsed_time,
    SUBSTRING(qt.text, (qs.statement_start_offset/2)+1,
        ((CASE qs.statement_end_offset
            WHEN -1 THEN DATALENGTH(qt.text)
            ELSE qs.statement_end_offset
        END - qs.statement_start_offset)/2) + 1) AS statement_text
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) qt
ORDER BY avg_elapsed_time DESC;
```

---

## Caching Strategy

### Current Implementation
- ✅ Distributed cache for site settings (30 min)
- ✅ Static files (7 days)

### Recommended Additions

```csharp
// Cache product lists
public async Task<List<Product>> GetFeaturedProductsAsync()
{
    var cacheKey = "featured_products";
    var cached = await _cache.GetStringAsync(cacheKey);
    
    if (cached != null)
        return JsonSerializer.Deserialize<List<Product>>(cached);
    
    var products = await _db.Products
        .Where(p => p.IsFeatured && p.IsActive)
        .Take(10)
        .ToListAsync();
    
    await _cache.SetStringAsync(cacheKey, 
        JsonSerializer.Serialize(products),
        new DistributedCacheEntryOptions {
            AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(10)
        });
    
    return products;
}
```

---

## Cost Optimization

### Azure Cost Saving Tips

1. **Right-size your resources**
   - Start small, scale as needed
   - Use autoscaling

2. **Reserved instances**
   - Save up to 72% with 1 or 3-year commitments

3. **Azure SQL**
   - Use DTU model for predictable workloads
   - Consider serverless for variable workloads

4. **Redis Cache**
   - Basic tier for development
   - Standard/Premium for production

---

## Conclusion

This application is already well-optimized with compression, caching, and proper architecture. The recommendations above will help you achieve even better performance as your user base grows.

**Priority Implementation Order:**
1. Database indexes (High Impact, Low Effort)
2. Output caching on controllers (High Impact, Low Effort)
3. Lazy loading images (Medium Impact, Low Effort)
4. Health checks and monitoring (High Impact, Medium Effort)
5. CDN for static assets (High Impact, Medium Effort)

---

**Last Updated**: December 8, 2025  
**Version**: 1.0
