using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Sparkle.Api.Areas.Seller.Controllers;

[Area("Seller")]
[Authorize(Roles = "Seller")]
public class HelpSupportController : Controller
{
    public IActionResult Index()
    {
        return View();
    }
}
