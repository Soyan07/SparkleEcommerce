using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using Sparkle.Domain.Orders;
using Sparkle.Infrastructure;
using Microsoft.EntityFrameworkCore;

namespace Sparkle.Api.Services;

public interface IInvoiceService
{
    Task<byte[]> GenerateOrderInvoiceAsync(int orderId);
    Task<string> GetInvoicePathAsync(int orderId);
}

public class InvoiceService : IInvoiceService
{
    private readonly ApplicationDbContext _db;
    private readonly ILogger<InvoiceService> _logger;
    private readonly string _invoiceDirectory;

    public InvoiceService(ApplicationDbContext db, ILogger<InvoiceService> logger, IWebHostEnvironment env)
    {
        _db = db;
        _logger = logger;
        _invoiceDirectory = Path.Combine(env.WebRootPath, "invoices");
        
        if (!Directory.Exists(_invoiceDirectory))
        {
            Directory.CreateDirectory(_invoiceDirectory);
        }
        
        // Configure QuestPDF license
        QuestPDF.Settings.License = LicenseType.Community;
    }

    public async Task<byte[]> GenerateOrderInvoiceAsync(int orderId)
    {
        var order = await _db.Orders
            .Include(o => o.User)
            .Include(o => o.Seller)
            .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Product)
            .Include(o => o.ShippingAddress)
            .FirstOrDefaultAsync(o => o.Id == orderId);

        if (order == null)
        {
            throw new Exception($"Order {orderId} not found");
        }

        var document = Document.Create(container =>
        {
            container.Page(page =>
            {
                page.Size(PageSizes.A4);
                page.Margin(2, Unit.Centimetre);
                page.PageColor(Colors.White);
                page.DefaultTextStyle(x => x.FontSize(11));

                page.Header()
                    .Element(ComposeHeader);

                page.Content()
                    .Element(c => ComposeContent(c, order));

                page.Footer()
                    .AlignCenter()
                    .Text(x =>
                    {
                        x.Span("Page ");
                        x.CurrentPageNumber();
                        x.Span(" of ");
                        x.TotalPages();
                    });
            });
        });

        return document.GeneratePdf();
    }

    public async Task<string> GetInvoicePathAsync(int orderId)
    {
        var fileName = $"Invoice_Order_{orderId}_{DateTime.UtcNow:yyyyMMdd}.pdf";
        var filePath = Path.Combine(_invoiceDirectory, fileName);

        if (!File.Exists(filePath))
        {
            var pdfBytes = await GenerateOrderInvoiceAsync(orderId);
            await File.WriteAllBytesAsync(filePath, pdfBytes);
        }

        return filePath;
    }

    private void ComposeHeader(IContainer container)
    {
        container.Column(column =>
        {
            column.Spacing(10);

            // Logo and company name row
            column.Item().Row(row =>
            {
                // Logo section (left)
                row.ConstantItem(100).Height(60).Border(1).BorderColor(Colors.Grey.Lighten2)
                    .Padding(5).AlignCenter().AlignMiddle().Text("SPARKLE")
                    .FontSize(20).Bold().FontColor(Colors.Blue.Medium);

                row.RelativeItem().PaddingLeft(20).Column(col =>
                {
                    col.Item().Text("SPARKLE E-COMMERCE").FontSize(24).Bold().FontColor(Colors.Blue.Darken2);
                    col.Item().Text("Your Trusted Marketplace").FontSize(11).Italic().FontColor(Colors.Grey.Darken1);
                    col.Item().PaddingTop(5).Text(text =>
                    {
                        text.Span("📍 ").FontSize(10);
                        text.Span("Dhaka, Bangladesh").FontSize(10);
                    });
                });

                // Invoice label (right)
                row.ConstantItem(150).AlignRight().Column(col =>
                {
                    col.Item().Background(Colors.Blue.Medium).Padding(8).AlignCenter()
                        .Text("TAX INVOICE").FontSize(16).Bold().FontColor(Colors.White);
                    col.Item().PaddingTop(5).AlignRight().Text(text =>
                    {
                        text.Span("Date: ").SemiBold().FontSize(9);
                        text.Span($"{DateTime.UtcNow:dd MMM yyyy}").FontSize(9);
                    });
                });
            });

            // Contact information bar
            column.Item().PaddingTop(10).Background(Colors.Grey.Lighten3).Padding(8)
                .Row(row =>
                {
                    row.RelativeItem().Text(text =>
                    {
                        text.Span("📞 ").FontSize(9);
                        text.Span("+880 1234-567890").FontSize(9);
                    });
                    row.RelativeItem().AlignCenter().Text(text =>
                    {
                        text.Span("📧 ").FontSize(9);
                        text.Span("support@sparkle.com").FontSize(9);
                    });
                    row.RelativeItem().AlignRight().Text(text =>
                    {
                        text.Span("🌐 ").FontSize(9);
                        text.Span("www.sparkle.com").FontSize(9);
                    });
                });

            // Divider
            column.Item().PaddingTop(5).BorderBottom(2).BorderColor(Colors.Blue.Medium);
        });
    }

    private void ComposeContent(IContainer container, Order order)
    {
        container.PaddingVertical(20).Column(column =>
        {
            column.Spacing(10);

            // Order Information
            column.Item().Element(c => ComposeOrderInfo(c, order));

            // Bill To / Ship To
            column.Item().Element(c => ComposeAddresses(c, order));

            // Order Items Table
            column.Item().Element(c => ComposeTable(c, order));

            // Summary
            column.Item().Element(c => ComposeSummary(c, order));

            // Footer Notes
            column.Item().PaddingTop(20).BorderTop(1).PaddingTop(10).Column(footerColumn =>
            {
                footerColumn.Item().Text("Terms & Conditions:").SemiBold();
                footerColumn.Item().Text("1. All prices are in BDT").FontSize(9);
                footerColumn.Item().Text("2. Goods once sold cannot be returned unless defective").FontSize(9);
                footerColumn.Item().Text("3. Payment due within 7 days of delivery").FontSize(9);
            });
        });
    }

    private void ComposeOrderInfo(IContainer container, Order order)
    {
        container.Background(Colors.Grey.Lighten3).Padding(10).Row(row =>
        {
            row.RelativeItem().Text(text =>
            {
                text.Span("Order #: ").SemiBold();
                text.Span($"{order.OrderNumber}");
            });

            row.RelativeItem().Text(text =>
            {
                text.Span("Order Date: ").SemiBold();
                text.Span($"{order.OrderDate:dd MMM yyyy}");
            });

            row.RelativeItem().Text(text =>
            {
                text.Span("Payment: ").SemiBold();
                text.Span($"{order.PaymentMethod}");
            });

            row.RelativeItem().Text(text =>
            {
                text.Span("Status: ").SemiBold();
                text.Span($"{order.Status}");
            });
        });
    }

    private void ComposeAddresses(IContainer container, Order order)
    {
        container.Row(row =>
        {
            row.RelativeItem().Column(column =>
            {
                column.Item().Text("BILL TO:").SemiBold();
                column.Item().PaddingTop(5).Text(order.User.FullName ?? "");
                column.Item().Text(order.User.Email ?? "");
                column.Item().Text(order.User.PhoneNumber ?? "");
            });

            row.RelativeItem().Column(column =>
            {
                column.Item().Text("SHIP TO:").SemiBold();
                column.Item().PaddingTop(5).Text(order.ShippingAddress?.FullName ?? "");
                column.Item().Text($"{order.ShippingAddress?.Line1 ?? ""}");
                if (!string.IsNullOrEmpty(order.ShippingAddress?.Line2))
                    column.Item().Text(order.ShippingAddress.Line2);
                column.Item().Text($"{order.ShippingAddress?.City ?? ""}, {order.ShippingAddress?.State ?? ""} {order.ShippingAddress?.PostalCode ?? ""}");
                column.Item().Text(order.ShippingAddress?.Phone ?? "");
            });

            row.RelativeItem().Column(column =>
            {
                column.Item().Text("SELLER:").SemiBold();
                column.Item().PaddingTop(5).Text(order.Seller?.ShopName ?? "Sparkle");
                column.Item().Text(order.Seller?.Email ?? "");
                column.Item().Text(order.Seller?.MobileNumber ?? "");
            });
        });
    }

    private void ComposeTable(IContainer container, Order order)
    {
        container.Table(table =>
        {
            table.ColumnsDefinition(columns =>
            {
                columns.ConstantColumn(30);  // #
                columns.RelativeColumn(3);   // Product
                columns.ConstantColumn(60);  // Qty
                columns.ConstantColumn(80);  // Unit Price
                columns.ConstantColumn(80);  // Total
            });

            table.Header(header =>
            {
                header.Cell().Element(CellStyle).Text("#");
                header.Cell().Element(CellStyle).Text("Product");
                header.Cell().Element(CellStyle).AlignRight().Text("Qty");
                header.Cell().Element(CellStyle).AlignRight().Text("Unit Price");
                header.Cell().Element(CellStyle).AlignRight().Text("Total");

                static IContainer CellStyle(IContainer container)
                {
                    return container.DefaultTextStyle(x => x.SemiBold()).PaddingVertical(5).BorderBottom(1).BorderColor(Colors.Black);
                }
            });

            int index = 1;
            foreach (var item in order.OrderItems)
            {
                table.Cell().Element(CellStyle).Text(index++.ToString());
                table.Cell().Element(CellStyle).Text(item.Product?.Name ?? item.ProductName);
                table.Cell().Element(CellStyle).AlignRight().Text(item.Quantity.ToString());
                table.Cell().Element(CellStyle).AlignRight().Text($"৳{item.UnitPrice:N2}");
                table.Cell().Element(CellStyle).AlignRight().Text($"৳{(item.UnitPrice * item.Quantity):N2}");

                static IContainer CellStyle(IContainer container)
                {
                    return container.BorderBottom(1).BorderColor(Colors.Grey.Lighten2).PaddingVertical(5);
                }
            }
        });
    }

    private void ComposeSummary(IContainer container, Order order)
    {
        container.AlignRight().Width(200).Column(column =>
        {
            column.Spacing(5);

            column.Item().Row(row =>
            {
                row.RelativeItem().Text("Subtotal:");
                row.RelativeItem().AlignRight().Text($"৳{order.SubTotal:N2}");
            });

            column.Item().Row(row =>
            {
                row.RelativeItem().Text("Shipping:");
                row.RelativeItem().AlignRight().Text($"৳{order.ShippingCost:N2}");
            });

            if (order.DiscountAmount > 0)
            {
                column.Item().Row(row =>
                {
                    row.RelativeItem().Text("Discount:");
                    row.RelativeItem().AlignRight().Text($"-৳{order.DiscountAmount:N2}").FontColor(Colors.Green.Medium);
                });
            }

            column.Item().PaddingTop(5).BorderTop(1).Row(row =>
            {
                row.RelativeItem().Text("GRAND TOTAL:").SemiBold().FontSize(12);
                row.RelativeItem().AlignRight().Text($"৳{order.TotalAmount:N2}").SemiBold().FontSize(12).FontColor(Colors.Blue.Medium);
            });
        });
    }
}
