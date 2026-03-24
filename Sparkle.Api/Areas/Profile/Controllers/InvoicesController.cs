using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using Sparkle.Api.Services;

namespace Sparkle.Api.Areas.Profile.Controllers;

[Area("Profile")]
[Authorize]
public class InvoicesController : Controller
{
    private readonly IInvoiceService _invoiceService;
    private readonly ILogger<InvoicesController> _logger;

    public InvoicesController(IInvoiceService invoiceService, ILogger<InvoicesController> logger)
    {
        _invoiceService = invoiceService;
        _logger = logger;
    }

    // GET: /Profile/Invoices/Download/5
    [HttpGet("Profile/Invoices/Download/{orderId}")]
    public async Task<IActionResult> Download(int orderId)
    {
        try
        {
            var pdfBytes = await _invoiceService.GenerateOrderInvoiceAsync(orderId);
            var fileName = $"Invoice_Order_{orderId}_{DateTime.UtcNow:yyyyMMdd}.pdf";
            
            return File(pdfBytes, "application/pdf", fileName);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error generating invoice for order {OrderId}", orderId);
            TempData["Error"] = "Unable to generate invoice. Please try again.";
            return RedirectToAction("Details", "Orders", new { id = orderId });
        }
    }

    // GET: /Profile/Invoices/View/5
    [HttpGet("Profile/Invoices/View/{orderId}")]
    public async Task<IActionResult> View(int orderId)
    {
        try
        {
            var pdfBytes = await _invoiceService.GenerateOrderInvoiceAsync(orderId);
            return File(pdfBytes, "application/pdf");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error viewing invoice for order {OrderId}", orderId);
            return StatusCode(500, "Error generating invoice");
        }
    }
}
