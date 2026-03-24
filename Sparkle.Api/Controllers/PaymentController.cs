using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Sparkle.Infrastructure.Services;
using Sparkle.Infrastructure;

using Sparkle.Domain.Orders;

namespace Sparkle.Api.Controllers;

public class PaymentController : Controller
{
    private readonly ApplicationDbContext _db;
    private readonly IPaymentService _paymentService;

    public PaymentController(ApplicationDbContext db, IPaymentService paymentService)
    {
        _db = db;
        _paymentService = paymentService;
    }

    // Gateway Dispatcher
    [HttpGet("payment/gateway")]
    public IActionResult Gateway(string method, string orderIds, decimal amount)
    {
        ViewBag.OrderIds = orderIds;
        ViewBag.Amount = amount;
        
        return method.ToLower() switch
        {
            "bkash" => View("Bkash"),
            "nagad" => View("Nagad"),
            "rocket" => View("Rocket"),
            "card" => RedirectToAction("MockGateway", new { orderIds = orderIds, amount = amount, trxIdx = "TRX-INIT-CARD" }),
            "instalment" => View("Instalment"),
            _ => RedirectToAction("Confirmation", "Order", new { ids = orderIds })
        };
    }

    [HttpPost("payment/process")]
    public async Task<IActionResult> ProcessPayment(string orderIds, string status)
    {
         if (status == "success")
         {
             var ids = orderIds.Split(',').Select(int.Parse).ToList();
             var orders = await _db.Orders.Where(o => ids.Contains(o.Id)).ToListAsync();
             foreach(var order in orders)
             {
                 order.PaymentStatus = PaymentStatus.Paid;
                 order.PaymentTransactionId = "TRX-" + Guid.NewGuid().ToString().Substring(0,8).ToUpper();
                 order.PaidAt = DateTime.UtcNow;
             }
             await _db.SaveChangesAsync();
             return RedirectToAction("Confirmation", "Order", new { ids = orderIds });
         }
         else
         {
             return View("Failed", (object)orderIds);
         }
    }

    // Generic Mock Gateway Page for Card/SSLCommerz Simulation
    [HttpGet("payment/mock-gateway")]
    public IActionResult MockGateway(string orderIds, decimal amount, string trxIdx)
    {
        ViewBag.OrderIds = orderIds; // Changed from OrderId to OrderIds
        ViewBag.Amount = amount;
        ViewBag.TrxIdx = trxIdx;
        return View(); 
    }
}
