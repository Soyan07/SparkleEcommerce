# Architecture & System Design Document

## System Overview Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        FRONTEND                                  │
│  (Web Browser / Mobile App)                                      │
│  - Homepage Sections Display                                     │
│  - Product Listings                                              │
│  - Trending Products                                             │
│  - Flash Sale Sections                                           │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ HTTP/REST API Calls
                         │
┌────────────────────────▼────────────────────────────────────────┐
│                    ASP.NET Core API Layer                        │
│                   (Sparkle.Api)                                  │
├────────────────────────────────────────────────────────────────┤
│                                                                  │
│  API Controllers:                                                │
│  ┌──────────────────────────┐  ┌──────────────────────────┐    │
│  │ HomepageApiController    │  │ HomepageSectionsApi      │    │
│  │ (Public/Read-Only)       │  │ Controller (Admin)       │    │
│  │                          │  │                          │    │
│  │ GET /sections            │  │ POST /sections (create)  │    │
│  │ GET /trending            │  │ PUT /sections/{id}       │    │
│  │ GET /flash-sales         │  │ DELETE /sections/{id}    │    │
│  │ GET /recommendations     │  │ POST /products (add)     │    │
│  │                          │  │ DELETE /products (remove)│    │
│  └──────────────────────────┘  │ PUT /layout (config)     │    │
│                                │ POST /enable-automation  │    │
│                                │ POST /disable-automation │    │
│                                └──────────────────────────┘    │
│                                                                  │
│  Response Caching Layer:                                         │
│  ┌──────────────────────────────────────────────────────┐       │
│  │ Distributed Cache (Redis/Memory)                      │       │
│  │ - Sections: 1 hour TTL                                │       │
│  │ - Trending: 30 min TTL                                │       │
│  │ - Flash Sales: 30 min TTL                             │       │
│  │ - Recommendations: 10 min TTL                          │       │
│  └──────────────────────────────────────────────────────┘       │
│                                                                  │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ Service Injection
                         │
┌────────────────────────▼────────────────────────────────────────┐
│                 Service Layer (Business Logic)                   │
│                   (Sparkle.Api.Services)                         │
├────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌─────────────────────────────────────────────────────┐        │
│  │ IHomepageSectionService                             │        │
│  │ (HomepageSectionService)                            │        │
│  ├─────────────────────────────────────────────────────┤        │
│  │                                                     │        │
│  │ Section Management:                                 │        │
│  │  • GetSectionBySlug()          • GetSectionById()   │        │
│  │  • GetAllActiveSections()      • CreateSection()    │        │
│  │  • UpdateSection()             • DeleteSection()    │        │
│  │                                                     │        │
│  │ Product Management:                                 │        │
│  │  • GetSectionProducts()        • AddProduct()       │        │
│  │  • RemoveProduct()             • UpdateOrder()      │        │
│  │                                                     │        │
│  │ Category Management:                                │        │
│  │  • GetSectionCategories()      • AddCategory()      │        │
│  │  • RemoveCategory()                                 │        │
│  │                                                     │        │
│  │ Configuration:                                      │        │
│  │  • UpdateLayout()              • UpdateDisplay()    │        │
│  │  • EnableAutomation()          • DisableAutomat.()  │        │
│  │                                                     │        │
│  │ Audit:                                              │        │
│  │  • LogAudit()                                       │        │
│  │                                                     │        │
│  └─────────────────────────────────────────────────────┘        │
│                                                                  │
│  ┌─────────────────────────────────────────────────────┐        │
│  │ IIntelligentProductAnalysisService                  │        │
│  │ (IntelligentProductAnalysisService)                 │        │
│  ├─────────────────────────────────────────────────────┤        │
│  │                                                     │        │
│  │ Trending Analysis (AI/ML):                          │        │
│  │  • AnalyzeTrendingProducts()                        │        │
│  │  • GetCurrentTrendingProducts()                     │        │
│  │  • RefreshTrendingProducts()                        │        │
│  │                                                     │        │
│  │ Flash Sale Analysis (AI/ML):                        │        │
│  │  • AnalyzeFlashSaleOpportunities()                  │        │
│  │  • GetSuggestedFlashSaleProducts()                  │        │
│  │  • RefreshFlashSaleSuggestions()                    │        │
│  │                                                     │        │
│  │ User Behavior Tracking:                             │        │
│  │  • LogUserAction()                                  │        │
│  │  • GetRecommendedProducts()                         │        │
│  │  • GetUserSearchPattern()                           │        │
│  │                                                     │        │
│  │ Sales Metrics Aggregation:                          │        │
│  │  • UpdateSalesMetrics()                             │        │
│  │  • GetLatestMetrics()                               │        │
│  │  • RefreshAllMetrics()                              │        │
│  │                                                     │        │
│  │ Bulk Operations (Background Jobs):                  │        │
│  │  • RunDailyAnalysis()          • RunWeeklyAnalysis()│        │
│  │                                                     │        │
│  │ Analysis Algorithms:                                │        │
│  │  • Multi-Factor Scoring       (Sales, Views, etc)   │        │
│  │  • Growth Rate Calculation                          │        │
│  │  • Trend Determination                              │        │
│  │  • Inventory Analysis                               │        │
│  │  • Revenue Impact Estimation                        │        │
│  │                                                     │        │
│  └─────────────────────────────────────────────────────┘        │
│                                                                  │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ Data Access (EF Core)
                         │
┌────────────────────────▼────────────────────────────────────────┐
│           Data Access Layer (Entity Framework Core)              │
│                   (Sparkle.Infrastructure)                       │
├────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ApplicationDbContext                                            │
│  ├─ DbSet<HomepageSection>                                      │
│  ├─ DbSet<HomepageSectionProduct>                               │
│  ├─ DbSet<HomepageSectionCategory>                              │
│  ├─ DbSet<TrendingProductSuggestion>                            │
│  ├─ DbSet<FlashSaleProductSuggestion>                           │
│  ├─ DbSet<UserBehaviorAnalytic>                                 │
│  ├─ DbSet<SalesMetricsSnapshot>                                 │
│  ├─ DbSet<HomepageSectionAuditLog>                              │
│  └─ [Other existing DbSets...]                                  │
│                                                                  │
│  ORM Features:                                                   │
│  • Async LINQ queries (Async/Await)                              │
│  • Relationship configuration                                    │
│  • Index definition                                              │
│  • Cascade behaviors                                             │
│  • Migrations support                                            │
│                                                                  │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         │ SQL Queries
                         │
┌────────────────────────▼────────────────────────────────────────┐
│                    DATABASE LAYER                                │
│            SQL Server (SparkleDb)                                │
├────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Content Schema Tables:                                          │
│  ┌──────────────────────────────────────────────────┐           │
│  │ HomepageSections                 (Main config)   │           │
│  │ ├─ Id, Name, Slug, DisplayTitle                 │           │
│  │ ├─ SectionType, DisplayOrder                    │           │
│  │ ├─ LayoutType, CardSize, ProductsPerRow          │           │
│  │ ├─ UseAutomatedSelection, UseManualSelection     │           │
│  │ ├─ ShowRating, ShowPrice, ShowDiscount           │           │
│  │ └─ Audit fields (CreatedAt, UpdatedAt, etc)      │           │
│  └──────────────────────────────────────────────────┘           │
│                                                                  │
│  ┌──────────────────────────────────────────────────┐           │
│  │ HomepageSectionProducts         (Manual assign)  │           │
│  │ ├─ SectionId, ProductId                         │           │
│  │ ├─ DisplayOrder                                 │           │
│  │ ├─ PromotionalText, BadgeText                   │           │
│  │ └─ IsActive                                      │           │
│  └──────────────────────────────────────────────────┘           │
│                                                                  │
│  ┌──────────────────────────────────────────────────┐           │
│  │ HomepageSectionCategories       (Category shop)  │           │
│  │ ├─ SectionId, CategoryId                        │           │
│  │ ├─ DisplayOrder, ProductCountToShow              │           │
│  │ └─ CustomDisplayTitle                            │           │
│  └──────────────────────────────────────────────────┘           │
│                                                                  │
│  ┌──────────────────────────────────────────────────┐           │
│  │ TrendingProductSuggestions      (AI generated)   │           │
│  │ ├─ ProductId                                     │           │
│  │ ├─ ConfidenceScore (0-100)                      │           │
│  │ ├─ SalesCount, ViewCount, WishlistCount          │           │
│  │ ├─ AverageRating, SalesGrowthRate                │           │
│  │ ├─ CalculatedAt, ExpiresAt                       │           │
│  │ └─ Rank, AnalysisPeriod                          │           │
│  └──────────────────────────────────────────────────┘           │
│                                                                  │
│  ┌──────────────────────────────────────────────────┐           │
│  │ FlashSaleProductSuggestions     (AI generated)   │           │
│  │ ├─ ProductId                                     │           │
│  │ ├─ SuggestedDiscountPercentage                   │           │
│  │ ├─ SuggestedFlashPrice                           │           │
│  │ ├─ CurrentInventory                              │           │
│  │ ├─ SuggestionReason                              │           │
│  │ ├─ ExpectedSalesBoost, EstimatedRevenueLift      │           │
│  │ └─ PriorityScore                                 │           │
│  └──────────────────────────────────────────────────┘           │
│                                                                  │
│  ┌──────────────────────────────────────────────────┐           │
│  │ UserBehaviorAnalytics           (Action log)     │           │
│  │ ├─ UserId, ActionType                            │           │
│  │ ├─ ProductId, CategoryId                         │           │
│  │ ├─ SearchTerm, TimeSpentSeconds                  │           │
│  │ ├─ DeviceType, SessionId                         │           │
│  │ └─ IpAddress, UserAgent                          │           │
│  └──────────────────────────────────────────────────┘           │
│                                                                  │
│  ┌──────────────────────────────────────────────────┐           │
│  │ SalesMetricsSnapshot            (Aggregated)     │           │
│  │ ├─ ProductId, PeriodDates                        │           │
│  │ ├─ TotalSales, TotalRevenue                      │           │
│  │ ├─ UniqueBuyers, PageViews                       │           │
│  │ ├─ ConversionRate, ClickThroughRate              │           │
│  │ ├─ AverageRating, ReviewCount                    │           │
│  │ └─ SalesGrowthRate, SalesTrend                   │           │
│  └──────────────────────────────────────────────────┘           │
│                                                                  │
│  ┌──────────────────────────────────────────────────┐           │
│  │ HomepageSectionAuditLogs        (Change history) │           │
│  │ ├─ SectionId, ChangeType                        │           │
│  │ ├─ PropertyName, OldValue, NewValue              │           │
│  │ ├─ ChangedByUserId, ChangedAt                    │           │
│  │ └─ IsAutomatedChange, Notes                      │           │
│  └──────────────────────────────────────────────────┘           │
│                                                                  │
│  Database Features:                                              │
│  • Indexes on frequently queried columns                         │
│  • Unique constraints (slug, combinations)                       │
│  • Foreign keys with proper cascade behaviors                    │
│  • Schema: [content]                                             │
│  • Transactions for data consistency                             │
│                                                                  │
└────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagram

```
                    ┌─────────────────────────┐
                    │  User on Homepage       │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │  Browser Requests       │
                    │  /api/homepage/sections │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │  Check Cache (1hr)      │
                    └────────────┬────────────┘
                                 │
                    ┌────────────▼────────────────────┐
                    │  If Cache Hit:                  │
                    │  Return Cached Response         │
                    │  (80% of requests)              │
                    └────────────┬────────────────────┘
                                 │
                    ┌────────────▼──────────────────────┐
                    │  If Cache Miss (20%):             │
                    │  Query Database                   │
                    │  HomepageSectionService.          │
                    │  GetAllActiveSectionsAsync()      │
                    └────────────┬──────────────────────┘
                                 │
          ┌──────────────────────┬──────────────────────┐
          │                      │                      │
    ┌─────▼──────┐      ┌─────────▼──────┐    ┌──────────▼──────┐
    │ Sections   │      │ Products in    │    │ Categories      │
    │            │      │ Sections       │    │                 │
    │ (ordered by│      │ (by display    │    │ (for category   │
    │ display    │      │ order)         │    │ sections)       │
    │ order)     │      │                │    │                 │
    └─────┬──────┘      └─────────┬──────┘    └──────────┬──────┘
          │                       │                      │
          │  Format & Build       │  Format & Build      │  Format & Build
          │  Response DTOs        │  Response DTOs       │  Response DTOs
          │                       │                      │
          └───────────┬───────────┴──────────────────────┘
                      │
                ┌─────▼─────────────────┐
                │ Combine & Cache       │
                │ Response (1 hour)     │
                └─────┬─────────────────┘
                      │
                ┌─────▼─────────────────┐
                │ Return to Client      │
                │ (JSON Response)       │
                └──────────────────────┘


        INTELLIGENT ANALYSIS BACKGROUND FLOW

                ┌──────────────────┐
                │ Scheduled Job    │
                │ Daily @ 2AM UTC  │
                └────────┬─────────┘
                         │
         ┌───────────────┴───────────────┐
         │                               │
    ┌────▼────────────────┐    ┌─────────▼────────────────┐
    │ Update Sales        │    │ Analyze Trending         │
    │ Metrics             │    │ Products                 │
    │                     │    │                          │
    │ For Each Product:   │    │ Multi-Factor Analysis:   │
    │ - Count sales       │    │ 1. Sales velocity (40%)  │
    │ - Calculate revenue │    │ 2. Views (30%)           │
    │ - Count views       │    │ 3. Wishlist (20%)        │
    │ - Get rating        │    │ 4. Rating (10%)          │
    │ - Calc CTR          │    │ 5. Growth rate (boost)   │
    │ - Determine trend   │    │                          │
    │                     │    │ Result: Ranked list      │
    │ Store in            │    │ with confidence scores   │
    │ SalesMetricsSnapshot│    │                          │
    │                     │    │ Store in                 │
    │                     │    │ TrendingProductSuggestion│
    └────┬────────────────┘    └─────────┬────────────────┘
         │                               │
         └───────────────┬───────────────┘
                         │
              ┌──────────▼──────────┐
              │ Analyze Flash       │
              │ Sale Opportunities  │
              │                     │
              │ For Each Product:   │
              │ - Get inventory     │
              │ - Calc daily avg    │
              │ - Calc days supply  │
              │ - Suggest discount  │
              │ - Est. revenue lift │
              │                     │
              │ Result: Ranked list │
              │ by priority         │
              │                     │
              │ Store in            │
              │ FlashSaleProduct    │
              │ Suggestion          │
              └─────────┬──────────┘
                        │
             ┌──────────▼──────────┐
             │ Expire Old          │
             │ Suggestions         │
             │ (Cleanup)           │
             │                     │
             │ Remove outdated:    │
             │ - Trending (7d)     │
             │ - Flash Sales (7d)  │
             └──────────┬──────────┘
                        │
             ┌──────────▼──────────┐
             │ Job Complete        │
             │ Results cached      │
             │ for API calls       │
             └─────────────────────┘


         USER BEHAVIOR TRACKING FLOW

        ┌────────────────────────────┐
        │ User Interacts on Site     │
        │ - Views product            │
        │ - Searches products        │
        │ - Adds to cart/wishlist    │
        │ - Makes purchase           │
        └────────────┬───────────────┘
                     │
        ┌────────────▼────────────┐
        │ Frontend Logs Action    │
        │ via Analytics API       │
        │                         │
        │ POST /api/analytics     │
        │ {                       │
        │   userId,               │
        │   actionType,           │
        │   productId,            │
        │   sessionId,            │
        │   timeSpent             │
        │ }                       │
        └────────────┬────────────┘
                     │
        ┌────────────▼────────────────┐
        │ IntelligentProductAnalysis  │
        │ Service.LogUserActionAsync()│
        │                             │
        │ Records Action in:          │
        │ UserBehaviorAnalytic table  │
        └────────────┬────────────────┘
                     │
        ┌────────────▼────────────────┐
        │ Data Aggregated in          │
        │ Nightly Analysis            │
        │                             │
        │ Used for:                   │
        │ - Trending detection        │
        │ - User recommendations      │
        │ - Pattern analysis          │
        │ - Behavior insights         │
        └─────────────────────────────┘
```

## Technology Stack

```
┌─────────────────────────────────────────────────────────┐
│                   FRONTEND LAYER                        │
├─────────────────────────────────────────────────────────┤
│ • HTML5/CSS3                                            │
│ • JavaScript (ES6+) / TypeScript                        │
│ • Responsive Design                                     │
│ • Caching Headers (1hr, 30min, 10min)                   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│               BACKEND FRAMEWORK                         │
├─────────────────────────────────────────────────────────┤
│ • ASP.NET Core 8.0                                      │
│ • Entity Framework Core (ORM)                           │
│ • Dependency Injection (Built-in)                       │
│ • Async/Await Pattern                                   │
│ • Logging (ILogger)                                     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                 CACHING LAYER                           │
├─────────────────────────────────────────────────────────┤
│ • Distributed Cache (Redis compatible)                  │
│ • Memory Cache (Fallback)                               │
│ • Response Caching Middleware                           │
│ • Cache Invalidation (TTL-based)                        │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│              DATABASE LAYER                             │
├─────────────────────────────────────────────────────────┤
│ • SQL Server 2019+                                      │
│ • Relational Schema                                     │
│ • Indexes (Query Optimization)                          │
│ • Foreign Keys (Referential Integrity)                  │
│ • Transactions (ACID Compliance)                        │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│            BACKGROUND JOBS                              │
├─────────────────────────────────────────────────────────┤
│ • Option 1: Hangfire (Recommended)                      │
│ • Option 2: Timer-based Service                         │
│ • Option 3: Windows Service / Task Scheduler            │
│ • Frequency: Daily @ 2 AM UTC, Weekly                   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│            MONITORING & LOGGING                         │
├─────────────────────────────────────────────────────────┤
│ • ILogger Interface                                     │
│ • Application Insights (Optional)                       │
│ • Audit Logging (Database)                              │
│ • Performance Metrics                                   │
└─────────────────────────────────────────────────────────┘
```

## Security Architecture

```
┌─────────────────────────────────────────────────────────┐
│                 AUTHENTICATION                          │
├─────────────────────────────────────────────────────────┤
│ • ASP.NET Core Identity                                 │
│ • JWT Tokens (for API)                                  │
│ • Cookies (for MVC)                                     │
│ • Google OAuth (Integration Ready)                      │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                AUTHORIZATION                            │
├─────────────────────────────────────────────────────────┤
│ • Role-Based Access Control (RBAC)                      │
│ • [Authorize(Roles = "Admin")] on Admin APIs            │
│ • [AllowAnonymous] on Public APIs                       │
│ • Claims-based Authorization (Ready)                    │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│              INPUT VALIDATION                           │
├─────────────────────────────────────────────────────────┤
│ • DTO Validation (Request Models)                       │
│ • Enum Validation (LayoutType, ActionType)              │
│ • Range Checks (1-6 rows, 0-100 scores)                 │
│ • String Sanitization (Titles, descriptions)            │
│ • Null Reference Checks                                 │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│              DATA PROTECTION                            │
├─────────────────────────────────────────────────────────┤
│ • HTTPS Only (Enforced)                                 │
│ • Data Encryption at Rest (Option)                      │
│ • SQL Injection Prevention (Parameterized Queries)      │
│ • CORS Configuration (Controlled)                       │
│ • Rate Limiting (Infrastructure Level)                  │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│              AUDIT & COMPLIANCE                         │
├─────────────────────────────────────────────────────────┤
│ • Complete Audit Trail                                  │
│ • Change Logging (Who/When/What)                        │
│ • GDPR-Compliant Data Handling                          │
│ • User Behavior Anonymization (Option)                  │
└─────────────────────────────────────────────────────────┘
```

## Performance Architecture

```
┌────────────────────────────────┐
│    API Request Received        │
└────────────┬───────────────────┘
             │
      ┌──────▼──────┐
      │ Caching     │
      │ Middleware  │
      └──────┬──────┘
             │
      ┌──────▼──────────┐
      │ Cache Hit?      │
      └──────┬──────┬───┘
             │Yes   │No
      ┌──────▼──┐   │
      │Return   │   │
      │ Cached  │   │
      │Response │   │
      └─────────┘   │
                    │
             ┌──────▼──────────┐
             │ Service Layer   │
             │ (Async/Await)   │
             └──────┬──────────┘
                    │
             ┌──────▼──────────┐
             │ EF Core Query   │
             │ (NoTracking)    │
             └──────┬──────────┘
                    │
             ┌──────▼──────────┐
             │ Database        │
             │ (Indexed Query) │
             └──────┬──────────┘
                    │
             ┌──────▼──────────┐
             │ Format DTO      │
             │ Response        │
             └──────┬──────────┘
                    │
             ┌──────▼──────────┐
             │ Cache Response  │
             │ (1hr/30min/10m) │
             └──────┬──────────┘
                    │
             ┌──────▼──────────┐
             │ Return to       │
             │ Client          │
             └─────────────────┘

Optimization Techniques:
✓ Response Caching (80% hit rate)
✓ Database Indexing (25+ indexes)
✓ Async/Await (No thread blocking)
✓ NoTracking Queries (Read-only)
✓ Connection Pooling (Configured)
✓ Batch Operations (Bulk updates)
✓ Lazy Loading Prevention
✓ Query Projection (Select what needed)
```

This completes the comprehensive system architecture documentation!
