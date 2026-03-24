using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Sparkle.Api.Services;
using Sparkle.Infrastructure;
using System.Security.Claims;

namespace Sparkle.Api.Controllers;

/// <summary>
/// Controller for product reviews with strict order verification.
/// Users can only review products they have purchased and received.
/// </summary>
[Authorize]
public class ReviewController : Controller
{
    private readonly ApplicationDbContext _db;
    private readonly IReviewService _reviewService;
    private readonly ILogger<ReviewController> _logger;

    public ReviewController(
        ApplicationDbContext db,
        IReviewService reviewService,
        ILogger<ReviewController> logger)
    {
        _db = db;
        _reviewService = reviewService;
        _logger = logger;
    }

    private string GetUserId() => User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "";

    /// <summary>
    /// List all products the user can review (delivered but not yet reviewed).
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> Index()
    {
        var userId = GetUserId();
        var reviewableItems = await _reviewService.GetReviewableOrderItemsAsync(userId);
        return View(reviewableItems);
    }

    /// <summary>
    /// Check if user can review a specific product.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> CanReview(int productId)
    {
        var userId = GetUserId();
        var eligibility = await _reviewService.CheckEligibilityAsync(userId, productId);
        return Json(eligibility);
    }

    /// <summary>
    /// Show review form for a product.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> Create(int productId, int? orderItemId)
    {
        var userId = GetUserId();
        
        // Verify eligibility
        var eligibility = await _reviewService.CheckEligibilityAsync(userId, productId);
        if (!eligibility.CanReview)
        {
            TempData["Error"] = eligibility.Reason;
            return RedirectToAction("Index", "Profile");
        }

        var product = await _db.Products
            .Include(p => p.Images)
            .Include(p => p.Seller)
            .FirstOrDefaultAsync(p => p.Id == productId);

        if (product == null)
            return NotFound();

        ViewBag.Product = product;
        ViewBag.Eligibility = eligibility;
        
        return View();
    }

    /// <summary>
    /// Submit a product review.
    /// </summary>
    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(
        int productId,
        int rating,
        string? title,
        string? comment,
        int? qualityRating,
        int? valueForMoneyRating,
        int? accuracyRating,
        List<IFormFile>? images)
    {
        var userId = GetUserId();

        // Handle image uploads
        var imageUrls = new List<string>();
        if (images?.Any() == true)
        {
            var uploadsFolder = Path.Combine("wwwroot", "uploads", "reviews");
            Directory.CreateDirectory(uploadsFolder);

            foreach (var image in images.Take(5))
            {
                if (image.Length > 0 && image.Length <= 5 * 1024 * 1024) // Max 5MB
                {
                    var fileName = $"{Guid.NewGuid()}{Path.GetExtension(image.FileName)}";
                    var filePath = Path.Combine(uploadsFolder, fileName);
                    
                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        await image.CopyToAsync(stream);
                    }
                    
                    imageUrls.Add($"/uploads/reviews/{fileName}");
                }
            }
        }

        var request = new ReviewSubmissionRequest
        {
            UserId = userId,
            ProductId = productId,
            Rating = rating,
            Title = title,
            Comment = comment,
            QualityRating = qualityRating,
            ValueForMoneyRating = valueForMoneyRating,
            AccuracyRating = accuracyRating,
            ImageUrls = imageUrls
        };

        var result = await _reviewService.SubmitReviewAsync(request);

        if (result.Success)
        {
            TempData["Success"] = result.Message;
            return RedirectToAction("Index", "Profile", new { area = "" });
        }
        else
        {
            TempData["Error"] = result.Message;
            return RedirectToAction("Create", new { productId });
        }
    }

    /// <summary>
    /// Get reviews for a product (public API).
    /// </summary>
    [HttpGet]
    [AllowAnonymous]
    public async Task<IActionResult> ProductReviews(int productId, int page = 1)
    {
        var reviews = await _reviewService.GetProductReviewsAsync(productId, page, 10);
        var stats = await _reviewService.GetProductReviewStatsAsync(productId);

        return Json(new
        {
            reviews = reviews.Select(r => new
            {
                r.Id,
                r.Rating,
                r.Title,
                r.Comment,
                ReviewerName = r.User?.FullName ?? "Customer",
                ReviewDate = r.ReviewDate.ToString("MMM d, yyyy"),
                r.IsVerifiedPurchase,
                r.HelpfulCount,
                Images = r.Images.Select(i => i.ImageUrl).ToList(),
                SellerResponse = r.SellerResponse,
                SellerResponseDate = r.SellerResponseDate?.ToString("MMM d, yyyy")
            }),
            stats = new
            {
                stats.TotalReviews,
                stats.AverageRating,
                stats.FiveStarCount,
                stats.FourStarCount,
                stats.ThreeStarCount,
                stats.TwoStarCount,
                stats.OneStarCount
            }
        });
    }

    /// <summary>
    /// Vote on a review (helpful/not helpful).
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> Vote(int reviewId, bool isHelpful)
    {
        var userId = GetUserId();
        
        // Check if already voted
        var existingVote = await _db.ReviewVotes
            .FirstOrDefaultAsync(v => v.ProductReviewId == reviewId && v.UserId == userId);

        if (existingVote != null)
        {
            return Json(new { success = false, message = "You have already voted on this review" });
        }

        var review = await _db.ProductReviews.FindAsync(reviewId);
        if (review == null)
            return NotFound();

        var vote = new Sparkle.Domain.Reviews.ReviewVote
        {
            ProductReviewId = reviewId,
            UserId = userId,
            IsHelpful = isHelpful,
            VotedAt = DateTime.UtcNow
        };

        _db.ReviewVotes.Add(vote);
        
        if (isHelpful)
            review.HelpfulCount++;
        else
            review.NotHelpfulCount++;

        await _db.SaveChangesAsync();

        return Json(new { success = true, helpfulCount = review.HelpfulCount });
    }

    /// <summary>
    /// Report a review.
    /// </summary>
    [HttpPost]
    public async Task<IActionResult> Report(int reviewId, string reason)
    {
        var review = await _db.ProductReviews.FindAsync(reviewId);
        if (review == null)
            return NotFound();

        review.ReportCount++;
        
        // If report count exceeds threshold, flag for moderation
        if (review.ReportCount >= 3)
        {
            review.Status = "PendingModeration";
        }

        await _db.SaveChangesAsync();
        
        _logger.LogInformation("Review {ReviewId} reported by user. Reason: {Reason}", reviewId, reason);

        return Json(new { success = true, message = "Thank you for your report. We will review it shortly." });
    }
}
