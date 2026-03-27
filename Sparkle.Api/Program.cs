using System.Net;
using System.Text;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Sparkle.Domain.Catalog;
using Sparkle.Domain.Identity;
using Sparkle.Infrastructure;
using Sparkle.Infrastructure.Services;
using Sparkle.Api.Services;
using Sparkle.Domain.Configuration;
using Sparkle.Domain.Sellers;

var builder = WebApplication.CreateBuilder(args);
var loggerFactory = LoggerFactory.Create(b => b.AddConsole());
var startupLogger = loggerFactory.CreateLogger("Startup");

// Database & Identity
var connectionString = Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection")
    ?? builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("Connection string 'DefaultConnection' not found.");

startupLogger.LogInformation("Connection string source: {Source}",
    Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection") != null ? "Environment Variable" : "appsettings.json");
startupLogger.LogInformation("Database: SQL Server");

// Azure Free Tier: reduced pool size (1GB RAM limit)
builder.Services.AddDbContextPool<ApplicationDbContext>(options =>
{
    options.UseSqlServer(connectionString, sqlOptions =>
    {
        sqlOptions.CommandTimeout(builder.Environment.IsDevelopment() ? 30 : 180);
        sqlOptions.EnableRetryOnFailure(maxRetryCount: 5, maxRetryDelay: TimeSpan.FromSeconds(30), errorNumbersToAdd: null);
        sqlOptions.UseQuerySplittingBehavior(QuerySplittingBehavior.SplitQuery);
    });

    if (builder.Environment.IsDevelopment())
    {
        options.EnableSensitiveDataLogging(false);
        options.EnableDetailedErrors(false);
        options.LogTo(_ => { }, LogLevel.Warning);
    }
}, poolSize: 32);

builder.Services.AddIdentity<ApplicationUser, ApplicationRole>(options =>
    {
        options.Password.RequireDigit = true;
        options.Password.RequireLowercase = true;
        options.Password.RequireUppercase = false;
        options.Password.RequireNonAlphanumeric = false;
        options.Password.RequiredLength = 6;
        
        options.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(5);
        options.Lockout.MaxFailedAccessAttempts = 5;
        options.Lockout.AllowedForNewUsers = true;
        
        options.User.RequireUniqueEmail = true;
        options.SignIn.RequireConfirmedEmail = false;
        options.SignIn.RequireConfirmedAccount = false;
    })
    .AddEntityFrameworkStores<ApplicationDbContext>()
    .AddDefaultTokenProviders();

// Google OAuth
var googleClientId = builder.Configuration["Google:ClientId"];
var googleClientSecret = builder.Configuration["Google:ClientSecret"];
var isGoogleConfigured = !string.IsNullOrWhiteSpace(googleClientId) && 
                         !string.IsNullOrWhiteSpace(googleClientSecret) &&
                         googleClientId != "YOUR_GOOGLE_CLIENT_ID_HERE" &&
                         googleClientSecret != "YOUR_GOOGLE_CLIENT_SECRET_HERE";

if (isGoogleConfigured)
{
    builder.Services.AddAuthentication()
        .AddGoogle(options =>
        {
            options.ClientId = googleClientId!;
            options.ClientSecret = googleClientSecret!;
            options.SaveTokens = true;
        });
    startupLogger.LogInformation("Google OAuth enabled.");
}
else
{
    startupLogger.LogInformation("Google OAuth not configured.");
}

builder.Services.AddSingleton<IGoogleAuthConfigurationService>(sp => 
    new GoogleAuthConfigurationService(isGoogleConfigured));

// Cookie authentication
builder.Services.ConfigureApplicationCookie(options =>
{
    options.LoginPath = "/auth/login";
    options.LogoutPath = "/auth/logout";
    options.AccessDeniedPath = "/auth/access-denied";
    options.ExpireTimeSpan = TimeSpan.FromDays(30);
    options.SlidingExpiration = true;
    options.Cookie.HttpOnly = true;
    options.Cookie.SecurePolicy = CookieSecurePolicy.SameAsRequest;
});

// JWT Authentication for APIs
var jwtSection = builder.Configuration.GetSection("Jwt");
var jwtKey = jwtSection["Key"] ?? throw new InvalidOperationException("JWT Key is missing");
var keyBytes = Encoding.UTF8.GetBytes(jwtKey);

builder.Services.AddAuthentication()
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtSection["Issuer"],
            ValidAudience = jwtSection["Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(keyBytes)
        };
    });

// Application Services
builder.Services.AddScoped<ICommissionService, CommissionService>();
builder.Services.AddScoped<Sparkle.Domain.Marketing.ILoyaltyService, LoyaltyService>();
builder.Services.AddScoped<ISettingsService, SettingsService>();
builder.Services.AddTransient<LocationSeedingService>();
builder.Services.AddScoped<IDynamicFormService, DynamicFormService>();
builder.Services.AddScoped<DynamicFormSeedingService>();
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<ShipmentService>();
builder.Services.AddScoped<IReviewService, ReviewService>();
builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddScoped<ICachingService, RedisCachingService>();
builder.Services.AddScoped<ISellerPerformanceService, SellerPerformanceService>();
builder.Services.AddScoped<IInvoiceService, InvoiceService>();
builder.Services.AddScoped<IAIService, AIService>();
builder.Services.AddScoped<IStockManagementService, StockManagementService>();
builder.Services.AddScoped<IHomepageSectionService, HomepageSectionService>();
builder.Services.AddScoped<IIntelligentProductAnalysisService, IntelligentProductAnalysisService>();
builder.Services.AddScoped<IAIRecommendationService, AIRecommendationService>();
builder.Services.AddScoped<HomepageSectionSeedingService>();
builder.Services.AddScoped<ISellerAuthorizationService, SellerAuthorizationService>();
builder.Services.AddScoped<Sparkle.Domain.Intelligence.ISmartSearchService, Sparkle.Infrastructure.Intelligence.SmartSearchService>();
builder.Services.AddScoped<IWalletService, WalletService>();
builder.Services.AddScoped<ISupportService, SupportService>();
builder.Services.AddScoped<ILogisticsService, LogisticsService>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddScoped<IPaymentService, SSLCommerzService>();

// SignalR
builder.Services.AddSignalR();

// Session (Azure Free Tier: reduced timeout)
builder.Services.AddDistributedMemoryCache();
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromMinutes(30);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
    options.Cookie.Name = ".Sparkle.Session";
    options.Cookie.SameSite = SameSiteMode.Lax;
});

// Response Compression
builder.Services.AddResponseCompression(options =>
{
    options.EnableForHttps = true;
    options.Providers.Add<Microsoft.AspNetCore.ResponseCompression.BrotliCompressionProvider>();
    options.Providers.Add<Microsoft.AspNetCore.ResponseCompression.GzipCompressionProvider>();
});

builder.Services.Configure<Microsoft.AspNetCore.ResponseCompression.BrotliCompressionProviderOptions>(options =>
{
    options.Level = System.IO.Compression.CompressionLevel.Fastest;
});

builder.Services.Configure<Microsoft.AspNetCore.ResponseCompression.GzipCompressionProviderOptions>(options =>
{
    options.Level = System.IO.Compression.CompressionLevel.Fastest;
});

builder.Services.AddResponseCaching();

builder.Services.AddControllersWithViews()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
        options.JsonSerializerOptions.DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull;
    });

builder.Services.AddRazorPages();

if (builder.Environment.IsDevelopment())
{
    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen();
}

var app = builder.Build();

// Health endpoint
app.MapGet("/health", () => Results.Ok(new { status = "healthy", timestamp = DateTime.UtcNow }));

// Database initialization
try
{
    using (var initScope = app.Services.CreateScope())
    {
        var initServices = initScope.ServiceProvider;
        var initLogger = initServices.GetRequiredService<ILogger<Program>>();
        var initDb = initServices.GetRequiredService<ApplicationDbContext>();

        try
        {
            await Sparkle.Api.Data.DbInitializer.InitializeAsync(initServices);
        }
        catch (Exception ex)
        {
            initLogger.LogError(ex, "Database initialization failed.");
        }

        var allExist = await initDb.Database.SqlQueryRaw<int>(
            @"SELECT CASE WHEN 
                EXISTS (SELECT 1 FROM [sellers].[Sellers]) AND
                EXISTS (SELECT 1 FROM [catalog].[Products]) AND
                EXISTS (SELECT 1 FROM [DeliveryZones]) AND
                EXISTS (SELECT 1 FROM [system].[SiteSettings])
            THEN 1 ELSE 0 END AS Value").SingleAsync() == 1;

        if (allExist)
        {
            initLogger.LogInformation("[FastStart] All data exists. Skipping seeding.");
        }
        else
        {
            initLogger.LogInformation("[FastStart] Seeding required. Starting initialization...");
            await SeedAllDataAsync(app.Services);
        }

        try
        {
            var sectionSeeder = initServices.GetRequiredService<HomepageSectionSeedingService>();
            await sectionSeeder.SeedAsync();
        }
        catch (Exception ex)
        {
            initLogger.LogWarning(ex, "Homepage section seeding failed (non-critical).");
        }
    }
}
catch (Exception ex)
{
    startupLogger.LogWarning(ex, "Database initialization skipped.");
}

// Background cleanup (non-blocking)
_ = Task.Run(async () =>
{
    try
    {
        using var bgScope = app.Services.CreateScope();
        var bgDb = bgScope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        await bgDb.Database.ExecuteSqlRawAsync("DELETE FROM [orders].[Carts] WHERE [UserId] LIKE 'guest_%'");
    }
    catch { }
});

// HTTP pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/swagger/v1/swagger.json", "Sparkle API V1");
        options.RoutePrefix = "api-docs";
    });
}
else
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
    app.UseHttpsRedirection();
}

if (!app.Environment.IsDevelopment())
{
    app.UseResponseCompression();
}

app.UseStaticFiles(new StaticFileOptions
{
    OnPrepareResponse = ctx =>
    {
        const int durationInSeconds = 60 * 60 * 24 * 7;
        ctx.Context.Response.Headers.Append("Cache-Control", $"public,max-age={durationInSeconds}");
    }
});

app.UseRouting();
app.UseResponseCaching();
app.UseSession();

app.UseMiddleware<Sparkle.Api.Middleware.GlobalExceptionMiddleware>();
app.UseMiddleware<Sparkle.Api.Middleware.SecurityMiddleware>();
app.UseMiddleware<Sparkle.Api.Middleware.AdminActionLoggingMiddleware>();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllerRoute(
    name: "areas",
    pattern: "{area:exists}/{controller=Dashboard}/{action=Index}/{id?}");

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.MapControllers();

// SignalR Hubs
app.MapHub<Sparkle.Api.Hubs.InventoryHub>("/hubs/inventory");
app.MapHub<Sparkle.Api.Hubs.OrderTrackingHub>("/hubs/ordertracking");
app.MapHub<Sparkle.Api.Hubs.NotificationHub>("/hubs/notification");
app.MapHub<Sparkle.Api.Hubs.ChatHub>("/hubs/chat");

// ==================== SEEDING ====================
async Task SeedAllDataAsync(IServiceProvider rootServices)
{
    using var scope = rootServices.CreateScope();
    var services = scope.ServiceProvider;
    var logger = services.GetRequiredService<ILogger<Program>>();
    var db = services.GetRequiredService<ApplicationDbContext>();

    try
    {
        var roleManager = services.GetRequiredService<RoleManager<ApplicationRole>>();
        var userManager = services.GetRequiredService<UserManager<ApplicationUser>>();

        var existingRoleNames = await roleManager.Roles.Select(r => r.Name).ToListAsync();

        string[] roles = ["User", "Seller", "Admin"];
        foreach (var roleName in roles)
        {
            if (!existingRoleNames.Contains(roleName))
                await roleManager.CreateAsync(new ApplicationRole { Name = roleName });
        }

        var seedEmails = new[] { "admin@sparkle.local", "user@sparkle.local" };
        var existingUsers = await db.Users
            .Where(u => seedEmails.Contains(u.Email))
            .ToDictionaryAsync(u => u.Email!);

        if (!existingUsers.ContainsKey("admin@sparkle.local"))
        {
            var admin = new ApplicationUser
            {
                UserName = "admin@sparkle.local",
                Email = "admin@sparkle.local",
                EmailConfirmed = true,
                FullName = "Super Admin"
            };
            var createResult = await userManager.CreateAsync(admin, "Admin@123");
            if (createResult.Succeeded)
                await userManager.AddToRoleAsync(admin, "Admin");
        }

        try
        {
            await db.Database.ExecuteSqlRawAsync(@"
                IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('support.ChatMessages') AND name = 'DeletedFor')
                BEGIN
                    ALTER TABLE [support].[ChatMessages] ADD [DeletedFor] nvarchar(450) NULL;
                END");
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "Chat DeletedFor column check failed (non-critical).");
        }

        // Categories
        var requiredCategories = new List<Category>
        {
            new() { Name = "Electronics & Gadgets", Slug = "electronics-gadgets" },
            new() { Name = "Fashion & Lifestyle", Slug = "fashion-lifestyle" },
            new() { Name = "Home & Living", Slug = "home-living" },
            new() { Name = "Mobiles & Tablets", Slug = "mobiles-tablets" },
            new() { Name = "Laptops & Computers", Slug = "laptops-computers" },
            new() { Name = "Home Appliances", Slug = "home-appliances" },
            new() { Name = "Kitchen Appliances", Slug = "kitchen-small-appliances" },
            new() { Name = "Beauty & Personal Care", Slug = "beauty-personal-care" },
            new() { Name = "Jewelry & Accessories", Slug = "jewelry-accessories" },
            new() { Name = "Groceries & Essentials", Slug = "groceries-essentials" },
            new() { Name = "Baby, Kids & Mom", Slug = "baby-kids-mom" },
            new() { Name = "Toys & Games", Slug = "toys-games" },
            new() { Name = "Books & Stationery", Slug = "books-stationery" },
            new() { Name = "Sports & Outdoors", Slug = "sports-outdoors" },
            new() { Name = "Automotive & Bike", Slug = "automotive-bike" },
            new() { Name = "Pet Supplies", Slug = "pet-supplies" },
            new() { Name = "Local BD Brands", Slug = "local-bd-brands" },
            new() { Name = "Medicine & Wellness", Slug = "medicine-wellness" },
            new() { Name = "Photography & Camera", Slug = "photography-camera" },
            new() { Name = "Art & Crafts", Slug = "art-crafts" },
            new() { Name = "Musical Instruments", Slug = "musical-instruments" },
            new() { Name = "Garden & Outdoor", Slug = "garden-outdoor" },
            new() { Name = "Travel & Luggage", Slug = "travel-luggage" },
            new() { Name = "Fitness & Gym", Slug = "fitness-gym" }
        };

        var slugs = requiredCategories.Select(c => c.Slug).ToList();
        var existingCategories = await db.Categories
            .Where(c => slugs.Contains(c.Slug))
            .ToDictionaryAsync(c => c.Slug);

        foreach (var cat in requiredCategories)
        {
            if (!existingCategories.TryGetValue(cat.Slug, out var existing))
                db.Categories.Add(cat);
            else if (existing.Name != cat.Name)
                existing.Name = cat.Name;
        }
        if (db.ChangeTracker.HasChanges())
            await db.SaveChangesAsync();

        // Sellers
        if (!await db.Sellers.AnyAsync())
        {
            var sellerConfigs = new[]
            {
                new { Email = "dailyessentials@sparkle.local", Password = "Vendor@123", FullName = "Abdul Malek", ShopName = "Daily Essentials BD", ShopDescription = "Your one-stop shop for daily household needs, electronics, and kitchenware.", City = "Dhaka", District = "Dhaka", Phone = "+880 1711-223344", Bkash = "01711223344", Rating = 4.8m, Address = "Plot-5, Road-12, Section-10, Mirpur, Dhaka" },
                new { Email = "dailymart@sparkle.local", Password = "Vendor@123", FullName = "Salma Begum", ShopName = "DailyMart BD", ShopDescription = "Everything you need for your daily life. Groceries, home appliances, and household essentials.", City = "Chittagong", District = "Chittagong", Phone = "+880 1822-334455", Bkash = "01822334455", Rating = 4.7m, Address = "12, Nellie Road, Chittagong-4000" },
                new { Email = "homeneeds@sparkle.local", Password = "Vendor@123", FullName = "Rafiq Ahmed", ShopName = "HomeNeeds BD", ShopDescription = "Quality home essentials, electronics, and personal care products.", City = "Dhaka", District = "Dhaka", Phone = "+880 1734-567890", Bkash = "01734567890", Rating = 4.6m, Address = "78/B, Dhanmondi, Dhaka-1209" },
                new { Email = "mobilebazar@sparkle.local", Password = "Vendor@123", FullName = "Jamal Uddin", ShopName = "Mobile Bazar Bangladesh", ShopDescription = "Authorized reseller of Samsung, Xiaomi, Realme, Oppo.", City = "Sylhet", District = "Sylhet", Phone = "+880 1745-678901", Bkash = "01745678901", Rating = 4.8m, Address = "12, Zindabazar, Sylhet-3100" },
                new { Email = "freshmart@sparkle.local", Password = "Vendor@123", FullName = "Nasrin Akter", ShopName = "Fresh Mart BD", ShopDescription = "Daily fresh groceries delivered to your doorstep.", City = "Dhaka", District = "Dhaka", Phone = "+880 1756-789012", Bkash = "01756789012", Rating = 4.4m, Address = "56, Banani, Dhaka-1213" },
                new { Email = "beautyzone@sparkle.local", Password = "Vendor@123", FullName = "Sumaiya Khan", ShopName = "Beauty Zone Cosmetics", ShopDescription = "100% original cosmetics and skincare products.", City = "Dhaka", District = "Dhaka", Phone = "+880 1767-890123", Bkash = "01767890123", Rating = 4.9m, Address = "34, Gulshan-2, Dhaka-1212" },
                new { Email = "sportsworld@sparkle.local", Password = "Vendor@123", FullName = "Rubel Islam", ShopName = "Sports World BD", ShopDescription = "Complete sports equipment and fitness gear.", City = "Khulna", District = "Khulna", Phone = "+880 1778-901234", Bkash = "01778901234", Rating = 4.3m, Address = "89, Sonadanga, Khulna-9100" },
                new { Email = "computerplus@sparkle.local", Password = "Vendor@123", FullName = "Tamim Hasan", ShopName = "Computer Plus Solutions", ShopDescription = "Laptops, desktops, accessories, and IT solutions.", City = "Dhaka", District = "Dhaka", Phone = "+880 1789-012345", Bkash = "01789012345", Rating = 4.7m, Address = "67, IDB Bhaban, Agargaon, Dhaka-1207" },
                new { Email = "bookshop@sparkle.local", Password = "Vendor@123", FullName = "Farhan Chowdhury", ShopName = "Book Lovers Paradise", ShopDescription = "Largest collection of Bengali and English books.", City = "Rajshahi", District = "Rajshahi", Phone = "+880 1790-123456", Bkash = "01790123456", Rating = 4.6m, Address = "23, Shaheb Bazar, Rajshahi-6100" },
                new { Email = "babyshop@sparkle.local", Password = "Vendor@123", FullName = "Mehjabin Sultana", ShopName = "Baby Care Heaven", ShopDescription = "Everything for your little ones.", City = "Dhaka", District = "Dhaka", Phone = "+880 1701-234567", Bkash = "01701234567", Rating = 4.8m, Address = "92, Uttara, Sector-7, Dhaka-1230" },
                new { Email = "jewelrypalace@sparkle.local", Password = "Vendor@123", FullName = "Sabrina Ahmed", ShopName = "Jewelry Palace BD", ShopDescription = "Exquisite gold, silver, and diamond jewelry.", City = "Dhaka", District = "Dhaka", Phone = "+880 1812-345678", Bkash = "01812345678", Rating = 4.9m, Address = "156, New Market, Dhaka-1205" },
                new { Email = "pharmaeasy@sparkle.local", Password = "Vendor@123", FullName = "Dr. Ashraf Hossain", ShopName = "PharmaEasy Bangladesh", ShopDescription = "Licensed pharmacy with 24/7 medicine delivery.", City = "Dhaka", District = "Dhaka", Phone = "+880 1823-456789", Bkash = "01823456789", Rating = 4.8m, Address = "45, Farmgate, Dhaka-1215" },
                new { Email = "petworld@sparkle.local", Password = "Vendor@123", FullName = "Tanvir Rahman", ShopName = "Pet World Bangladesh", ShopDescription = "Complete pet care solutions.", City = "Dhaka", District = "Dhaka", Phone = "+880 1834-567890", Bkash = "01834567890", Rating = 4.5m, Address = "78, Banasree, Dhaka-1219" },
                new { Email = "camerahub@sparkle.local", Password = "Vendor@123", FullName = "Imran Khan", ShopName = "Camera Hub BD", ShopDescription = "Professional cameras, lenses, drones, and photography equipment.", City = "Dhaka", District = "Dhaka", Phone = "+880 1845-678901", Bkash = "01845678901", Rating = 4.7m, Address = "234, Elephant Road, Dhaka-1205" },
                new { Email = "autoparts@sparkle.local", Password = "Vendor@123", FullName = "Rahim Uddin", ShopName = "Auto Parts Bangladesh", ShopDescription = "Genuine car and bike parts and accessories.", City = "Chittagong", District = "Chittagong", Phone = "+880 1856-789012", Bkash = "01856789012", Rating = 4.4m, Address = "67, Muradpur, Chittagong-4212" },
                new { Email = "musicstore@sparkle.local", Password = "Vendor@123", FullName = "Anika Tabassum", ShopName = "Music Store Bangladesh", ShopDescription = "Musical instruments, sound systems, DJ equipment.", City = "Dhaka", District = "Dhaka", Phone = "+880 1867-890123", Bkash = "01867890123", Rating = 4.6m, Address = "89, Dhanmondi 27, Dhaka-1209" },
                new { Email = "gardenstore@sparkle.local", Password = "Vendor@123", FullName = "Hasan Mahmud", ShopName = "Garden Store BD", ShopDescription = "Plants, seeds, gardening tools, fertilizers.", City = "Dhaka", District = "Dhaka", Phone = "+880 1878-901234", Bkash = "01878901234", Rating = 4.5m, Address = "123, Mirpur 10, Dhaka-1216" },
                new { Email = "travelgear@sparkle.local", Password = "Vendor@123", FullName = "Nadia Islam", ShopName = "Travel Gear Bangladesh", ShopDescription = "Quality luggage, travel bags, backpacks.", City = "Sylhet", District = "Sylhet", Phone = "+880 1889-012345", Bkash = "01889012345", Rating = 4.7m, Address = "45, Zindabazar, Sylhet-3100" },
                new { Email = "artcraft@sparkle.local", Password = "Vendor@123", FullName = "Mahbub Alam", ShopName = "Art & Craft Corner", ShopDescription = "Art supplies, craft materials, painting tools.", City = "Dhaka", District = "Dhaka", Phone = "+880 1890-123456", Bkash = "01890123456", Rating = 4.6m, Address = "56, Kataban, Dhaka-1217" },
                new { Email = "fitnessgear@sparkle.local", Password = "Vendor@123", FullName = "Sakib Ahmed", ShopName = "Fitness Gear Pro", ShopDescription = "Professional gym equipment and fitness supplements.", City = "Dhaka", District = "Dhaka", Phone = "+880 1801-234567", Bkash = "01801234567", Rating = 4.8m, Address = "34, Bashundhara, Dhaka-1229" },
                new { Email = "toysrus@sparkle.local", Password = "Vendor@123", FullName = "Farhana Begum", ShopName = "Toys R Us Bangladesh", ShopDescription = "Educational toys, action figures, dolls, puzzles.", City = "Chittagong", District = "Chittagong", Phone = "+880 1913-345678", Bkash = "01913345678", Rating = 4.7m, Address = "78, GEC Circle, Chittagong-4000" },
                new { Email = "electroniccity@sparkle.local", Password = "Vendor@123", FullName = "Jahangir Alam", ShopName = "Electronic City BD", ShopDescription = "TVs, refrigerators, washing machines, ACs.", City = "Dhaka", District = "Dhaka", Phone = "+880 1924-456789", Bkash = "01924456789", Rating = 4.6m, Address = "123, Shantinagar, Dhaka-1217" },
                new { Email = "medicalequip@sparkle.local", Password = "Vendor@123", FullName = "Dr. Sultana Kamal", ShopName = "Medical Equipment BD", ShopDescription = "Medical devices, wheelchairs, health monitoring.", City = "Dhaka", District = "Dhaka", Phone = "+880 1935-567890", Bkash = "01935567890", Rating = 4.8m, Address = "67, Mohakhali, Dhaka-1212" },
                new { Email = "officemaster@sparkle.local", Password = "Vendor@123", FullName = "Kamrul Hassan", ShopName = "Office Master BD", ShopDescription = "Office furniture, chairs, desks, filing cabinets.", City = "Dhaka", District = "Dhaka", Phone = "+880 1946-678901", Bkash = "01946678901", Rating = 4.5m, Address = "89, Panthapath, Dhaka-1215" },
                new { Email = "kidszone@sparkle.local", Password = "Vendor@123", FullName = "Roksana Akter", ShopName = "Kids Zone Fashion", ShopDescription = "Trendy kids clothing, shoes, school uniforms.", City = "Dhaka", District = "Dhaka", Phone = "+880 1957-789012", Bkash = "01957789012", Rating = 4.7m, Address = "45, Elephant Road, Dhaka-1205" }
            };

            foreach (var config in sellerConfigs)
            {
                var sellerUser = new ApplicationUser
                {
                    UserName = config.Email,
                    Email = config.Email,
                    EmailConfirmed = true,
                    FullName = config.FullName,
                    IsSeller = true
                };

                var sellerCreate = await userManager.CreateAsync(sellerUser, config.Password);
                if (sellerCreate.Succeeded)
                {
                    await userManager.AddToRoleAsync(sellerUser, "Seller");
                    var seller = new Seller
                    {
                        UserId = sellerUser.Id,
                        ShopName = config.ShopName,
                        ShopDescription = config.ShopDescription,
                        Status = SellerStatus.Approved,
                        StoreLogo = $"https://ui-avatars.com/api/?name={Uri.EscapeDataString(config.ShopName)}&size=200&background=random",
                        StoreBanner = $"https://placehold.co/1200x300/6366f1/ffffff?text={Uri.EscapeDataString(config.ShopName)}",
                        City = config.City,
                        District = config.District,
                        Country = "Bangladesh",
                        MobileNumber = config.Phone,
                        BkashMerchantNumber = config.Bkash,
                        BusinessAddress = config.Address,
                        Rating = config.Rating,
                        CreatedAt = DateTime.UtcNow.AddMonths(-Random.Shared.Next(6, 24)),
                        ApprovedAt = DateTime.UtcNow.AddMonths(-Random.Shared.Next(1, 6))
                    };
                    db.Sellers.Add(seller);
                }
            }
            await db.SaveChangesAsync();
        }

        // Products
        var productSeeder = new ProductSeedingService(db, services.GetRequiredService<ILoggerFactory>().CreateLogger<ProductSeedingService>());
        await productSeeder.SeedProductsAsync();

        // Demo user
        if (!existingUsers.ContainsKey("user@sparkle.local"))
        {
            var customerUser = new ApplicationUser { UserName = "user@sparkle.local", Email = "user@sparkle.local", EmailConfirmed = true, FullName = "Demo Customer" };
            if ((await userManager.CreateAsync(customerUser, "User@123")).Succeeded)
                await userManager.AddToRoleAsync(customerUser, "User");
        }

        // Delivery zones
        if (!await db.DeliveryZones.AnyAsync())
        {
            var locationSeeder = services.GetRequiredService<LocationSeedingService>();
            var zones = locationSeeder.GetZones();
            db.DeliveryZones.AddRange(zones);
            await db.SaveChangesAsync();

            var dhakaZone = await db.DeliveryZones.FirstOrDefaultAsync(z => z.Name == "Inside Dhaka");
            var suburbsZone = await db.DeliveryZones.FirstOrDefaultAsync(z => z.Name == "Dhaka Suburbs");

            if (dhakaZone != null)
            {
                var areas = locationSeeder.GetDhakaAreas();
                foreach (var area in areas) area.ZoneId = dhakaZone.Id;
                db.DeliveryAreas.AddRange(areas);
            }
            if (suburbsZone != null)
            {
                var areas = locationSeeder.GetDhakaSuburbs();
                foreach (var area in areas) area.ZoneId = suburbsZone.Id;
                db.DeliveryAreas.AddRange(areas);
            }
            await db.SaveChangesAsync();
        }

        // Site settings
        if (!await db.SiteSettings.AnyAsync())
        {
            var settingsService = services.GetRequiredService<ISettingsService>();
            await settingsService.SetStringValueAsync("SiteTitle", "Sparkle", "General", "string", "The name of the website");
            await settingsService.SetStringValueAsync("SupportPhone", "16789", "General", "string", "Customer support phone number");
            await settingsService.SetStringValueAsync("SupportEmail", "support@sparkle.com", "General", "string", "Customer support email address");
            await settingsService.SetStringValueAsync("FooterCopyright", "Sparkle.com", "General", "string", "Copyright text for footer");
        }

        // Dynamic forms
        var dynamicFormSeeder = services.GetRequiredService<DynamicFormSeedingService>();
        await dynamicFormSeeder.SeedFormsAsync();
    }
    catch (Exception ex)
    {
        logger.LogError(ex, "An error occurred during database seeding.");
    }
}

app.Run();
