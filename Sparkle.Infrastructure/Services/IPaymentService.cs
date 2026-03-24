using Sparkle.Domain.Orders;
using System.Threading.Tasks;

namespace Sparkle.Infrastructure.Services;

public interface IPaymentService
{
    Task<string> InitiatePaymentAsync(Order order);
    Task<bool> ValidatePaymentAsync(string transactionId);
}
