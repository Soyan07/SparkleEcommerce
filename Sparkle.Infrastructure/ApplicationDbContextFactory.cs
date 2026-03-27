using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Npgsql.EntityFrameworkCore.PostgreSQL;
using System;

namespace Sparkle.Infrastructure;

public class ApplicationDbContextFactory : IDesignTimeDbContextFactory<ApplicationDbContext>
{
    public ApplicationDbContext CreateDbContext(string[] args)
    {
        var optionsBuilder = new DbContextOptionsBuilder<ApplicationDbContext>();
        
        var connectionString = Environment.GetEnvironmentVariable("ConnectionStrings__DefaultConnection") 
            ?? "Data Source=.\\SQLEXPRESS;Initial Catalog=SparkleEcommerce;Integrated Security=True;TrustServerCertificate=True;MultipleActiveResultSets=true;Encrypt=False;Command Timeout=180;Connect Timeout=60";
        
        var isPostgreSQL = connectionString.Contains("Host=", StringComparison.OrdinalIgnoreCase) ||
                          connectionString.Contains("postgres", StringComparison.OrdinalIgnoreCase);
        
        if (isPostgreSQL)
        {
            Console.WriteLine($"[DesignTime] Using PostgreSQL: {connectionString.Split(';')[0]}...");
            optionsBuilder.UseNpgsql(connectionString, npgsqlOptions =>
            {
                npgsqlOptions.CommandTimeout(180);
            });
        }
        else
        {
            Console.WriteLine($"[DesignTime] Using SQL Server: Data Source (redacted)");
            optionsBuilder.UseSqlServer(connectionString, sqlOptions =>
            {
                sqlOptions.CommandTimeout(180);
            });
        }
        
        return new ApplicationDbContext(optionsBuilder.Options);
    }
}
