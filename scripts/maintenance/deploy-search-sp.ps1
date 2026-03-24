$serverName = "localhost\SQLEXPRESS"
$databaseName = "SparkleEcommerce"

$dropSql = @"
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[catalog].[usp_SearchProducts]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [catalog].[usp_SearchProducts];
END
"@

$createSql = @"
CREATE PROCEDURE [catalog].[usp_SearchProducts]
    @CategoryId INT = NULL,
    @SearchTerm NVARCHAR(255) = NULL,
    @MinPrice DECIMAL(18,2) = NULL,
    @MaxPrice DECIMAL(18,2) = NULL,
    @AttributeFilters NVARCHAR(MAX) = NULL,
    @SortBy NVARCHAR(50) = 'Relevance',
    @PageNumber INT = 1,
    @PageSize INT = 20
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @FilterTable TABLE (FieldKey NVARCHAR(50), FilterValue NVARCHAR(MAX));
    
    IF @AttributeFilters IS NOT NULL
    BEGIN
        INSERT INTO @FilterTable (FieldKey, FilterValue)
        SELECT [Key], [Value] FROM OPENJSON(@AttributeFilters)
        WITH ([Key] NVARCHAR(50), [Value] NVARCHAR(MAX));
    END

    -- Calculate max values for smart scoring normalization
    DECLARE @MaxReviews INT, @MaxPriceValue DECIMAL(18,2);
    SELECT @MaxReviews = MAX(TotalReviews), @MaxPriceValue = MAX(BasePrice)
    FROM [catalog].[Products]
    WHERE IsActive = 1;

    SELECT 
        p.Id,
        p.Title,
        p.ShortDescription,
        p.BasePrice,
        p.DiscountPercent,
        (SELECT TOP 1 Url FROM [catalog].[ProductImages] pi WHERE pi.ProductId = p.Id ORDER BY pi.SortOrder) as Thumbnail,
        (SELECT SUM(Stock) FROM [catalog].[ProductVariants] pv WHERE pv.ProductId = p.Id) as StockQuantity,
        p.Slug,
        c.Name as CategoryName,
        s.ShopName as SellerName,
        
        -- Basic Relevance Score (backward compatibility)
        (CASE WHEN p.Title LIKE '%' + @SearchTerm + '%' THEN 10 ELSE 0 END +
         CASE WHEN p.Description LIKE '%' + @SearchTerm + '%' THEN 5 ELSE 0 END) as Relevance,
        
        -- AI CONFIDENCE SCORE (0-100)
        CAST((
            -- Rating Score (25 points)
            (ISNULL(p.AverageRating, 0) / 5.0 * 25) +
            
            -- Popularity Score (20 points)
            (CAST(ISNULL(p.TotalReviews, 0) AS FLOAT) / NULLIF(@MaxReviews, 0) * 20) +
            
            -- Discount/Value Score (20 points)
            (CASE 
                WHEN ISNULL(p.DiscountPercent, 0) >= 30 THEN 20
                WHEN ISNULL(p.DiscountPercent, 0) >= 20 THEN 15
                WHEN ISNULL(p.DiscountPercent, 0) >= 10 THEN 10
                ELSE 5
            END) +
            
            -- Price Competitiveness (15 points)
            (CASE
                WHEN (p.BasePrice * (1 - ISNULL(p.DiscountPercent,0)/100.0)) <= @MaxPriceValue * 0.3 THEN 15
                WHEN (p.BasePrice * (1 - ISNULL(p.DiscountPercent,0)/100.0)) <= @MaxPriceValue * 0.5 THEN 10
                ELSE 5
            END) +
            
            -- Search Relevance (20 points)
            (CASE 
                WHEN @SearchTerm IS NULL THEN 10
                WHEN p.Title = @SearchTerm THEN 20
                WHEN p.Title LIKE @SearchTerm + '%' THEN 18
                WHEN p.Title LIKE '%' + @SearchTerm + '%' THEN 15
                WHEN SOUNDEX(p.Title) = SOUNDEX(@SearchTerm) THEN 12
                WHEN p.Description LIKE '%' + @SearchTerm + '%' THEN 10
                ELSE 0
            END)
        ) AS INT) as ConfidenceScore,
        
        -- Smart Tags (comma-separated string)
        (SELECT STRING_AGG(tag, ',') FROM (
            SELECT 'Best match' as tag WHERE p.Title LIKE '%' + @SearchTerm + '%' AND @SearchTerm IS NOT NULL
            UNION ALL
            SELECT 'Trending' WHERE ISNULL(p.TotalReviews, 0) > (@MaxReviews * 0.5)
            UNION ALL
            SELECT 'Recommended' WHERE ISNULL(p.AverageRating, 0) >= 4.5
            UNION ALL
            SELECT 'Best value' WHERE ISNULL(p.DiscountPercent, 0) >= 30
            UNION ALL
            SELECT 'Popular choice' WHERE ISNULL(p.TotalReviews, 0) > (@MaxReviews * 0.3)
            UNION ALL
            SELECT 'High performance match' WHERE ISNULL(p.AverageRating, 0) >= 4.0 AND ISNULL(p.TotalReviews, 0) > 10
        ) tags) as SmartTags,
        
        -- Personalization Level (null for now, will be enhanced with user history)
        CAST(NULL AS NVARCHAR(50)) as PersonalizationLevel,
        
        -- Fuzzy Match Indicator
        CAST(CASE 
            WHEN @SearchTerm IS NOT NULL 
                AND SOUNDEX(p.Title) = SOUNDEX(@SearchTerm) 
                AND p.Title NOT LIKE '%' + @SearchTerm + '%' 
            THEN 1 
            ELSE 0 
        END AS BIT) as IsFuzzyMatch
        
    FROM [catalog].[Products] p
    INNER JOIN [catalog].[Categories] c ON p.CategoryId = c.Id
    INNER JOIN [sellers].[Sellers] s ON p.SellerId = s.Id
    WHERE p.IsActive = 1
    AND (@CategoryId IS NULL OR p.CategoryId = @CategoryId)
    AND (@MinPrice IS NULL OR (p.BasePrice * (1 - ISNULL(p.DiscountPercent,0)/100.0)) >= @MinPrice)
    AND (@MaxPrice IS NULL OR (p.BasePrice * (1 - ISNULL(p.DiscountPercent,0)/100.0)) <= @MaxPrice)
    AND (@SearchTerm IS NULL OR 
         p.Title LIKE '%' + @SearchTerm + '%' OR 
         p.Description LIKE '%' + @SearchTerm + '%' OR
         SOUNDEX(p.Title) = SOUNDEX(@SearchTerm))
    AND NOT EXISTS (
        SELECT 1 FROM @FilterTable ft
        WHERE NOT EXISTS (
            SELECT 1 
            FROM [dynamic].[FormData] fe
            JOIN [dynamic].[FormDataFieldValues] fv ON fe.Id = fv.EntryId
            JOIN [dynamic].[FormFieldMaster] ff ON fv.FieldId = ff.Id
            WHERE fe.ReferenceType = 'Product' 
            AND fe.ReferenceId = CAST(p.Id AS NVARCHAR(50))
            AND ff.Name = ft.FieldKey
            AND fv.Value = ft.FilterValue
        )
    )
    ORDER BY 
        CASE WHEN @SortBy = 'PriceLowHigh' THEN (p.BasePrice * (1 - ISNULL(p.DiscountPercent,0)/100.0)) END ASC,
        CASE WHEN @SortBy = 'PriceHighLow' THEN (p.BasePrice * (1 - ISNULL(p.DiscountPercent,0)/100.0)) END DESC,
        CASE WHEN @SortBy = 'Relevance' THEN ConfidenceScore END DESC,
        p.CreatedAt DESC
    
    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END
"@

try {
    Write-Host "Deploying updated search stored procedure..." -ForegroundColor Cyan
    
    # Drop the existing procedure
    Invoke-Sqlcmd -ServerInstance $serverName -Database $databaseName -Query $dropSql
    Write-Host "[OK] Dropped existing procedure" -ForegroundColor Gray
    
    # Create the new procedure
    Invoke-Sqlcmd -ServerInstance $serverName -Database $databaseName -Query $createSql
    Write-Host "[OK] Created new procedure with AI features" -ForegroundColor Gray
    
    Write-Host "â Enhanced search deployed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "â Error: $_" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
