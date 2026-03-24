using Sparkle.Domain.Orders;
using System.Threading.Tasks;

namespace Sparkle.Infrastructure.Services;

public class SSLCommerzService : IPaymentService
{
    public Task<string> InitiatePaymentAsync(Order order)
    {
        // Mock URL pointing to our own internal controller
        // In production, this would call the SSLCommerz API
        return Task.FromResult($"/payment/mock-gateway?orderId={order.Id}&amount={order.TotalAmount}&trxIdx={order.OrderNumber}");
    }

    public Task<bool> ValidatePaymentAsync(string transactionId)
    {
        // Always return true for mock
        return Task.FromResult(true);
    }
}
