-- Script to add 150+ additional products to reach 200+ total
-- Run with: sqlcmd -S .\SQLEXPRESS -d SparkleEcommerce -i "database\add_products.sql"

DECLARE @SellerId INT, @CategoryId INT, @ProductId INT, @i INT = 1

-- Get a random seller for each product
DECLARE @SellerCount INT = (SELECT COUNT(*) FROM [sellers].[Sellers])

-- Electronics Products (Category 1)
SET @CategoryId = 1
SET @SellerId = (SELECT TOP 1 Id FROM [sellers].[Sellers] ORDER BY NEWID())

WHILE @i <= 15
BEGIN
    INSERT INTO [catalog].[Products] (Title, Slug, ShortDescription, Description, BasePrice, DiscountPercent, CategoryId, SellerId, IsActive, AverageRating, TotalReviews, ViewCount, PurchaseCount, CreatedAt)
    VALUES 
    (CASE @i 
        WHEN 1 THEN 'Xiaomi Mi Band 8 Smart Fitness Tracker'
        WHEN 2 THEN 'JBL Flip 6 Portable Bluetooth Speaker'
        WHEN 3 THEN 'Anker PowerCore 20000mAh Power Bank'
        WHEN 4 THEN 'TP-Link Archer AX73 WiFi 6 Router'
        WHEN 5 THEN 'Logitech G502 HERO Gaming Mouse'
        WHEN 6 THEN 'SanDisk Ultra 256GB USB 3.0 Flash Drive'
        WHEN 7 THEN 'Sony Alpha A6400 Mirrorless Camera'
        WHEN 8 THEN 'DJI Mini 3 Pro Drone 4K Camera'
        WHEN 9 THEN 'Samsung T7 1TB Portable SSD'
        WHEN 10 THEN 'Razer BlackWidow V3 Mechanical Keyboard'
        WHEN 11 THEN 'Bose QuietComfort 45 Headphones'
        WHEN 12 THEN 'GoPro HERO12 Black Action Camera'
        WHEN 13 THEN 'Nintendo Switch OLED Model'
        WHEN 14 THEN 'Marshall Stanmore III Bluetooth Speaker'
        WHEN 15 THEN 'Ring Video Doorbell Pro 2'
    END,
    LOWER(REPLACE(CASE @i 
        WHEN 1 THEN 'Xiaomi Mi Band 8 Smart Fitness Tracker'
        WHEN 2 THEN 'JBL Flip 6 Portable Bluetooth Speaker'
        WHEN 3 THEN 'Anker PowerCore 20000mAh Power Bank'
        WHEN 4 THEN 'TP-Link Archer AX73 WiFi 6 Router'
        WHEN 5 THEN 'Logitech G502 HERO Gaming Mouse'
        WHEN 6 THEN 'SanDisk Ultra 256GB USB 3.0 Flash Drive'
        WHEN 7 THEN 'Sony Alpha A6400 Mirrorless Camera'
        WHEN 8 THEN 'DJI Mini 3 Pro Drone 4K Camera'
        WHEN 9 THEN 'Samsung T7 1TB Portable SSD'
        WHEN 10 THEN 'Razer BlackWidow V3 Mechanical Keyboard'
        WHEN 11 THEN 'Bose QuietComfort 45 Headphones'
        WHEN 12 THEN 'GoPro HERO12 Black Action Camera'
        WHEN 13 THEN 'Nintendo Switch OLED Model'
        WHEN 14 THEN 'Marshall Stanmore III Bluetooth Speaker'
        WHEN 15 THEN 'Ring Video Doorbell Pro 2'
    END, ' ', '-')) + '-' + CAST(ABS(CHECKSUM(NEWID())) % 9999 AS VARCHAR),
    'High quality electronics product with premium features',
    'This premium electronics product offers exceptional performance and reliability. Features advanced technology and durable build quality.',
    (ABS(CHECKSUM(NEWID())) % 15000) + 1000,
    (ABS(CHECKSUM(NEWID())) % 25),
    @CategoryId,
    (SELECT TOP 1 Id FROM [sellers].[Sellers] ORDER BY NEWID()),
    1, 4.0 + (CAST(ABS(CHECKSUM(NEWID())) % 10 AS DECIMAL)/10), 
    (ABS(CHECKSUM(NEWID())) % 500) + 50, 0, 0, DATEADD(day, -(ABS(CHECKSUM(NEWID())) % 30), GETUTCDATE()))
    
    SET @ProductId = SCOPE_IDENTITY()
    INSERT INTO [catalog].[ProductImages] (ProductId, Url, SortOrder) VALUES (@ProductId, 'https://via.placeholder.com/600x600/' + RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 999999 AS VARCHAR), 6) + '/ffffff?text=Electronics', 0)
    INSERT INTO [catalog].[ProductVariants] (ProductId, Color, Price, Stock, Sku) VALUES (@ProductId, 'Black', (ABS(CHECKSUM(NEWID())) % 15000) + 1000, (ABS(CHECKSUM(NEWID())) % 100) + 10, 'ELEC-' + CAST(@ProductId AS VARCHAR))
    SET @i = @i + 1
END

-- Fashion Products (Category 3)
SET @CategoryId = 3
SET @i = 1
WHILE @i <= 20
BEGIN
    INSERT INTO [catalog].[Products] (Title, Slug, ShortDescription, Description, BasePrice, DiscountPercent, CategoryId, SellerId, IsActive, AverageRating, TotalReviews, ViewCount, PurchaseCount, CreatedAt)
    VALUES 
    (CASE @i % 10
        WHEN 1 THEN 'Premium Slim Fit Formal Shirt - Men'
        WHEN 2 THEN 'Designer Silk Saree with Blouse Piece'
        WHEN 3 THEN 'Leather Belt Premium Quality - Brown'
        WHEN 4 THEN 'Cotton Casual Polo T-Shirt'
        WHEN 5 THEN 'Denim Jeans Slim Fit - Dark Blue'
        WHEN 6 THEN 'Ladies Kurti Embroidered Cotton'
        WHEN 7 THEN 'Sports Running Shoes - Lightweight'
        WHEN 8 THEN 'Winter Jacket Windproof - Men'
        WHEN 9 THEN 'Formal Blazer Slim Fit - Navy'
        ELSE 'Summer Dress Floral Print - Women'
    END + ' #' + CAST(@i AS VARCHAR),
    'fashion-item-' + CAST(@i AS VARCHAR) + '-' + CAST(ABS(CHECKSUM(NEWID())) % 9999 AS VARCHAR),
    'Trendy fashion item with premium quality fabric',
    'Premium quality fashion item designed for style and comfort. Made with high-quality materials for durability.',
    (ABS(CHECKSUM(NEWID())) % 3000) + 500,
    (ABS(CHECKSUM(NEWID())) % 40),
    @CategoryId,
    (SELECT TOP 1 Id FROM [sellers].[Sellers] ORDER BY NEWID()),
    1, 4.0 + (CAST(ABS(CHECKSUM(NEWID())) % 10 AS DECIMAL)/10),
    (ABS(CHECKSUM(NEWID())) % 800) + 100, 0, 0, DATEADD(day, -(ABS(CHECKSUM(NEWID())) % 30), GETUTCDATE()))
    
    SET @ProductId = SCOPE_IDENTITY()
    INSERT INTO [catalog].[ProductImages] (ProductId, Url, SortOrder) VALUES (@ProductId, 'https://via.placeholder.com/600x600/' + RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 999999 AS VARCHAR), 6) + '/ffffff?text=Fashion', 0)
    INSERT INTO [catalog].[ProductVariants] (ProductId, Color, Size, Price, Stock, Sku) VALUES (@ProductId, CASE (ABS(CHECKSUM(NEWID())) % 4) WHEN 0 THEN 'Black' WHEN 1 THEN 'White' WHEN 2 THEN 'Navy' ELSE 'Grey' END, CASE (ABS(CHECKSUM(NEWID())) % 4) WHEN 0 THEN 'S' WHEN 1 THEN 'M' WHEN 2 THEN 'L' ELSE 'XL' END, (ABS(CHECKSUM(NEWID())) % 3000) + 500, (ABS(CHECKSUM(NEWID())) % 80) + 20, 'FASH-' + CAST(@ProductId AS VARCHAR))
    SET @i = @i + 1
END

-- Home & Living Products (Category 4)
SET @CategoryId = 4
SET @i = 1
WHILE @i <= 20
BEGIN
    INSERT INTO [catalog].[Products] (Title, Slug, ShortDescription, Description, BasePrice, DiscountPercent, CategoryId, SellerId, IsActive, AverageRating, TotalReviews, ViewCount, PurchaseCount, CreatedAt)
    VALUES 
    (CASE @i % 10
        WHEN 1 THEN 'Decorative Throw Pillow Set of 4'
        WHEN 2 THEN 'Wall Clock Modern Design - Silent'
        WHEN 3 THEN 'Floor Lamp LED Adjustable - Black'
        WHEN 4 THEN 'Bathroom Organizer Rack 3-Tier'
        WHEN 5 THEN 'Kitchen Storage Containers Set'
        WHEN 6 THEN 'Bedside Table Lamp Touch Control'
        WHEN 7 THEN 'Curtains Blackout 2 Panels Set'
        WHEN 8 THEN 'Area Rug Modern Geometric Pattern'
        WHEN 9 THEN 'Wall Shelves Floating Set of 3'
        ELSE 'Photo Frame Collage Wall Mount'
    END + ' #' + CAST(@i AS VARCHAR),
    'home-item-' + CAST(@i AS VARCHAR) + '-' + CAST(ABS(CHECKSUM(NEWID())) % 9999 AS VARCHAR),
    'Beautiful home decor item to enhance your living space',
    'High-quality home decor product designed to beautify your living space. Perfect for modern homes.',
    (ABS(CHECKSUM(NEWID())) % 4000) + 400,
    (ABS(CHECKSUM(NEWID())) % 30),
    @CategoryId,
    (SELECT TOP 1 Id FROM [sellers].[Sellers] ORDER BY NEWID()),
    1, 4.0 + (CAST(ABS(CHECKSUM(NEWID())) % 10 AS DECIMAL)/10),
    (ABS(CHECKSUM(NEWID())) % 600) + 80, 0, 0, DATEADD(day, -(ABS(CHECKSUM(NEWID())) % 30), GETUTCDATE()))
    
    SET @ProductId = SCOPE_IDENTITY()
    INSERT INTO [catalog].[ProductImages] (ProductId, Url, SortOrder) VALUES (@ProductId, 'https://via.placeholder.com/600x600/' + RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 999999 AS VARCHAR), 6) + '/ffffff?text=Home', 0)
    INSERT INTO [catalog].[ProductVariants] (ProductId, Color, Price, Stock, Sku) VALUES (@ProductId, CASE (ABS(CHECKSUM(NEWID())) % 4) WHEN 0 THEN 'White' WHEN 1 THEN 'Brown' WHEN 2 THEN 'Grey' ELSE 'Beige' END, (ABS(CHECKSUM(NEWID())) % 4000) + 400, (ABS(CHECKSUM(NEWID())) % 60) + 15, 'HOME-' + CAST(@ProductId AS VARCHAR))
    SET @i = @i + 1
END

-- Kitchen Products (Category 5)
SET @CategoryId = 5
SET @i = 1
WHILE @i <= 15
BEGIN
    INSERT INTO [catalog].[Products] (Title, Slug, ShortDescription, Description, BasePrice, DiscountPercent, CategoryId, SellerId, IsActive, AverageRating, TotalReviews, ViewCount, PurchaseCount, CreatedAt)
    VALUES 
    (CASE @i % 10
        WHEN 1 THEN 'Non-Stick Cookware Set 10 Pieces'
        WHEN 2 THEN 'Electric Rice Cooker 2.8L'
        WHEN 3 THEN 'Knife Set Stainless Steel 6 Pcs'
        WHEN 4 THEN 'Glass Food Storage Containers'
        WHEN 5 THEN 'Cast Iron Skillet Pan 12 inch'
        WHEN 6 THEN 'Electric Kettle 1.7L Stainless'
        WHEN 7 THEN 'Cutting Board Set Bamboo 3 Pcs'
        WHEN 8 THEN 'Mixing Bowl Set Stainless Steel'
        WHEN 9 THEN 'Pressure Cooker 6 Quart'
        ELSE 'Spice Rack Organizer 20 Jars'
    END + ' #' + CAST(@i AS VARCHAR),
    'kitchen-item-' + CAST(@i AS VARCHAR) + '-' + CAST(ABS(CHECKSUM(NEWID())) % 9999 AS VARCHAR),
    'Essential kitchen item for your cooking needs',
    'High-quality kitchen product designed for everyday cooking. Durable and easy to clean.',
    (ABS(CHECKSUM(NEWID())) % 5000) + 500,
    (ABS(CHECKSUM(NEWID())) % 35),
    @CategoryId,
    (SELECT TOP 1 Id FROM [sellers].[Sellers] ORDER BY NEWID()),
    1, 4.0 + (CAST(ABS(CHECKSUM(NEWID())) % 10 AS DECIMAL)/10),
    (ABS(CHECKSUM(NEWID())) % 400) + 60, 0, 0, DATEADD(day, -(ABS(CHECKSUM(NEWID())) % 30), GETUTCDATE()))
    
    SET @ProductId = SCOPE_IDENTITY()
    INSERT INTO [catalog].[ProductImages] (ProductId, Url, SortOrder) VALUES (@ProductId, 'https://via.placeholder.com/600x600/' + RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 999999 AS VARCHAR), 6) + '/ffffff?text=Kitchen', 0)
    INSERT INTO [catalog].[ProductVariants] (ProductId, Color, Price, Stock, Sku) VALUES (@ProductId, CASE (ABS(CHECKSUM(NEWID())) % 3) WHEN 0 THEN 'Silver' WHEN 1 THEN 'Black' ELSE 'Red' END, (ABS(CHECKSUM(NEWID())) % 5000) + 500, (ABS(CHECKSUM(NEWID())) % 50) + 10, 'KITCH-' + CAST(@ProductId AS VARCHAR))
    SET @i = @i + 1
END

-- Beauty Products (Category 6 if exists, else 1)
SET @CategoryId = ISNULL((SELECT TOP 1 Id FROM [catalog].[Categories] WHERE Name LIKE '%Beauty%'), 6)
SET @i = 1
WHILE @i <= 15
BEGIN
    INSERT INTO [catalog].[Products] (Title, Slug, ShortDescription, Description, BasePrice, DiscountPercent, CategoryId, SellerId, IsActive, AverageRating, TotalReviews, ViewCount, PurchaseCount, CreatedAt)
    VALUES 
    (CASE @i % 10
        WHEN 1 THEN 'Vitamin C Serum Anti-Aging 30ml'
        WHEN 2 THEN 'Hair Dryer Professional 2000W'
        WHEN 3 THEN 'Makeup Brush Set 12 Pieces'
        WHEN 4 THEN 'Face Moisturizer SPF 30 Daily'
        WHEN 5 THEN 'Perfume Eau de Parfum 100ml'
        WHEN 6 THEN 'Hair Straightener Ceramic Plates'
        WHEN 7 THEN 'Lipstick Matte Collection Set'
        WHEN 8 THEN 'Body Lotion Hydrating 500ml'
        WHEN 9 THEN 'Nail Polish Set 12 Colors'
        ELSE 'Eyeshadow Palette 18 Shades'
    END + ' #' + CAST(@i AS VARCHAR),
    'beauty-item-' + CAST(@i AS VARCHAR) + '-' + CAST(ABS(CHECKSUM(NEWID())) % 9999 AS VARCHAR),
    'Premium beauty product for your daily routine',
    'High-quality beauty product formulated with premium ingredients for best results.',
    (ABS(CHECKSUM(NEWID())) % 2500) + 300,
    (ABS(CHECKSUM(NEWID())) % 40),
    @CategoryId,
    (SELECT TOP 1 Id FROM [sellers].[Sellers] ORDER BY NEWID()),
    1, 4.2 + (CAST(ABS(CHECKSUM(NEWID())) % 8 AS DECIMAL)/10),
    (ABS(CHECKSUM(NEWID())) % 700) + 100, 0, 0, DATEADD(day, -(ABS(CHECKSUM(NEWID())) % 30), GETUTCDATE()))
    
    SET @ProductId = SCOPE_IDENTITY()
    INSERT INTO [catalog].[ProductImages] (ProductId, Url, SortOrder) VALUES (@ProductId, 'https://via.placeholder.com/600x600/' + RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 999999 AS VARCHAR), 6) + '/ffffff?text=Beauty', 0)
    INSERT INTO [catalog].[ProductVariants] (ProductId, Price, Stock, Sku) VALUES (@ProductId, (ABS(CHECKSUM(NEWID())) % 2500) + 300, (ABS(CHECKSUM(NEWID())) % 100) + 20, 'BEAUT-' + CAST(@ProductId AS VARCHAR))
    SET @i = @i + 1
END

-- Sports & Fitness Products (multiple categories)
SET @CategoryId = ISNULL((SELECT TOP 1 Id FROM [catalog].[Categories] WHERE Name LIKE '%Sport%' OR Name LIKE '%Fitness%'), 7)
SET @i = 1
WHILE @i <= 15
BEGIN
    INSERT INTO [catalog].[Products] (Title, Slug, ShortDescription, Description, BasePrice, DiscountPercent, CategoryId, SellerId, IsActive, AverageRating, TotalReviews, ViewCount, PurchaseCount, CreatedAt)
    VALUES 
    (CASE @i % 10
        WHEN 1 THEN 'Yoga Mat Non-Slip 6mm Thick'
        WHEN 2 THEN 'Dumbbells Set Adjustable 20kg'
        WHEN 3 THEN 'Resistance Bands Set 5 Levels'
        WHEN 4 THEN 'Running Shoes Breathable Mesh'
        WHEN 5 THEN 'Gym Bag Large Capacity Duffle'
        WHEN 6 THEN 'Fitness Tracker Heart Rate Monitor'
        WHEN 7 THEN 'Ab Roller Wheel Exercise Equipment'
        WHEN 8 THEN 'Jump Rope Speed Training'
        WHEN 9 THEN 'Protein Shaker Bottle 700ml'
        ELSE 'Sports Water Bottle Insulated 1L'
    END + ' #' + CAST(@i AS VARCHAR),
    'sports-item-' + CAST(@i AS VARCHAR) + '-' + CAST(ABS(CHECKSUM(NEWID())) % 9999 AS VARCHAR),
    'Quality sports equipment for your fitness journey',
    'Professional-grade sports and fitness equipment designed for optimal performance.',
    (ABS(CHECKSUM(NEWID())) % 8000) + 500,
    (ABS(CHECKSUM(NEWID())) % 30),
    @CategoryId,
    (SELECT TOP 1 Id FROM [sellers].[Sellers] ORDER BY NEWID()),
    1, 4.3 + (CAST(ABS(CHECKSUM(NEWID())) % 7 AS DECIMAL)/10),
    (ABS(CHECKSUM(NEWID())) % 350) + 50, 0, 0, DATEADD(day, -(ABS(CHECKSUM(NEWID())) % 30), GETUTCDATE()))
    
    SET @ProductId = SCOPE_IDENTITY()
    INSERT INTO [catalog].[ProductImages] (ProductId, Url, SortOrder) VALUES (@ProductId, 'https://via.placeholder.com/600x600/' + RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 999999 AS VARCHAR), 6) + '/ffffff?text=Sports', 0)
    INSERT INTO [catalog].[ProductVariants] (ProductId, Color, Price, Stock, Sku) VALUES (@ProductId, CASE (ABS(CHECKSUM(NEWID())) % 4) WHEN 0 THEN 'Black' WHEN 1 THEN 'Blue' WHEN 2 THEN 'Red' ELSE 'Green' END, (ABS(CHECKSUM(NEWID())) % 8000) + 500, (ABS(CHECKSUM(NEWID())) % 70) + 15, 'SPORT-' + CAST(@ProductId AS VARCHAR))
    SET @i = @i + 1
END

-- Mobile & Tablets (Category 2)
SET @CategoryId = 2
SET @i = 1
WHILE @i <= 15
BEGIN
    INSERT INTO [catalog].[Products] (Title, Slug, ShortDescription, Description, BasePrice, DiscountPercent, CategoryId, SellerId, IsActive, AverageRating, TotalReviews, ViewCount, PurchaseCount, CreatedAt)
    VALUES 
    (CASE @i % 10
        WHEN 1 THEN 'iPhone 15 Pro Max 256GB'
        WHEN 2 THEN 'Samsung Galaxy Tab S9 Ultra'
        WHEN 3 THEN 'OnePlus 12 5G 12GB RAM'
        WHEN 4 THEN 'iPad Pro 12.9 inch M2 Chip'
        WHEN 5 THEN 'Google Pixel 8 Pro 128GB'
        WHEN 6 THEN 'Realme GT 5 Pro 256GB'
        WHEN 7 THEN 'OPPO Find X6 Pro 512GB'
        WHEN 8 THEN 'Vivo X100 Pro 5G'
        WHEN 9 THEN 'Huawei MatePad Pro 12.6'
        ELSE 'Nothing Phone 2 256GB'
    END + ' #' + CAST(@i AS VARCHAR),
    'mobile-item-' + CAST(@i AS VARCHAR) + '-' + CAST(ABS(CHECKSUM(NEWID())) % 9999 AS VARCHAR),
    'Latest smartphone with cutting-edge features',
    'Premium mobile device featuring the latest technology and exceptional camera performance.',
    (ABS(CHECKSUM(NEWID())) % 80000) + 25000,
    (ABS(CHECKSUM(NEWID())) % 15),
    @CategoryId,
    (SELECT TOP 1 Id FROM [sellers].[Sellers] ORDER BY NEWID()),
    1, 4.5 + (CAST(ABS(CHECKSUM(NEWID())) % 5 AS DECIMAL)/10),
    (ABS(CHECKSUM(NEWID())) % 1000) + 200, 0, 0, DATEADD(day, -(ABS(CHECKSUM(NEWID())) % 30), GETUTCDATE()))
    
    SET @ProductId = SCOPE_IDENTITY()
    INSERT INTO [catalog].[ProductImages] (ProductId, Url, SortOrder) VALUES (@ProductId, 'https://via.placeholder.com/600x600/' + RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 999999 AS VARCHAR), 6) + '/ffffff?text=Mobile', 0)
    INSERT INTO [catalog].[ProductVariants] (ProductId, Color, Size, Price, Stock, Sku) VALUES (@ProductId, CASE (ABS(CHECKSUM(NEWID())) % 3) WHEN 0 THEN 'Black' WHEN 1 THEN 'White' ELSE 'Blue' END, CASE (ABS(CHECKSUM(NEWID())) % 3) WHEN 0 THEN '128GB' WHEN 1 THEN '256GB' ELSE '512GB' END, (ABS(CHECKSUM(NEWID())) % 80000) + 25000, (ABS(CHECKSUM(NEWID())) % 40) + 5, 'MOB-' + CAST(@ProductId AS VARCHAR))
    SET @i = @i + 1
END

-- Grocery & Essentials
SET @CategoryId = ISNULL((SELECT TOP 1 Id FROM [catalog].[Categories] WHERE Name LIKE '%Grocer%'), 8)
SET @i = 1
WHILE @i <= 15
BEGIN
    INSERT INTO [catalog].[Products] (Title, Slug, ShortDescription, Description, BasePrice, DiscountPercent, CategoryId, SellerId, IsActive, AverageRating, TotalReviews, ViewCount, PurchaseCount, CreatedAt)
    VALUES 
    (CASE @i % 10
        WHEN 1 THEN 'Basmati Rice Premium 5kg Pack'
        WHEN 2 THEN 'Extra Virgin Olive Oil 1L'
        WHEN 3 THEN 'Organic Honey Pure 500g'
        WHEN 4 THEN 'Green Tea Bags 100 Pack'
        WHEN 5 THEN 'Mixed Nuts Dry Roasted 500g'
        WHEN 6 THEN 'Whole Wheat Flour 2kg'
        WHEN 7 THEN 'Coconut Oil Cold Pressed 1L'
        WHEN 8 THEN 'Dark Chocolate 70% Cocoa 200g'
        WHEN 9 THEN 'Oatmeal Rolled Oats 1kg'
        ELSE 'Himalayan Pink Salt 1kg'
    END + ' #' + CAST(@i AS VARCHAR),
    'grocery-item-' + CAST(@i AS VARCHAR) + '-' + CAST(ABS(CHECKSUM(NEWID())) % 9999 AS VARCHAR),
    'Premium quality grocery item',
    'Fresh and high-quality grocery product sourced from trusted suppliers.',
    (ABS(CHECKSUM(NEWID())) % 1500) + 100,
    (ABS(CHECKSUM(NEWID())) % 20),
    @CategoryId,
    (SELECT TOP 1 Id FROM [sellers].[Sellers] ORDER BY NEWID()),
    1, 4.4 + (CAST(ABS(CHECKSUM(NEWID())) % 6 AS DECIMAL)/10),
    (ABS(CHECKSUM(NEWID())) % 300) + 50, 0, 0, DATEADD(day, -(ABS(CHECKSUM(NEWID())) % 30), GETUTCDATE()))
    
    SET @ProductId = SCOPE_IDENTITY()
    INSERT INTO [catalog].[ProductImages] (ProductId, Url, SortOrder) VALUES (@ProductId, 'https://via.placeholder.com/600x600/' + RIGHT('000000' + CAST(ABS(CHECKSUM(NEWID())) % 999999 AS VARCHAR), 6) + '/ffffff?text=Grocery', 0)
    INSERT INTO [catalog].[ProductVariants] (ProductId, Price, Stock, Sku) VALUES (@ProductId, (ABS(CHECKSUM(NEWID())) % 1500) + 100, (ABS(CHECKSUM(NEWID())) % 200) + 50, 'GROC-' + CAST(@ProductId AS VARCHAR))
    SET @i = @i + 1
END

PRINT 'Successfully added 130+ new products!'
SELECT COUNT(*) as TotalProducts FROM [catalog].[Products]
GO
