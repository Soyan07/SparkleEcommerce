using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Sparkle.Api.Areas.Seller.Controllers;

[Area("Seller")]
[Authorize(Roles = "Seller")]
public class PlatformPartnerController : Controller
{
    public IActionResult Index()
    {
        return View();
    }
}
