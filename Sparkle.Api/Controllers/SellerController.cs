using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Sparkle.Infrastructure;
using Sparkle.Domain.Sellers;

namespace Sparkle.Api.Controllers;

public class SellerController : Controller
{
    private readonly ApplicationDbContext _db;

    public SellerController(ApplicationDbContext db)
    {
        _db = db;
    }

    [HttpGet]
    [Route("shop/{id}")]
    public async Task<IActionResult> Index(int id)
    {
        var seller = await _db.Sellers
            .FirstOrDefaultAsync(s => s.Id == id && s.Status == SellerStatus.Approved);

        if (seller == null)
        {
            return NotFound();
        }

        var products = await _db.Products
            .Include(p => p.Images)
            .Include(p => p.Variants)
            .Include(p => p.Category)
            .Where(p => p.SellerId == id && p.IsActive)
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();

        ViewBag.Products = products;
        return View(seller);
    }
}
