using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Storage;
using System;
using System.Threading.Tasks;

namespace Sparkle.Api.Data;

public enum DatabaseType
{
    Unknown,
    SqlServer,
    PostgreSQL
}

public static class DatabaseHelper
{
    public static DatabaseType DetectDatabaseType(DbContext context)
    {
        var providerName = context.Database.ProviderName ?? string.Empty;
        
        if (providerName.Contains("SqlServer", StringComparison.OrdinalIgnoreCase))
            return DatabaseType.SqlServer;
        else if (providerName.Contains("Npgsql", StringComparison.OrdinalIgnoreCase) || 
                 providerName.Contains("PostgreSQL", StringComparison.OrdinalIgnoreCase))
            return DatabaseType.PostgreSQL;
        
        return DatabaseType.Unknown;
    }
    
    public static bool IsPostgreSQL(DbContext context)
    {
        return DetectDatabaseType(context) == DatabaseType.PostgreSQL;
    }
    
    public static async Task<bool> ColumnExistsAsync(DbContext context, string schema, string table, string column)
    {
        var isPostgres = IsPostgreSQL(context);
        
        try
        {
            string sql;
            if (isPostgres)
            {
                sql = $@"
                    SELECT EXISTS (
                        SELECT 1 FROM information_schema.columns 
                        WHERE table_schema = '{schema}' 
                        AND table_name = '{table}' 
                        AND column_name = '{column}'
                    )";
            }
            else
            {
                sql = $@"
                    IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[{schema}].[{table}]') AND name = '{column}')
                        SELECT 1
                    ELSE
                        SELECT 0";
            }
            
            var result = await context.Database.ExecuteSqlRawAsync(sql);
            return result > 0;
        }
        catch
        {
            return false;
        }
    }
    
    public static async Task<bool> TableExistsAsync(DbContext context, string schema, string table)
    {
        var isPostgres = IsPostgreSQL(context);
        
        try
        {
            string sql;
            if (isPostgres)
            {
                sql = $@"
                    SELECT EXISTS (
                        SELECT 1 FROM information_schema.tables 
                        WHERE table_schema = '{schema}' 
                        AND table_name = '{table}'
                    )";
            }
            else
            {
                sql = $@"
                    IF OBJECT_ID('[{schema}].[{table}]', 'U') IS NOT NULL
                        SELECT 1
                    ELSE
                        SELECT 0";
            }
            
            var result = await context.Database.ExecuteSqlRawAsync(sql);
            return result > 0;
        }
        catch
        {
            return false;
        }
    }
    
    public static async Task<bool> SchemaExistsAsync(DbContext context, string schemaName)
    {
        var isPostgres = IsPostgreSQL(context);
        
        try
        {
            string sql;
            if (isPostgres)
            {
                sql = $@"
                    SELECT EXISTS (
                        SELECT 1 FROM information_schema.schemata 
                        WHERE schema_name = '{schemaName}'
                    )";
            }
            else
            {
                sql = $@"
                    IF EXISTS (SELECT * FROM sys.schemas WHERE name = '{schemaName}')
                        SELECT 1
                    ELSE
                        SELECT 0";
            }
            
            var result = await context.Database.ExecuteSqlRawAsync(sql);
            return result > 0;
        }
        catch
        {
            return false;
        }
    }
}
