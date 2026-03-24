# Sparkle Ecommerce - Mobile System Architecture

## System Overview

Sparkle Ecommerce is a multi-seller e-commerce platform with a three-tier architecture:

```
┌─────────────────────────────────────────────────────────────┐
│              MOBILE APPLICATION LAYER                       │
│  (iOS/Android using REST API)                              │
│  - User Interface                                           │
│  - Local Data Caching                                       │
│  - Offline Features                                         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ HTTP/REST API (JSON)
                     │
┌────────────────────▼────────────────────────────────────────┐
│         ASP.NET Core API Layer (REST/SignalR)              │
│              (Sparkle.Api)                                  │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  - Authentication & Authorization (JWT)                    │
│  - Business Logic & Validation                             │
│  - Response Caching (Redis)                                │
│  - Real-time Notifications (SignalR)                       │
│  - File Upload/Download                                    │
│                                                             │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ Entity Framework Core
                     │
┌────────────────────▼────────────────────────────────────────┐
│         Data Access Layer (Sparkle.Infrastructure)          │
│         SQL Server Database                                 │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  - Tables for all entities                                 │
│  - Relationships & Constraints                              │
│  - Stored Procedures (Intelligent Search)                   │
│  - Migrations for schema versioning                         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Core Data Models & Relationships

### 1. User Management System

#### ApplicationUser Entity
```
┌─────────────────────────────────────────────────┐
│            ApplicationUser (Identity)             │
├─────────────────────────────────────────────────┤
│ id (PK)                                          │
│ username [UNIQUE]                                │
│ email [UNIQUE]                                   │
│ phoneNumber                                      │
│ passwordHash (hashed)                            │
│                                                  │
│ FullName                                         │
│ ContactPhone                                     │
│ Address                                          │
│ DateOfBirth                                      │
│ Gender (enum: Male/Female/Other)                 │
│ ProfilePhotoPath (url to /wwwroot)              │
│                                                  │
│ IsSeller (bool) - can sell products             │
│ IsActive (bool) - account status                │
│ AdminSubRole (enum) → Admin/Moderator/etc       │
│                                                  │
│ NationalIdFrontPath (for seller verification)  │
│ NationalIdBackPath                              │
│                                                  │
│ RegisteredAt (datetime)                          │
└─────────────────────────────────────────────────┘
```

#### User Relationships
```
ApplicationUser
  ├── Orders (1 → Many)
  ├── Cart (1 → 1)
  ├── Wishlist (1 → 1)
  ├── Addresses (1 → Many)
  ├── Reviews (1 → Many)
  ├── Seller Profile (1 → 1) [if IsSeller = true]
  ├── SupportTickets (1 → Many)
  └── Wallet & Transactions (1 → Many)
```

#### Admin Roles (AdminSubRole Enum)
```
AdminRoleType:
  - SuperAdmin (full access)
  - ProductModerator (approve/reject products)
  - OrderManager (manage orders, disputes)
  - SellerManager (manage sellers)
  - FinanceManager (wallet, refunds)
  - ContentManager (homepage, promotions)
  - SystemAdmin (settings, maintenance)
```

---

### 2. Product Catalog System

#### Category Entity
```
┌──────────────────────────────────────┐
│         Category                      │
├──────────────────────────────────────┤
│ id (PK)                               │
│ name (e.g., "Electronics")           │
│ slug (url slug)                       │
│ description                           │
│ icon (Bootstrap icon class)           │
│ imageUrl                              │
│ displayOrder                          │
│ isActive                              │
│ parentId (FK) → Parent Category      │
│ attributeFormId (FK) → DynamicForm   │
│                                       │
│ CreatedAt, UpdatedAt                 │
└──────────────────────────────────────┘
```

#### Product Entity
```
┌──────────────────────────────────────────────┐
│         Product                               │
├──────────────────────────────────────────────┤
│ id (PK)                                       │
│ title                                         │
│ slug (url slug - unique)                      │
│ shortDescription                              │
│ description (detailed/HTML)                   │
│ features (JSON array or comma-separated)      │
│                                               │
│ basePrice (decimal)                           │
│ discountPercent (0-100)                       │
│ calculatedPrice = basePrice * (1 - discount%)│
│                                               │
│ isActive                                      │
│ isAdminProduct (Sparkle Official badge)      │
│ averageRating (0-5 stars)                    │
│ totalReviews (count)                          │
│                                               │
│ viewCount (intelligence tracking)            │
│ purchaseCount (intelligence tracking)        │
│                                               │
│ weight, dimensions                            │
│ deliveryTypeEligibility (JSON)               │
│                                               │
│ MODERATION FIELDS:                            │
│ moderationStatus (Draft/Pending/Approved)    │
│ moderationNotes                               │
│ moderatedAt                                   │
│ moderatedBy (admin user id)                  │
│                                               │
│ categoryId (FK) → Category                    │
│ brandId (FK) → Brand [optional]               │
│ sellerId (FK) → Seller [optional]             │
│                                               │
│ CreatedAt, UpdatedAt                          │
└──────────────────────────────────────────────┘
```

#### ProductVariant Entity
```
┌────────────────────────────────────┐
│    ProductVariant (SKU)             │
├────────────────────────────────────┤
│ id (PK)                             │
│ productId (FK)                      │
│ sku (unique code)                   │
│ color [optional]                    │
│ size [optional]                     │
│ price (variant-specific)            │
│ stock (inventory)                   │
│                                     │
│ Example: Gold iPhone 14 Pro 256GB  │
│  - Color: Gold                      │
│  - Size: 256GB                      │
│  - Price: 120,000 BDT              │
│  - Stock: 15 units                  │
└────────────────────────────────────┘
```

#### ProductImage Entity
```
┌────────────────────────────────┐
│    ProductImage                 │
├────────────────────────────────┤
│ id (PK)                         │
│ productId (FK)                  │
│ url (path to image)             │
│ isMain (primary display image)  │
│                                 │
│ Note: Store as relative paths   │
│ e.g., /products/phone-1.jpg    │
└────────────────────────────────┘
```

#### Product Relationships Diagram
```
Product
  ├── Category (Many → 1)
  ├── Brand (Many → 1) [optional]
  ├── Seller (Many → 1) [optional - null = admin product]
  ├── ProductVariants (1 → Many)
  │    └── CartItems (1 → Many)
  │    └── OrderItems (1 → Many)
  ├── ProductImages (1 → Many)
  ├── Reviews (1 → Many)
  └── HomepageSections (Many → Many)
```

---

### 3. Shopping Cart System

#### Cart Entity
```
┌──────────────────────────────────┐
│         Cart                      │
├──────────────────────────────────┤
│ id (PK)                           │
│ userId (FK) → ApplicationUser    │
│ couponCode [optional]             │
│ discountAmount (decimal)          │
│                                   │
│ Items: List<CartItem>            │
└──────────────────────────────────┘
```

#### CartItem Entity
```
┌──────────────────────────────────┐
│       CartItem                    │
├──────────────────────────────────┤
│ id (PK)                           │
│ cartId (FK)                       │
│ productVariantId (FK)             │
│ quantity (1-99)                   │
│ unitPrice (snapshot at add time)  │
│                                   │
│ Total = quantity × unitPrice      │
└──────────────────────────────────┘
```

#### Wishlist & Wishlist Item
```
┌──────────────────────────────────┐
│       Wishlist                    │
├──────────────────────────────────┤
│ id (PK)                           │
│ userId (FK)                       │
│ name [optional]                   │
│ isPublic (bool - sharing)         │
│ shareToken (unique token)         │
│ sharedAt                          │
│                                   │
│ Items: List<WishlistItem>        │
└──────────────────────────────────┘

┌──────────────────────────────────┐
│     WishlistItem                  │
├──────────────────────────────────┤
│ id (PK)                           │
│ wishlistId (FK)                   │
│ productId (FK)                    │
└──────────────────────────────────┘
```

---

### 4. Order Management System

#### Order Status Enum
```
OrderStatus:
  0 = Pending (awaiting confirmation)
  1 = Confirmed (order confirmed by seller/admin)
  10 = SellerPreparing (seller packing product)
  11 = ReadyForHandover (ready for pickup)
  20 = PickupScheduled (rider assigned)
  21 = PickedUp (item picked from seller)
  22 = PickupFailed (issue during pickup)
  30 = ReceivedAtHub (at logistics hub)
  31 = QCPassed (quality check passed)
  32 = QCFailed (item damaged/defective)
  33 = Sorting (being sorted for delivery)
  40 = OutForDelivery (on delivery rider)
  41 = DeliveryAttempted (rider tried delivery)
  42 = Shipped (legacy - similar to OutForDelivery)
  50 = Delivered (successfully delivered)
  60 = DeliveryFailed (couldn't deliver)
  61 = ReturnToHub (returned to hub)
  70 = ReturnRequested (customer requested return)
  71 = Returned (item returned)
  80 = Refunded (money refunded)
  90 = Cancelled (order cancelled)
```

#### PaymentStatus Enum
```
PaymentStatus:
  - Pending (awaiting payment)
  - Paid (payment received)
  - Failed (payment failed)
  - Refunded (full refund given)
  - PartiallyRefunded (partial refund)
```

#### PaymentMethodType Enum
```
PaymentMethodType:
  - CashOnDelivery (pay at delivery)
  - BkashPersonal (bKash personal account)
  - BkashMerchant (bKash merchant API)
  - Nagad (Nagad payment)
  - Rocket (Rocket payment)
  - CreditCard (Visa/Mastercard)
  - DebitCard (Bank debit card)
  - BankTransfer (Direct bank transfer)
  - SparkleWallet (In-app wallet)
  - Instalment (Pay in installments)
```

#### Order Entity
```
┌──────────────────────────────────────────────────┐
│         Order                                     │
├──────────────────────────────────────────────────┤
│ id (PK)                                           │
│ orderNumber (UNIQUE - e.g., ORD-202306-001234)  │
│                                                  │
│ PARTIES:                                          │
│ userId (FK) → Buyer                             │
│ sellerId (FK) → Seller [if multi-seller order]  │
│                                                  │
│ STATUS & PAYMENT:                                │
│ status (OrderStatus enum)                        │
│ paymentStatus (PaymentStatus enum)               │
│ paymentMethod (PaymentMethodType enum)           │
│ paymentTransactionId (from gateway)              │
│ paidAt (datetime - when paid)                    │
│                                                  │
│ AMOUNTS:                                          │
│ subTotal (sum of item prices)                    │
│ shippingCost                                      │
│ taxAmount                                        │
│ discountAmount (product discounts)               │
│ couponDiscount (coupon code discount)            │
│ voucherDiscount (vendor voucher)                 │
│ totalAmount (final amount due)                   │
│ couponCode [optional]                            │
│                                                  │
│ SHIPPING ADDRESS:                                │
│ shippingFullName                                 │
│ shippingPhone                                    │
│ shippingAddressLine1                             │
│ shippingAddressLine2 [optional]                  │
│ shippingArea                                     │
│ shippingCity                                     │
│ shippingDistrict                                 │
│ shippingDivision                                 │
│ shippingPostalCode                               │
│ shippingCountry (default: Bangladesh)            │
│                                                  │
│ BILLING ADDRESS (optional if different):        │
│ billingAddressSame (bool)                        │
│ billingFullName, billingPhone, etc.             │
│                                                  │
│ TRACKING & LOGISTICS:                            │
│ deliveryMode (PlatformPickup/SellerDrop)        │
│ assignedHubId (FM hub)                          │
│ pickupRiderId (who picks from seller)           │
│ deliveryRiderId (who delivers to customer)      │
│ courierName                                      │
│ trackingNumber (from courier)                    │
│                                                  │
│ TIMESTAMPS:                                      │
│ orderDate                                        │
│ shippedAt                                        │
│ deliveredAt                                      │
│ estimatedDeliveryDate                            │
│ cancelledAt                                      │
│ deliveryAttempts (count)                         │
│                                                  │
│ NOTES:                                           │
│ customerNotes (buyer notes for seller)           │
│ internalNotes (admin-only notes)                 │
│ cancellationReason                               │
│                                                  │
│ RELATIONSHIPS:                                    │
│ orderItems: List<OrderItem>                     │
│ shipments: List<Shipment>                       │
│ trackingHistory: List<OrderTracking>            │
│ transactions: List<Transaction>                 │
└──────────────────────────────────────────────────┘
```

#### OrderItem Entity
```
┌──────────────────────────────────┐
│       OrderItem                   │
├──────────────────────────────────┤
│ id (PK)                           │
│ orderId (FK)                      │
│ productVariantId (FK)             │
│ quantity                          │
│ unitPrice (snapshot at order time)│
│ subtotal = quantity × unitPrice   │
│                                   │
│ Product details stored for        │
│ reference even if product changes│
└──────────────────────────────────┘
```

#### OrderTracking Entity
```
┌──────────────────────────────────┐
│     OrderTracking                 │
├──────────────────────────────────┤
│ id (PK)                           │
│ orderId (FK)                      │
│ status (OrderStatus)              │
│ statusChangedAt (datetime)        │
│ notes (status change reason)      │
│ latitude, longitude (location)    │
│ updatedBy (staff member id)       │
└──────────────────────────────────┘
```

#### Address Entity
```
┌──────────────────────────────────┐
│       Address                     │
├──────────────────────────────────┤
│ id (PK)                           │
│ userId (FK)                       │
│ fullName                          │
│ phone                             │
│ line1 (Street address)            │
│ line2 [optional]                  │
│ city                              │
│ state                             │
│ area [optional]                   │
│ postalCode                        │
│ country (default: Bangladesh)     │
│ isDefault (bool)                  │
└──────────────────────────────────┘
```

---

### 5. Seller System

#### Seller Profile
```
┌──────────────────────────────────────┐
│         Seller                        │
├──────────────────────────────────────┤
│ id (PK)                               │
│ userId (FK) → Seller's Account       │
│                                       │
│ shopName                              │
│ shopSlug (unique-url)                 │
│ shopDescription                       │
│ shopLogo                              │
│ shopBanner                            │
│                                       │
│ ownerName                             │
│ ownerPhone                            │
│ ownerEmail                            │
│                                       │
│ ADDRESS:                              │
│ businessAddress                       │
│ city, district, division              │
│                                       │
│ VERIFICATION:                         │
│ businessRegistrationNumber            │
│ taxId                                 │
│ isVerified (bool)                     │
│ verificationDocument                  │
│ verificationDate                      │
│                                       │
│ RATINGS:                              │
│ averageRating                         │
│ totalRatings                          │
│ positiveRating                        │
│ negativeRating                        │
│                                       │
│ STATUS:                               │
│ status (Active/Suspended/Inactive)    │
│ isFeatured (appears in highlights)   │
│                                       │
│ FINANCIAL:                            │
│ commissionPercentage (take by platform)│
│ bankAccountDetails                    │
│ monthlyRevenue                        │
│                                       │
│ TIMESTAMPS:                           │
│ createdAt                             │
│ updatedAt                             │
│ suspendedAt                           │
│                                       │
│ RELATIONSHIPS:                        │
│ products: List<Product>              │
│ orders: List<Order>                  │
│ reviews: List<Review>                │
│ wallet & transactions                │
└──────────────────────────────────────┘
```

---

### 6. Reviews & Ratings System

#### Review Entity
```
┌──────────────────────────────┐
│       Review                  │
├──────────────────────────────┤
│ id (PK)                       │
│ productId (FK)                │
│ userId (FK)                   │
│ rating (1-5 stars)            │
│ comment [optional]            │
│ createdAt                     │
│                               │
│ Hidden fields (for purchase   │
│ verification - not in mobile) │
│ orderId [optional]            │
│ orderItemId [optional]        │
└──────────────────────────────┘
```

---

### 7. Chat System (Real-time)

#### ChatMessage Entity
```
┌──────────────────────────────┐
│    ChatMessage                │
├──────────────────────────────┤
│ id (PK)                       │
│ senderId (FK) → User         │
│ recipientId (FK) → User      │
│ message (text)                │
│ isRead (bool)                 │
│ attachmentUrl [optional]      │
│ createdAt                     │
│                               │
│ Used for:                     │
│ - Seller support             │
│ - Product inquiries          │
│ - Order updates              │
└──────────────────────────────┘
```

---

### 8. Wallet & Financial System

#### Wallet Entity
```
┌──────────────────────────────┐
│      Wallet                   │
├──────────────────────────────┤
│ id (PK)                       │
│ userId (FK)                   │
│ balance (current amount)      │
│ totalRecharged                │
│ totalSpent                    │
│ createdAt, updatedAt          │
└──────────────────────────────┘
```

#### Transaction Entity
```
┌────────────────────────────────────┐
│      Transaction                    │
├────────────────────────────────────┤
│ id (PK)                             │
│ walletId (FK)                       │
│ orderId (FK) [optional]             │
│ type (Debit/Credit)                 │
│ amount                              │
│ description                         │
│ balanceAfter (snapshot)             │
│ status (Pending/Completed/Failed)   │
│ referenceNumber                     │
│ createdAt                           │
└────────────────────────────────────┘
```

---

## API Communication Standards

### Request Format
```
{
  "method": "POST|GET|PUT|DELETE",
  "headers": {
    "Content-Type": "application/json",
    "Authorization": "Bearer {jwt_token}"
  },
  "body": { /* json data */ }
}
```

### Response Format - Success
```
{
  "success": true,
  "statusCode": 200,
  "data": { /* requested data */ },
  "message": "Operation successful"
}
```

### Response Format - Error
```
{
  "success": false,
  "statusCode": 400|401|403|404|500,
  "errors": [
    {
      "field": "email",
      "message": "Email already exists"
    }
  ],
  "message": "Validation failed"
}
```

### Pagination Response
```
{
  "success": true,
  "data": [ /* items */ ],
  "pagination": {
    "totalItems": 250,
    "pageNumber": 1,
    "pageSize": 20,
    "totalPages": 13,
    "hasNextPage": true,
    "hasPreviousPage": false
  }
}
```

---

## Caching Strategy

### Cache Layers
```
Mobile App
  ├── Local SQLite Database (Long-term cache)
  ├── In-Memory Cache (Session data)
  └── HTTP Cache (API response headers)
        │
        ├── CDN Cache (for images)
        ├── API Response Cache (Redis - 1 hour)
        │
        └── Database (Source of truth)
```

### Cache TTL (Time-To-Live)
- **Homepage sections**: 1 hour
- **Product listings**: 30 minutes
- **Trending products**: 30 minutes
- **Seller information**: 1 hour
- **User profile**: 24 hours
- **Category data**: 24 hours
- **Product images**: No expiry (CDN)

---

## Real-time Features (SignalR)

### NotificationHub Connections
```
Client connects to SignalR for:
- Order status updates
- Chat messages
- New review notifications
- Flash sale alerts
- System announcements
```

### Notification Event Structure
```
{
  "type": "order-status-update|chat-message|review-posted|flash-sale",
  "timestamp": "2023-06-15T10:30:00Z",
  "data": { /* specific data */ },
  "userId": "user-id"
}
```

---

## Security Considerations for Mobile

1. **JWT Token Storage**: Use secure storage (Keychain for iOS, Keystore for Android)
2. **HTTPS Only**: All API calls must use HTTPS
3. **Certificate Pinning**: Implement SSL pinning for sensitive endpoints
4. **Request Signing**: Sign API requests with timestamp to prevent replay attacks
5. **Input Validation**: Validate all user inputs before sending to API
6. **Sensitive Data**: Never log JWT tokens, passwords, or payment details
7. **App Security**: Keep app signing keys secure
8. **API Rate Limiting**: Respect API rate limits (implement exponential backoff)

---

## Performance Optimization

### Image Optimization
- Store images in WebP format
- Provide multiple image sizes
- Implement lazy loading
- Cache images locally

### Data Optimization
- Minimize payload sizes
- Bundle related data
- Use compression (gzip)
- Implement pagination

### Network Optimization
- Implement request queuing
- Support offline-first architecture
- Use background sync
- Implement retry logic

---

**Architecture Version**: 1.0  
**Last Updated**: March 2026  
**Maintained By**: Development Team
