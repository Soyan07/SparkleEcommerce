IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'support')
BEGIN
    EXEC('CREATE SCHEMA [support]')
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[support].[Reports]') AND type in (N'U'))
BEGIN
    CREATE TABLE [support].[Reports] (
        [Id] int NOT NULL IDENTITY,
        [ReporterId] nvarchar(450) NOT NULL,
        [TargetType] nvarchar(max) NOT NULL,
        [ProductId] int NULL,
        [SellerId] int NULL,
        [Reason] nvarchar(max) NOT NULL,
        [Description] nvarchar(max) NOT NULL,
        [Status] nvarchar(max) NOT NULL DEFAULT N'Pending',
        [CreatedAt] datetime2 NOT NULL DEFAULT (GETUTCDATE()),
        [ResolvedAt] datetime2 NULL,
        [ResolutionNotes] nvarchar(max) NULL,
        [UpdatedAt] datetime2 NULL,
        [CreatedBy] nvarchar(max) NULL,
        [UpdatedBy] nvarchar(max) NULL,
        [IsDeleted] bit NOT NULL DEFAULT 0,
        [DeletedAt] datetime2 NULL,
        CONSTRAINT [PK_Reports] PRIMARY KEY ([Id]),
        CONSTRAINT [FK_Reports_AspNetUsers_ReporterId] FOREIGN KEY ([ReporterId]) REFERENCES [dbo].[AspNetUsers] ([Id]) ON DELETE NO ACTION,
        CONSTRAINT [FK_Reports_Products_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [catalog].[Products] ([Id]) ON DELETE SET NULL,
        CONSTRAINT [FK_Reports_Sellers_SellerId] FOREIGN KEY ([SellerId]) REFERENCES [sellers].[Sellers] ([Id]) ON DELETE SET NULL
    );

    CREATE INDEX [IX_Reports_ReporterId] ON [support].[Reports] ([ReporterId]);
    CREATE INDEX [IX_Reports_ProductId] ON [support].[Reports] ([ProductId]);
    CREATE INDEX [IX_Reports_SellerId] ON [support].[Reports] ([SellerId]);
    
    PRINT 'Reports table created successfully.'
END
ELSE
BEGIN
    PRINT 'Reports table already exists.'
END
