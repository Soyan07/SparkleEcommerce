using System.Diagnostics;
using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Distributed;
using System.Text.Json;
using Sparkle.Api.Models;
using Sparkle.Domain.Sellers;
using Sparkle.Api.Services;
using Sparkle.Infrastructure;
using Sparkle.Domain.Content;

namespace Sparkle.Api.Controllers;

public class HomeController : Controller
{
    private readonly ApplicationDbContext _db;
    private readonly ILogger<HomeController> _logger;
    private readonly IDistributedCache _cache;
    private readonly IProductService _productService;

    public HomeController(ApplicationDbContext db, ILogger<HomeController> logger, IDistributedCache cache, IProductService productService)
    {
        _db = db;
        _logger = logger;
        _cache = cache;
        _productService = productService;
    }

    [ResponseCache(Duration = 60, VaryByHeader = "Cookie", Location = ResponseCacheLocation.Any)]
    public async Task<IActionResult> Index()
    {
        // STRICT ROLE ISOLATION: Redirect authenticated users to their respective dashboards
        if (User.Identity?.IsAuthenticated == true)
        {
            if (User.IsInRole("Admin"))
            {
                return RedirectToAction("Index", "Dashboard", new { area = "Admin" });
            }
            if (User.IsInRole("Seller"))
            {
                return RedirectToAction("Index", "Dashboard", new { area = "Seller" });
            }
            // Regular Users stay on the Homepage
        }

        // Try to get cached homepage data - reduced cache time for better responsiveness
        var cacheKey = "homepage_data_v3"; // Updated cache key to force refresh
        var cachedData = await _cache.GetStringAsync(cacheKey);
        
        if (!string.IsNullOrEmpty(cachedData))
        {
            try
            {
                var model = JsonSerializer.Deserialize<HomepageViewModel>(cachedData);
                if (model != null)
                {
                    _logger.LogInformation("Returning cached homepage data");
                    return View(model);
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to deserialize cached homepage data");
                // Clear bad cache
                await _cache.RemoveAsync(cacheKey);
            }
        }

        // Build fresh data - Include both admin products and active seller products
        // Use AsSplitQuery to avoid cartesian explosion
        var baseQuery = _db.Products
            .AsNoTracking()
            .AsSplitQuery() // This fixes the slow query issue
            .Include(p => p.Images)
            .Include(p => p.Variants.OrderBy(v => v.Id)) // Limit variants removed for SQL compatibility
            .Include(p => p.Seller)
            .Where(p => p.IsActive && 
                (p.IsAdminProduct || (p.Seller != null && p.Seller.Status == SellerStatus.Approved)));

            // Fetch active homepage sections configuration
            var sections = await _db.HomepageSections
                .AsNoTracking()
                .Include(s => s.ManualProducts)
                .ThenInclude(sp => sp.Product)
                .ThenInclude(p => p.Images)
                .Include(s => s.ManualProducts)
                .ThenInclude(sp => sp.Product)
                .ThenInclude(p => p.Variants)
                .Where(s => s.IsActive)
                .ToListAsync();

            var featuredSection = sections.FirstOrDefault(s => s.SectionType == "RecommendedProducts");
            var flashSection = sections.FirstOrDefault(s => s.SectionType == "FlashSale");
            var trendingSection = sections.FirstOrDefault(s => s.SectionType == "TrendingProducts");

            // Helper to get products for a section
            async Task<List<Sparkle.Domain.Catalog.Product>> GetSectionProducts(Sparkle.Domain.Content.HomepageSection? section, IQueryable<Sparkle.Domain.Catalog.Product> baseQ, Func<IQueryable<Sparkle.Domain.Catalog.Product>, IQueryable<Sparkle.Domain.Catalog.Product>> fallbackLogic)
            {
               if (section == null || !section.IsActive) return new List<Sparkle.Domain.Catalog.Product>(); // Section disabled in admin

               if (section.UseManualSelection && section.ManualProducts.Any())
               {
                   // Use Manual Selection
                   return section.ManualProducts
                        .Where(sp => sp.Product.IsActive) // Ensure product itself is still active
                        .OrderBy(sp => sp.DisplayOrder)
                        .Select(sp => sp.Product)
                        .ToList();
               }
               
               // Fallback to algorithmic/automated
               return await fallbackLogic(baseQ).Take(section.MaxProductsToDisplay).ToListAsync();
            }

            // 1. Featured / Recommended
            var featuredProducts = await GetSectionProducts(
                featuredSection, 
                baseQuery, 
                q => q.OrderByDescending(p => p.Id)); // Default: Latest products

            // 2. Flash Deals
            var flashDeals = await GetSectionProducts(
                flashSection, 
                baseQuery, 
                q => q.Where(p => p.DiscountPercent > 15).OrderByDescending(p => p.DiscountPercent));

            // 3. Trending
            var trendingProducts = await GetSectionProducts(
                trendingSection, 
                baseQuery, 
                q => q.Where(p => p.AverageRating >= 4.0m).OrderByDescending(p => p.TotalReviews).ThenByDescending(p => p.AverageRating));

            // If sections are missing from DB (first run), fallback to defaults to avoid empty page
            if (featuredSection == null) featuredProducts = await baseQuery.OrderByDescending(p => p.Id).Take(12).ToListAsync();
            if (flashSection == null) flashDeals = await baseQuery.Where(p => p.DiscountPercent > 15).OrderByDescending(p => p.DiscountPercent).Take(8).ToListAsync();
            if (trendingSection == null) trendingProducts = await baseQuery.Where(p => p.AverageRating >= 4.0m).OrderByDescending(p => p.TotalReviews).Take(10).ToListAsync();

            // Set dynamic titles for View safely
            ViewBag.FeaturedTitle = featuredSection?.DisplayTitle;
            ViewBag.FlashTitle = flashSection?.DisplayTitle;
            ViewBag.TrendingTitle = trendingSection?.DisplayTitle;

            var newModel = new HomepageViewModel
            {
                Categories = await _db.Categories
                    .AsNoTracking()
                    .OrderBy(c => c.Name)
                    .ToListAsync(),

                FeaturedProducts = featuredProducts,
                FlashDeals = flashDeals,
                TrendingProducts = trendingProducts,

                // Get active banners for homepage
                Banners = await _db.Banners
                    .AsNoTracking()
                    .Where(b => b.IsActive && 
                               b.Position == "Homepage" &&
                               (b.StartDate == null || b.StartDate <= DateTime.UtcNow) &&
                               (b.EndDate == null || b.EndDate >= DateTime.UtcNow))
                    .OrderBy(b => b.DisplayOrder)
                    .ToListAsync(),
                
                // Assign Configurations
                Sections = await _db.HomepageSections.Where(s => s.IsActive).OrderBy(s => s.DisplayOrder).ToListAsync(),
                FeaturedSectionConfig = featuredSection,
                FlashSectionConfig = flashSection,
                TrendingSectionConfig = trendingSection
            };

        // Cache for 2 minutes for better responsiveness
        try
        {
            var jsonOptions = new JsonSerializerOptions 
            { 
                ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles,
                DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull
            };

            var serialized = JsonSerializer.Serialize(newModel, jsonOptions);
            await _cache.SetStringAsync(cacheKey, serialized, new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(2)
            });
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "Failed to cache homepage data");
        }

        return View(newModel);
    }

    public async Task<IActionResult> Product(int id)
    {
        var product = await _db.Products
            .AsNoTracking()
            .Include(p => p.Images)
            .Include(p => p.Variants)
            .Include(p => p.Category)
            .Include(p => p.Seller)
            .FirstOrDefaultAsync(p => p.Id == id && p.IsActive);

        if (product == null)
            return NotFound();

        // Verify product access: Admin products are always accessible, seller products only if seller is active
        if (!product.IsAdminProduct && (product.Seller == null || product.Seller.Status != SellerStatus.Approved))
            return NotFound();

        return View(product);
    }



    [HttpGet("/search")]
    public async Task<IActionResult> Search(string? q, string? category, int pg = 1)
    {
        int? categoryId = null;
        if (!string.IsNullOrWhiteSpace(category))
        {
            var cat = await _db.Categories.FirstOrDefaultAsync(c => c.Slug == category);
            if (cat != null) categoryId = cat.Id;
        }

        var results = await _productService.SearchProductsAsync(
            categoryId,
            q,
            null, // minPrice
            null, // maxPrice
            null, // attributeFilters
            "Relevance",
            pg,
            20
        );

        ViewBag.SearchQuery = q ?? "";
        ViewBag.Category = category ?? "";
        ViewBag.ResultCount = results.Count;

        return View(results);
    }

    [HttpGet("api/products/search-suggestions")]
    [ResponseCache(Duration = 60, VaryByQueryKeys = new[] { "term" })]
    public async Task<IActionResult> GetSearchSuggestions(string term)
    {
        if (string.IsNullOrWhiteSpace(term) || term.Length < 2)
            return Json(new List<string>());

        // Optimized query - case-insensitive distinct
        var suggestions = await _db.Products
            .AsNoTracking()
            .Where(p => p.IsActive && p.Title.Contains(term))
            .OrderBy(p => p.Title)
            .Select(p => p.Title)
            .Distinct()
            .Take(8)
            .ToListAsync();

        return Json(suggestions);
    }

    [HttpGet("api/products/related/{categoryId}")]
    [ResponseCache(Duration = 300, VaryByQueryKeys = new[] { "exclude", "limit" })]
    public async Task<IActionResult> GetRelatedProducts(int categoryId, int? exclude, int limit = 6)
    {
        var products = await _db.Products
            .AsNoTracking()
            .Include(p => p.Images)
            .Where(p => p.IsActive && p.CategoryId == categoryId && p.Id != (exclude ?? 0))
            .OrderByDescending(p => p.AverageRating)
            .Take(limit)
            .Select(p => new {
                id = p.Id,
                title = p.Title,
                basePrice = p.BasePrice,
                discountPercent = p.DiscountPercent,
                thumbnail = p.Images.OrderBy(i => i.SortOrder).Select(i => i.Url).FirstOrDefault()
            })
            .ToListAsync();
        
        return Json(products);
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel 
        { 
            RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier 
        });
    }


}

public class HomepageViewModel
{
    public List<Sparkle.Domain.Catalog.Category> Categories { get; set; } = new();
    public List<Sparkle.Domain.Catalog.Product> FeaturedProducts { get; set; } = new();
    public List<Sparkle.Domain.Catalog.Product> FlashDeals { get; set; } = new();
    public List<Sparkle.Domain.Catalog.Product> TrendingProducts { get; set; } = new();
    public List<Sparkle.Domain.Marketing.Banner> Banners { get; set; } = new();

    // Section Configurations
    public List<Sparkle.Domain.Content.HomepageSection> Sections { get; set; } = new();
    public Sparkle.Domain.Content.HomepageSection? FeaturedSectionConfig { get; set; }
    public Sparkle.Domain.Content.HomepageSection? FlashSectionConfig { get; set; }
    public Sparkle.Domain.Content.HomepageSection? TrendingSectionConfig { get; set; }
}
