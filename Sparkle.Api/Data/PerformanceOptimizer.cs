using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Sparkle.Infrastructure;


namespace Sparkle.Api.Data;

public static class PerformanceOptimizer
{
    public static async Task OptimizeDatabaseAsync(ApplicationDbContext db)
    {
        // Execute raw SQL to create indexes if they don't exist
        // Using Check-Before-Create pattern to prevent EF Core "Fail" logs
        
        // Products Indexes
        await EnsureIndexAsync(db, "[catalog].[Products]", "IX_Products_IsActive", 
            "CREATE INDEX [IX_Products_IsActive] ON [catalog].[Products] ([IsActive])");
            
        await EnsureIndexAsync(db, "[catalog].[Products]", "IX_Products_Price",
            "CREATE INDEX [IX_Products_Price] ON [catalog].[Products] ([BasePrice])");

        await EnsureIndexAsync(db, "[catalog].[Products]", "IX_Products_CreatedAt",
            "CREATE INDEX [IX_Products_CreatedAt] ON [catalog].[Products] ([CreatedAt] DESC)");

        // Orders Indexes
        await EnsureIndexAsync(db, "[orders].[Orders]", "IX_Orders_IsDeleted_Status",
            "CREATE INDEX [IX_Orders_IsDeleted_Status] ON [orders].[Orders] ([IsDeleted], [Status])");

        await EnsureIndexAsync(db, "[orders].[Orders]", "IX_Orders_OrderDate",
            "CREATE INDEX [IX_Orders_OrderDate] ON [orders].[Orders] ([OrderDate] DESC)");

        // Activity Logs
        await EnsureIndexAsync(db, "[system].[ActivityLogs]", "IX_ActivityLogs_Timestamp",
            "CREATE INDEX [IX_ActivityLogs_Timestamp] ON [system].[ActivityLogs] ([Timestamp] DESC)");
    }

    private static async Task EnsureIndexAsync(ApplicationDbContext db, string tableName, string indexName, string createSql)
    {
        // Wrap command in IF NOT EXISTS execution block to make it idempotent and prevent EF Core failure logs
        // This avoids the race conditions and complexity of checking first in C#
        var sql = $@"
            IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = '{indexName}' AND object_id = OBJECT_ID('{tableName}'))
            BEGIN
                {createSql};
            END";

        await db.Database.ExecuteSqlRawAsync(sql);
    }
}
