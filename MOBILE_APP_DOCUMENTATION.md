# Sparkle Ecommerce - Mobile App Documentation

Complete documentation for building the Sparkle Ecommerce mobile application.

---

## Table of Contents

1. [Overview](#1-overview)
2. [System Architecture](#2-system-architecture)
3. [Features Guide](#3-features-guide)
4. [UI/UX Design](#4-ux-design)
5. [Daraz-Style Design Patterns](#5-daraz-style-design-patterns)
6. [Implementation Roadmap](#6-implementation-roadmap)
7. [Quick Reference](#7-quick-reference)

---

## 1. Overview

### System Overview

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
│  - Authentication & Authorization (JWT)                       │
│  - Business Logic & Validation                               │
│  - Response Caching (Redis)                                 │
│  - Real-time Notifications (SignalR)                        │
│  - File Upload/Download                                    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     │ Entity Framework Core
                     │
┌────────────────────▼────────────────────────────────────────┐
│         Data Access Layer (Sparkle.Infrastructure)          │
│         SQL Server Database                                 │
└─────────────────────────────────────────────────────────────┘
```

### Technology Recommendations

**Cross-Platform (Recommended for fast MVP):**
- **Flutter** or **React Native**
- Single codebase, faster development

**Native Development:**
- iOS: Swift + SwiftUI
- Android: Kotlin + Jetpack Compose

**Key Libraries:**
- HTTP Client: Dio (Flutter), Alamofire (iOS), Retrofit (Android)
- State Management: Provider, GetX, Bloc, Redux
- Local Storage: SQLite, Hive, SharedPreferences
- Push Notification: Firebase Cloud Messaging

### Mobile-First Considerations
- All components must be responsive
- Touch-friendly button sizes (min 44x44 dp)
- Fast loading times (optimize images)
- Offline support for critical features
- Pagination for large lists
- Infinite scroll for product browsing

---

## 2. System Architecture

### Core Data Models

#### ApplicationUser Entity
```
- id, username, email, phoneNumber, passwordHash
- FullName, ContactPhone, Address, DateOfBirth, Gender
- ProfilePhotoPath, IsSeller, IsActive, AdminSubRole
- NationalIdFrontPath, NationalIdBackPath, RegisteredAt
```

#### Product Entity
```
- id, title, slug, shortDescription, description, features
- basePrice, discountPercent, calculatedPrice
- isActive, isAdminProduct, averageRating, totalReviews
- viewCount, purchaseCount, weight, dimensions
- moderationStatus, categoryId, brandId, sellerId
```

#### Order Entity
```
- id, orderNumber, userId, sellerId
- status (OrderStatus enum), paymentStatus, paymentMethod
- subTotal, shippingCost, taxAmount, discountAmount, totalAmount
- shippingFullName, shippingPhone, shippingAddressLine1, etc.
- deliveryMode, trackingNumber, orderDate, deliveredAt
```

#### Cart Entity
```
- id, userId, couponCode, discountAmount
- Items: List<CartItem>
```

#### Wishlist Entity
```
- id, userId, name, isPublic, shareToken
- Items: List<WishlistItem>
```

### API Communication Standards

**Request Format:**
```json
{
  "method": "POST|GET|PUT|DELETE",
  "headers": {
    "Content-Type": "application/json",
    "Authorization": "Bearer {jwt_token}"
  }
}
```

**Response Format - Success:**
```json
{
  "success": true,
  "statusCode": 200,
  "data": { /* requested data */ },
  "message": "Operation successful"
}
```

**Pagination Response:**
```json
{
  "success": true,
  "data": [ /* items */ ],
  "pagination": {
    "totalItems": 250,
    "pageNumber": 1,
    "pageSize": 20,
    "totalPages": 13,
    "hasNextPage": true
  }
}
```

### Caching Strategy
- **Homepage sections**: 1 hour
- **Product listings**: 30 minutes
- **Trending products**: 30 minutes
- **Seller information**: 1 hour
- **User profile**: 24 hours
- **Category data**: 24 hours

### Real-time Features (SignalR)
```
Client connects to SignalR for:
- Order status updates
- Chat messages
- New review notifications
- Flash sale alerts
```

### Security Considerations
1. JWT Token Storage: Use secure storage (Keychain/Keystore)
2. HTTPS Only: All API calls must use HTTPS
3. Certificate Pinning: Implement SSL pinning
4. Input Validation: Validate all user inputs
5. API Rate Limiting: Implement exponential backoff

---

## 3. Features Guide

### 3.1 Authentication & Account Management

#### Registration Flow
```
1. Enter email/phone, password, full name
2. Accept terms & conditions
3. Submit registration
4. Email/Phone verification (OTP)
5. Redirect to home or onboarding
```

#### Login Methods
1. Email/Password (Traditional)
2. Phone/Password (Alternative)
3. Social Login (Future Phase)

#### Password Reset
```
1. Enter email/phone
2. Receive OTP via Email/SMS
3. Enter 6-digit OTP
4. Set new password
5. Redirect to login
```

#### Account Profile
- View/Edit profile information
- Manage addresses (add, edit, delete, set default)
- Two-Factor Authentication setup
- Device management (logout from other devices)

### 3.2 Product Browsing & Discovery

#### Homepage Sections
```
- Hero Banner (Auto-rotating carousel)
- Quick Categories (Horizontal scroll, 8-12 categories)
- Flash Sale Section (Timer + products)
- Trending Products Section
- Recommended for You
- Seller Highlights
```

#### Search Functionality
- Search suggestions (recent, popular, auto-complete)
- Voice search (optional)
- Search filters (price, brand, rating, seller)
- Sort options (relevance, newest, price, rating)

#### Category Browsing
```
- Filter panel (collapsible)
- Sort options dropdown
- Product grid (2 columns)
- Pagination / Infinite scroll
- Subcategories navigation
```

### 3.3 Product Detail Page

#### Layout Structure
```
- Image Carousel (swipe, thumbnails, zoom)
- Quick Info (title, rating, reviews)
- Seller Info Card (logo, name, rating, follow button)
- Price Section (discount badge, current price, original price)
- Variant Selection (color, size, quantity)
- Action Buttons (Add to Cart, Buy Now, Wishlist, Share)
- Shipping Information
- Product Details Tabs (Description, Specs, Reviews)
- Recommendations Section
```

### 3.4 Shopping Features

#### Cart Management
```
- Cart items list with quantity editor
- Price summary (subtotal, discount, shipping, tax, total)
- Coupon code input
- Proceed to checkout
- Empty cart state
```

#### Wishlist Management
```
- Multiple wishlists support
- Add to cart from wishlist
- Share wishlist (generate link)
- Move items between lists
```

### 3.5 Checkout & Payment

#### Three-Step Checkout
```
STEP 1: DELIVERY ADDRESS
- Select saved address or add new
- Confirm delivery location

STEP 2: PAYMENT METHOD
- Cash on Delivery (COD)
- Bkash, Nagad, Rocket
- Credit/Debit Card
- Bank Transfer
- Sparkle Wallet

STEP 3: ORDER REVIEW & CONFIRMATION
- Order summary
- Address & payment confirmation
- T&C checkbox
- Place Order
```

#### Order Confirmation
```
- Success animation/icon
- Order number (copyable)
- Total amount
- Estimated delivery date
- Track Order button
- Continue Shopping
```

### 3.6 Order Tracking & Management

#### Order Status Timeline
```
Pending → Confirmed → Seller Preparing → Ready for Handover
→ Picked Up → In Transit → Out for Delivery → Delivered

Failed Statuses: Pickup Failed, QC Failed, Delivery Failed, Returned
```

#### Order Actions
- Track Order
- View Details
- Cancel Order (if allowed)
- Return/Refund (if eligible)
- Contact Seller
- Rate & Review (if delivered)

### 3.7 Seller Features

#### Seller Shop Page
```
- Shop banner, logo, name
- Follow button, share button
- Products count, follower count, rating
- Product grid with filters
- Chat with seller
```

#### Seller Dashboard
```
- Quick stats (sales, orders, followers)
- Recent orders
- Low stock alerts
- Product management
- Order fulfillment
- Wallet & payouts
```

### 3.8 Reviews & Ratings

#### Write Review
```
- 1-5 star rating
- Review title & comment
- Photo upload (optional)
- Submit review (after approval)
```

#### View Reviews
```
- Average rating display
- Rating distribution (5-star breakdown)
- Filter by rating, verified purchase, photos
- Helpful/Not helpful voting
- Seller responses
```

### 3.9 Chat & Communication

#### Chat Features
- Real-time messaging (SignalR/WebSocket)
- Image/photo sharing
- Message timestamps & read receipts
- Typing indicators
- Chat history persistence
- Push notifications

### 3.10 Admin Features

#### Admin Dashboard
```
- Quick stats (users, orders, revenue)
- Charts & graphs
- Recent activities
- Quick actions
```

#### Product Moderation
```
- Pending products queue
- Approve/Reject/Flag
- Moderation notes
- Bulk moderation
```

---

## 4. UI/UX Design

### Color Palette

#### Primary Colors
```
Brand Primary (Orange):     #FF6B35
Brand Secondary (Teal):     #0E9B6B
Dark Gray (Text):           #1F2937
Light Gray (Background):     #F3F4F6
White:                      #FFFFFF
```

#### Semantic Colors
```
Success:                    #10B981
Warning:                    #F59E0B
Error:                      #EF4444
Info:                       #3B82F6
Disabled:                   #D1D5DB
```

### Typography

#### Font Scale
```
Display (48px):     Weight 700, Line Height 1.2
Heading 1 (32px):   Weight 700, Line Height 1.2
Heading 2 (24px):   Weight 700, Line Height 1.3
Heading 3 (20px):   Weight 700, Line Height 1.3
Body (16px):        Weight 400, Line Height 1.5
Body Small (14px):  Weight 400, Line Height 1.5
Caption (12px):     Weight 400, Line Height 1.5
```

### Spacing (8px Grid System)
```
0 = 0px    4 = 16px   8 = 32px   12 = 48px
1 = 4px    5 = 20px   10 = 40px  16 = 64px
2 = 8px    6 = 24px   12 = 48px
3 = 12px   7 = 28px
```

### Border Radius
```
Small:      4px
Medium:     8px
Large:      12px
Extra Large:16px
Full:       50%
```

### Bottom Tab Navigation (5 Tabs)
```
┌─────────────────────────────────────┐
│ 🏠  🔍  ❤️  📦  👤                │
│ Home Search Wishlist Orders Account │
└─────────────────────────────────────┘

Tab Bar Specifications:
- Height: 64px
- Icon Size: 24x24px
- Active Color: #FF6B35
- Inactive Color: #6B7280
- Label Font: 12px, Weight 500
```

### Button Components

#### Primary Button
```
- Background: #FF6B35
- Text Color: White
- Height: 44px
- Border Radius: 8px
- Font: 16px, Weight 600
```

#### Secondary Button
```
- Background: #F3F4F6
- Text Color: #1F2937
- Border: 1px #D1D5DB
- Height: 44px
```

### Product Card (Grid View)
```
┌──────────────────────┐
│    Product Image     │ (180px height)
├──────────────────────┤
│ Product Name...      │ (2 lines max)
├──────────────────────┤
│ ⭐ 4.5 (250)        │
├──────────────────────┤
│ BDT 2,500            │
│ BDT 3,500 [STRIKE]   │
├──────────────────────┤
│ [+ ADD TO CART]      │
└──────────────────────┘

Card: 50% width, ~280px height, 8px gap
```

### Input Fields
```
- Height: 44px
- Padding: 12px 16px
- Background: #F3F4F6
- Border: 1px #D1D5DB
- Border Radius: 8px
- Focused: Border #FF6B35
```

### Toast/Snackbar
```
- Position: Bottom (above tab bar)
- Width: 90% or max 400px
- Duration: 3-5 seconds
- Animation: Slide up with fade
```

### Screen Layout Structure
```
┌─ Status Bar (20px) ────────────┐
├─ Header (56px) ────────────────┤
├─ Safe Area Content             │
│                                 │
│ [Content fills vertical space]  │
│                                 │
├─ [Tab Navigation (64px)] ───────┤
└─ Safe Area (bottom) ────────────┘
```

---

## 5. Daraz-Style Design Patterns

### Navigation Structure

#### Bottom Tab Navigation (5 Tabs)
```
Sparkle Implementation (RECOMMENDED):
├─ Tab 1: Home (Homepage)
├─ Tab 2: Search (Search & Browse)
├─ Tab 3: Wishlist (Saved Items)
├─ Tab 4: Orders (My Orders/Tracking)
└─ Tab 5: Account (Profile & Settings)

Rationale:
- Cart available from Home as floating button
- Wishlist as separate tab
- Orders tab for tracking
- Settings in Account tab
```

### Homepage Design Pattern

```
┌─────────────────────────────────┐
│ Header Strip (56px)             │
│ Logo | Search | Location         │
├─────────────────────────────────┤
│ HERO CAROUSEL (200-220px)       │
│ [Ad1] [Ad2] [Ad3] [Ads...]     │
│ ● ○ ○ ○ ○ (Dot indicators)     │
│ Auto-scroll + Tap navigation     │
├─────────────────────────────────┤
│ CATEGORY STRIP (80px)           │
│ [Electronics] [Fashion] [Home]   │
│ Horizontal scroll, icons + text  │
├─────────────────────────────────┤
│ FLASH SALE BANNER (100px)       │
│ ⏰ MEGA SALE Today 11am - 8pm    │
│ Products with countdown timer     │
├─────────────────────────────────┤
│ REGULAR PRODUCT SECTIONS        │
│ "Just For You" / "Trending"     │
│ Product Grid (2 columns)        │
└─────────────────────────────────┘
```

### Search Results Page
```
┌──────────────────────────────────┐
│ ← | 🔍 "search query" | ⋮        │
├──────────────────────────────────┤
│ FILTERS | SORT ▼                  │
├──────────────────────────────────┤
│ Results (845 products)            │
│ ┌────────┬────────┐              │
│ │ Prod1  │ Prod2  │  (Grid)      │
│ └────────┴────────┘              │
│ [LOAD MORE] (Pagination)          │
└──────────────────────────────────┘
```

### Product Detail Page
```
┌──────────────────────────────────┐
│ ← Details                        │
├──────────────────────────────────┤
│ [IMAGE CAROUSEL]                 │
│ ⭐⭐⭐⭐ (4.5) | 250 reviews    │
│ iPhone 14 Pro (128GB, Gold)      │
│ BDT 120,000                      │
│ BDT 150,000  [SAVE 20%]          │
│ FREE SHIPPING | 7-Day Return      │
│ SELLER: Apple Shop ⭐ 4.8        │
│ [- QUANTITY +]                   │
│ ┌──────────────────────────────┐ │
│ │ [ADD TO CART] [BUY NOW]      │ │
│ │ [SHARE] [❤ WISHLIST]        │ │
│ └──────────────────────────────┘ │
│ DESCRIPTION | SPECS | REVIEWS     │
└──────────────────────────────────┘
```

### Cart Page (Daraz Style)
```
┌──────────────────────────────────┐
│ ← My Cart (2)                    │
├──────────────────────────────────┤
│ Cart Item 1:                     │
│ [Image] iPhone 14 Pro            │
│ Gold | 128GB | BDT 120,000       │
│ Qty [-] 1 [+] [Remove] [Wishlist]│
│ ──────────────────────────────   │
│ Promo Code: [ENTER CODE] [APPLY] │
│ ──────────────────────────────   │
│ PRICE DETAILS                    │
│ Subtotal        BDT 170,000      │
│ Discount        -BDT 20,000      │
│ Shipping        FREE             │
│ ──────────────────────────────   │
│ TOTAL           BDT 150,000      │
│                                  │
│ [CONTINUE SHOPPING] [CHECKOUT]   │
└──────────────────────────────────┘
```

### Order Tracking (Daraz Pattern)
```
┌──────────────────────────────────┐
│ TIMELINE VIEW:                   │
│                                  │
│ ✓ Pending (Jun 14, 2:30 PM)     │
│ ✓ Confirmed (Jun 14, 5:00 PM)   │
│ ●  Out for Delivery              │
│   └─ Jun 16, 10:00 AM           │
│   Rider: Rajon | [CONTACT]       │
│ ○ Delivered (Expected)           │
│                                  │
│ DELIVERY ADDRESS:                │
│ 456 Dhanmondi, Dhaka 1205        │
│ +8801700123456                   │
│ [CONTACT SELLER] [HELP]          │
└──────────────────────────────────┘
```

### Daraz Success Factors to Replicate
```
1. Fast Checkout (2-3 steps, pre-filled addresses)
2. Transparent Tracking (real-time updates, push notifications)
3. Trust Signals (seller ratings, verified reviews)
4. Discounts & Deals (flash sales, category promotions)
5. Mobile-First Content (optimized images, fast loading)
6. Performance (<2s page loads, 60fps scrolling)
7. Communication (in-app chat, Q&A on products)
8. Personalization (recommendations, search history)
```

---

## 6. Implementation Roadmap

### Phase 1: Core Mobile App (MVP) - 3-4 Months

```
Week 1-2: Project Setup & Infrastructure
- Technology stack selection
- Dev environment setup
- CI/CD pipeline configuration

Week 2-3: Navigation & Authentication
- Splash screen
- Login/Registration screens
- Session management (JWT)
- Bottom tab navigation

Week 3-4: Product Browsing
- Homepage implementation
- Category browsing
- Search functionality
- Filters & sorting

Week 4-5: Cart & Checkout
- Product detail page
- Cart management
- Add to cart flow
- Persistent cart storage

Week 5-6: Payments (COD)
- Three-step checkout
- Cash on Delivery
- Order confirmation
- Basic order tracking

Week 6-7: Account & Profile
- Account screen
- Edit profile
- Address management
- Settings

Week 7-8: Testing & Launch Prep
- Unit & widget tests
- Manual testing
- App store preparation
- Beta testing
```

### Phase 2: Feature Expansion - 2-3 Months

```
- Product reviews & ratings
- Wishlist features (multiple lists, sharing)
- Seller shop pages & dashboard
- Real-time chat (SignalR)
- Multiple payment methods (Bkash, Nagad, Cards)
- Wallet & refunds
- Return & refund flow
- Push notifications & analytics
```

### Phase 3: Optimization & Polish - 1-2 Months

```
- Performance optimization (< 2s startup)
- Network optimization (caching, compression)
- Advanced filters & search
- Personalization features
- Seller tools enhancement
- Admin features (mobile)
- UI/UX refinement
- Accessibility audit
```

### Phase 4: Growth Features - 2-3 Months

```
- AI-powered recommendations
- Visual search
- Advanced seller analytics
- Q&A system
- Loyalty & rewards program
- Referral program
- Third-party integrations
- Internationalization
```

### Success Metrics

#### Phase 1
```
- App size: < 50-80 MB
- Startup time: < 3 seconds
- Downloads: 10,000+ in first month
- Rating: > 4.0 stars
- Crash-free: > 99.5%
```

#### Phase 2-4
```
- MAU: 100,000+
- Average session length: > 5 minutes
- Repeat purchase rate: > 40%
- Seller count: 1,000+ active
```

---

## 7. Quick Reference

### API Endpoint Categories

```
Authentication:
├─ POST /api/auth/register
├─ POST /api/auth/login
├─ POST /api/auth/logout
├─ POST /api/auth/refresh-token
└─ POST /api/auth/forgot-password

Products:
├─ GET /api/products (with filters)
├─ GET /api/products/{id}
├─ GET /api/products/search
├─ GET /api/categories
└─ GET /api/trending

Cart & Orders:
├─ POST /api/cart/add
├─ GET /api/cart
├─ POST /api/orders
├─ GET /api/orders
└─ GET /api/orders/{id}

Users:
├─ GET /api/users/profile
├─ PUT /api/users/profile
├─ GET /api/users/addresses
├─ POST /api/users/addresses
└─ PUT /api/users/password

Real-Time (SignalR):
├─ ChatHub (seller/customer chat)
└─ NotificationHub (order updates)
```

### Common Flows

#### Add to Cart Flow
```
1. User selects variant & quantity
2. Validate (variant, quantity, stock)
3. Send POST /api/cart/add
4. Show toast notification
5. Update cart badge count
```

#### Order Placement Flow
```
1. User views cart
2. Step 1: Select/add delivery address
3. Step 2: Select payment method & coupon
4. Step 3: Review order & T&C
5. User taps Place Order
6. POST /api/orders
7. Show confirmation screen
8. Start listening for order updates (SignalR)
```

### Development Setup Checklist

```
Before Starting:
□ Read documentation files
□ Choose tech stack (Flutter/React Native)
□ Set up development environment
□ Set up Git repository
□ Create project structure

Design Phase:
□ Review UI/UX design guide
□ Review Daraz comparison
□ Create Figma mockups
□ Export design specs

Development Phase:
□ Implement Phase 1 features
□ Set up API calls
□ Add error handling
□ Build components following design system

Testing Phase:
□ Unit tests
□ Widget tests
□ Integration tests
□ Performance testing
□ Accessibility audit
```

### Key Files & Resources

```
Backend API:
- Base URL: https://api.sparkle-ecommerce.com/api/
- Default Port: 5279 (development)
- Authentication: JWT Bearer token

Documentation:
- System Architecture: See Section 2
- Features: See Section 3
- Design: See Section 4
- Patterns: See Section 5
- Timeline: See Section 6

Resources:
- Flutter: https://flutter.dev
- Firebase: https://firebase.google.com
- Figma: https://figma.com
```

---

**Documentation Version**: 1.0  
**Last Updated**: March 2026  
**Status**: Complete Mobile App Documentation
