# Sparkle Ecommerce - Daraz-Like Mobile Design Pattern

Alignment of Sparkle features with Daraz mobile app design patterns and user experience.

---

## Overview

This document maps Sparkle Ecommerce features to the proven Daraz design patterns, which have been refined through millions of users in South Asia. By following these patterns, the mobile app will feel familiar and intuitive to target users.

---

## 1. Navigation Structure

### Bottom Tab Navigation (5 Tabs)

```
Daraz Pattern (Proven):
├─ Tab 1: Home (Catalog/Browse)
├─ Tab 2: Search
├─ Tab 3: My Purchases (Orders)
├─ Tab 4: My Account (Profile)
└─ Tab 5: Menu/More (Settings, Help, etc.)

Alternative (Also Common):
├─ Tab 1: Home
├─ Tab 2: Search
├─ Tab 3: Wishlist
├─ Tab 4: Cart
└─ Tab 5: Account

Sparkle Implementation (RECOMMENDED):
├─ Tab 1: Home (Homepage)
├─ Tab 2: Search (Search & Browse)
├─ Tab 3: Wishlist (Saved Items)
├─ Tab 4: Orders (My Orders/Tracking)
└─ Tab 5: Account (Profile & Settings)

Rationale:
├─ Cart available from Home as floating button
├─ Wishlist as separate tab (allows browsing without purchase intent)
├─ Orders tab for tracking (critical for delivery-based commerce)
└─ Settings in Account tab (less frequent access)
```

### Tab Bar Design

```
┌─────────────────────────────────────┐
│ 🏠 Home │ 🔍 Search │ ❤ Wishlist  │
│         │           │              │
│ 📦 Orders │ 👤 Account             │
└─────────────────────────────────────┘

Specifications (Following Daraz):
├─ Height: 60-64px (with safe area)
├─ Icons: 24x24px, Bold/Filled style
├─ Labels: 10px, Hidden on phone (show on tablet)
├─ Active Color: Brand orange/primary
├─ Inactive Color: Gray
├─ Badge: Red circle on icon (for cart count, etc.)
└─ Swipe: Swipe left/right to navigate tabs
```

---

## 2. Homepage Design (Daraz Pattern)

### Layout Structure

```
┌─────────────────────────────────┐
│ Header Strip (50px)              │
│ Logo | Search | Location         │
├─────────────────────────────────┤
│                                  │
│ HERO CAROUSEL (210px)            │
│  [Ad1]  [Ad2]  [Ad3]  [Ads...]  │
│  ● ○ ○ ○ ○    (Dot indicators)  │
│  Auto-scroll + Tap navigation    │
│                                  │
├─────────────────────────────────┤
│ CATEGORY STRIP (80px)            │
│ [Electronics] [Fashion] [Home]   │
│ [Books] [Sports] [Beauty]        │
│ Horizontal scroll, icons + text  │
│                                  │
├─────────────────────────────────┤
│ FLASH SALE BANNER (100px)        │
│     ⏰ MEGA SALE                 │
│     Today 11am - 8pm             │
│  Product 1  Product 2  Product 3 │
│  Horizontal 2.5-column scroll    │
│                                  │
├─────────────────────────────────┤
│ REGULAR PRODUCT SECTIONS         │
│ "Just For You" / "Trending"      │
│ Product Grid (2 columns)         │
│  [P1] [P2]    [P3] [P4]          │
│                                  │
│ "Best Sellers"                   │
│ Product Grid (2 columns)         │
│                                  │
│ "New Arrivals"                   │
│ Product Grid (2 columns)         │
│                                  │
└─────────────────────────────────┘
```

### Hero Carousel Details (Daraz Pattern)

```
Characteristics:
├─ Height: 200-220px
├─ Width: Full screen (edge-to-edge)
├─ Auto-scroll: Every 5 seconds
├─ Swipe: Manual left/right navigation
├─ Indicators: Dot indicators (bottom center)
│  - Active dot: Highlight color
│  └─ Inactive dots: Gray
├─ Duration: 4-second pause before auto-rotate
├─ Tap Action: Deep link to promotion or category
│  - Example: Tap Ad → Flash sale page
│  - Example: Tap Brand → Brand shop
└─ Images: 16:9 aspect ratio (landscape)

Content Strategy (Daraz):
├─ 1st Banner: Top promotional event
├─ 2nd Banner: Brand/Seller featured
├─ 3rd Banner: Flash sale announcement
├─ 4th Banner: New category launch
├─ 5th Banner: Referral/Loyalty promotion
└─ Rotation: Change every 24-48 hours
```

### Category Strip (Daraz Pattern)

```
┌──────────────────────────────────┐
│ [Electronics] [Fashion] [Home..]  │
│  Horizontal continuous scroll     │
│  Icon (40x40px)                   │
│  Label (12px, Gray)               │
│  Selected: Orange text            │
│  Tap → Navigate to category page  │
└──────────────────────────────────┘

Categories to Show (Priority):
├─ Electronics (phones, laptops)
├─ Fashion (men, women, kids)
├─ Home & Garden
├─ Sports & Outdoors
├─ Beauty & Personal Care
├─ Books & Media
├─ Toys & Games
├─ Groceries (future)
└─ All Categories (shows full list)

Design Notes (Daraz-Like):
├─ Show 6-8 on screen (1.5 items width)
├─ Smooth horizontal scrolling
├─ Icons are simple, monochrome or 2-color
├─ Labels below icons (centered)
├─ No slider controls visible (smooth infinite scroll)
└─ Pull/DragTo scroll (gesture)
```

### Flash Sale Section (Daraz Pattern)

```
┌──────────────────────────────────┐
│     ⏰ Mega Sale                  │
│     Today 11am - 8pm             │
│     [⏱ 5h 23m 14s remaining]     │
├──────────────────────────────────┤
│ Offer1 Offer2 Offer3 Offer4...  │
│ (Horizontal scroll, 2.5 items)   │
│ Products show discount % badge   │
└──────────────────────────────────┘

Flash Sale Features (Daraz):
├─ Countdown Timer
│  ├─ Hours : Minutes : Seconds
│  ├─ Updates in real-time
│  ├─ Color changes as time runs out
│  └─ Refresh data every 30 seconds
├─ Product Cards Show
│  ├─ Product image
│  ├─ Discount % (big, red badge)
│  ├─ Discounted price (bold)
│  ├─ Original price (strikethrough)
│  └─ Stock indicator ("Only 5 left!")
├─ Interaction
│  ├─ Tap product → Details page
│  ├─ Tap "View All Flash Sales" → Full page
│  └─ Add to Cart (quick action)
└─ Update Interval
   ├─ Products: Every 1-2 hours
   ├─ Timer: Real-time (server time)
   └─ Stock: Updated on each interaction
```

### Section Layout Pattern (Daraz)

```
For "Trending", "Just For You", "Best Sellers", etc.:

┌──────────────────────────────────┐
│ 🎯 Trending (38px header)         │
│                                  │
│ ┌────────┬────────┐              │
│ │ Prod1  │ Prod2  │  (Grid 2col) │
│ │ Image  │ Image  │              │
│ │ Price  │ Price  │              │
│ │ Rating │ Rating │              │
│ └────────┴────────┘              │
│                                  │
│ [LOAD MORE] or Pagination        │
│ or Infinite Scroll               │
└──────────────────────────────────┘

Product Card in Grid:
├─ Image: Full width, 160px height (approx)
├─ Product name: 2 lines, truncated
├─ Price: Large, bold (#FF6B35 or primary)
├─ Original price: Strikethrough, gray
├─ Rating: Stars + count
├─ Seller badge (if not admin)
├─ Spark/Flash sale badge (if applicable)
└─ Border: None, shadow: Light

Spacing:
├─ Grid gap: 8px
├─ Section padding: 16px
├─ Section top margin: 16px
└─ Section bottom margin: 20px
```

---

## 3. Search & Discovery (Daraz Pattern)

### Search Bar Placement

```
Header Search Bar:
┌──────────────────────────────────┐
│ 🔍 Search in Sparkle   | 🎤 🎥   │
└──────────────────────────────────┘

Daraz Pattern Notes:
├─ Placeholder text: "Search in Sparkle"
├─ Icons: Microphone (voice), Camera (visual)
├─ Always prominent at top
├─ Tap → Full search screen
└─ Voice/Camera: Optional in Phase 2
```

### Search Results Page (Daraz Pattern)

```
┌──────────────────────────────────┐
│ ← | 🔍 "iPhone 14" | ⋮           │
├──────────────────────────────────┤
│ FILTERS | SORT ▼                 │
├──────────────────────────────────┤
│ Results (845 products)            │
│                                  │
│ ┌────────┬────────┐              │
│ │ Prod1  │ Prod2  │  (Grid)      │
│ └────────┴────────┘              │
│                                  │
│ [LOAD MORE] (Pagination)         │
│                                  │
└──────────────────────────────────┘

Daraz Pattern - Filters:
├─ Collapsible filter drawer (bottom sheet)
├─ Price slider (range selection)
├─ Brand multi-select checkboxes
├─ Rating filter (5★, 4★+, 3★+, etc.)
├─ Free Shipping toggle
├─ Today's Deals toggle
├─ Seller filter (top-rated sellers)
└─ Apply / Clear buttons

Sort Options (Daraz):
├─ Relevance (default)
├─ Best Selling
├─ Newest
├─ Price: Low to High
├─ Price: High to Low
├─ Highest Rating
└─ Most Reviewed
```

### Search Suggestions (Daraz Pattern)

```
As User Types:

Recent Searches:
├─ iPhone 14          (History)
├─ Samsung Galaxy     (History)
└─ AirPods Pro        (History)

Suggested Searches:
├─ iPhone 14 Pro      (Popular)
├─ iPhone 14 Pro Max  (Auto-complete)
├─ iPhone 13 Pro      (Trending)
└─ iPhone cases       (Related)

Tapping any:
├─ Search for query
├─ Show results page
└─ Auto-focus on search bar (can modify)
```

---

## 4. Product Detail Page (Daraz Pattern)

### Layout Structure

```
┌──────────────────────────────────┐
│ ← Details                        │
├──────────────────────────────────┤
│                                  │
│ [IMAGE 1] [IMAGE 2]             │
│  Carousel with thumbnails        │
│                                  │
│ ⭐⭐⭐⭐ (4.5) | 250 reviews    │
│                                  │
│ iPhone 14 Pro (128GB, Gold)      │
│                                  │
│ BDT 120,000                      │
│ BDT 150,000  [SAVE 20%]          │
│                                  │
│ FREE SHIPPING                    │
│ 7-Day Return Possible            │
│                                  │
│ SELLER: Apple Shop               │
│ ⭐ 4.8 | Response: 2 hours      │
│ [FOLLOW] [CHAT WITH SELLER]      │
│                                  │
│ [- QUANTITY +] [1]               │
│                                  │
│ ┌─ STICKY BUTTONS (48px) ───────┐
│ │ [ADD TO CART] [BUY NOW]       │
│ │ [SHARE] [❤ ADD TO WISHLIST]  │
│ └──────────────────────────────┘
│                                  │
│ DESCRIPTION | SPECS | REVIEWS    │
│                                  │
│ Full description here...         │
│                                  │
├──────────────────────────────────┤
│ More From Seller                 │
│ [Prod1] [Prod2] [Prod3]          │
└──────────────────────────────────┘
```

### Key Features (Daraz Pattern)

```
Image Gallery:
├─ Full-screen swipe navigation
├─ Thumbnail strip below
├─ Pinch to zoom (optional)
├─ Auto-indicator dots
└─ Tap thumbnail to jump

Variant Selection:
├─ Color swatches (visual)
├─ Size options (text/grid)
├─ Storage options (if applicable)
├─ Price updates based on variant
└─ Stock status per variant

Quantity Selector:
├─ [−] decrements quantity
├─ Center: editable number (1-99)
├─ [+] increments quantity
├─ Max quantity = stock available
└─ Show stock status

Seller Information:
├─ Seller logo (small)
├─ Seller name (clickable → Shop)
├─ Seller rating (stars + count)
├─ Response time/rate
├─ Follow button
├─ Chat button
└─ View seller's other products

Price Display:
├─ Current price (large, prominent)
├─ Original price (strikethrough)
├─ Discount % badge (red)
├─ Savings amount ("Save BDT 30,000")
└─ Price per unit (if bulk item)

Deals & Promotions:
├─ Free Shipping badge
├─ 7-Day Return badge
├─ Seller's coupon (if any)
├─ Extra discounts (wallet, etc.)
└─ Condition: New tags
```

### Sticky Action Buttons (Daraz Pattern)

```
Bottom Sticky Area (4 buttons in 2 rows or 1 row):

Layout Option 1: Single Row (if space)
┌──────────────────────────────────┐
│ [ADD TO CART] [BUY NOW] [❤] [⬆] │
└──────────────────────────────────┘

Layout Option 2: 2 Buttons (Primary)
┌──────────────────────────────────┐
│ [ADD TO CART] [BUY NOW]          │
│ [❤ WISHLIST] [SHARE]             │
└──────────────────────────────────┘

Button Specifications:
├─ Add to Cart: Secondary style, left
├─ Buy Now: Primary style (orange), right
├─ Wishlist: Heart icon, toggleable
├─ Share: Share icon
├─ Height: 48px (larger touch target)
├─ Sticky: Always visible while scrolling
├─ Background: White with shadow
└─ Actions:
   ├─ Add to Cart → Add + Show toast
   ├─ Buy Now → Redirect to checkout
   ├─ Wishlist → Toggle heart, show toast
   └─ Share → Share modal/dialog
```

---

## 5. Cart & Checkout (Daraz Pattern)

### Cart Page (Daraz Style)

```
┌──────────────────────────────────┐
│ ← My Cart (2)                    │
├──────────────────────────────────┤
│                                  │
│ Cart Item 1:                     │
│ [Image] iPhone 14 Pro            │
│         Gold | 128GB             │
│         BDT 120,000 | Qty [−] 1 [+]
│         [Remove] [Wishlist]      │
│                                  │
│ Cart Item 2:                     │
│ [Image] AirPods Pro              │
│         White | 64GB             │
│         BDT 25,000 | Qty [−] 2 [+]
│         [Remove] [Wishlist]      │
│                                  │
│ ──────────────────────────────   │
│ Promo Code: [ENTER CODE] [APPLY] │
│                                  │
│ ──────────────────────────────   │
│                                  │
│ PRICE DETAILS                    │
│ Subtotal        BDT 170,000      │
│ Discount        -BDT 20,000      │
│ Shipping        FREE             │
│ Tax             BDT 5,000        │
│ ──────────────────────────────   │
│ TOTAL           BDT 155,000      │
│                                  │
├──────────────────────────────────┤
│ [CONTINUE SHOPPING] [CHECKOUT]   │
└──────────────────────────────────┘

Daraz Pattern Notes:
├─ Cart items show seller name (multi-seller)
├─ Easy remove/wishlist with swipe
├─ Quantity editor is prominent
├─ Promo code prominent (not hidden)
├─ Price breakdown clear
├─ Checkout button sticky/prominent
└─ Save for later (optional)
```

### Checkout Steps (Daraz Pattern)

Daraz uses a 3-step or 2-step checkout:

```
STEP 1: ADDRESS
└─ Select saved address or add new
└─ Confirm delivery location

STEP 2: PAYMENT
├─ Select payment method
└─ Confirm coupon/offers

CONFIRMATION
├─ Review order
├─ Place order
└─ Show confirmation

Sparkle Implementation:
STEP 1: DELIVERY (Address)
├─ Show saved addresses
├─ Option to edit
├─ Option to add new
├─ Delivery cost (if any)
└─ Next button

STEP 2: PAYMENT (Method)
├─ Select payment type
├─ Coupon code entry
├─ Notes for seller
└─ Next button

STEP 3: REVIEW (Confirm)
├─ Order summary
├─ Address confirmation
├─ Payment confirmation
├─ T&C checkbox
└─ PLACE ORDER button
```

### Order Confirmation (Daraz Pattern)

```
┌──────────────────────────────────┐
│                                  │
│     ✓ Order Confirmed!           │
│                                  │
│  Order #ORD-2023-001234          │
│  Date: Jun 14, 2023, 3:45 PM     │
│                                  │
│  BDT 155,000                     │
│  Est. Delivery: Jun 16-18        │
│                                  │
│  [Track Order] [View Details]    │
│                                  │
│ ─────────────────────────────── │
│                                  │
│ 🎉 You Saved BDT 20,000! 🎉     │
│ Next: Use 15% code → NEXT15 ←   │
│                                  │
│ ─────────────────────────────── │
│                                  │
│ [CONTINUE SHOPPING]              │
│                                  │
└──────────────────────────────────┘

Daraz Pattern:
├─ Success animation/icon
├─ Order number prominent
├─ Delivery timeframe highlighted
├─ Quick actions: Track, Details
├─ Promotional message for next purchase
├─ Continue shopping incentive
└─ Optional: Ask for rating after delivery
```

---

## 6. Orders & Tracking (Daraz Pattern)

### Orders List (Daraz Pattern)

```
┌──────────────────────────────────┐
│ ← My Purchases                   │
├──────────────────────────────────┤
│ [All] [Upcoming] [Delivered] [Cancelled]
│                                  │
│ Order 1:                         │
│ ┌────────────────────────────────┤
│ │ ORD-2023-001234                │
│ │ [Product Image] iPhone 14 Pro  │
│ │ ● Out for Delivery             │
│ │ BDT 155,000 | Est. Jun 16-18   │
│ │ [TRACK] [DETAILS] [...menu]    │
│ └────────────────────────────────┤
│                                  │
│ Order 2:                         │
│ ┌────────────────────────────────┤
│ │ ORD-2023-001233                │
│ │ [Product Image] AirPods Pro    │
│ │ ✓ Delivered (Jun 14)           │
│ │ BDT 25,000 | Delivered on time │
│ │ [RATE & REVIEW] [...menu]      │
│ └────────────────────────────────┤
│                                  │
└──────────────────────────────────┘

Daraz Pattern:
├─ Tabbed filters (All/Status)
├─ Most recent orders first
├─ Order card shows: ID, product, status
├─ Status with color-coded dot
├─ Quick actions inline
├─ Swipe for more actions (optional)
└─ Pull-to-refresh (reload orders)
```

### Order Tracking (Daraz Pattern)

```
┌──────────────────────────────────┐
│ ← Track Order ORD-001234         │
├──────────────────────────────────┤
│                                  │
│ TIMELINE VIEW:                   │
│                                  │
│ ○ Pending                        │
│  └─ Jun 14, 2:30 PM             │
│    Order confirmed               │
│                                  │
│ ○ Seller Preparing               │
│  └─ Jun 14, 5:00 PM             │
│    Seller is preparing items    │
│                                  │
│ ●  Out for Delivery              │
│  └─ Jun 16, 10:00 AM             │
│    Estimated delivery: Today    │
│    Rider: Rajon | Rating: 4.8    │
│    [CONTACT RIDER]               │
│                                  │
│ ○ Delivered                      │
│  └─ Jun 16 (Expected)            │
│    Awaiting delivery             │
│                                  │
├──────────────────────────────────┤
│                                  │
│ DELIVERY ADDRESS:                │
│ 456 Dhanmondi, Dhaka 1205        │
│ +8801700123456                   │
│                                  │
│ [CONTACT SELLER] [HELP]          │
│                                  │
└──────────────────────────────────┘

Daraz Pattern:
├─ Vertical timeline (visual)
├─ Current status highlighted
├─ Completed steps marked with checkmark
├─ Future steps empty circles
├─ Timeline is scrollable/expandable
├─ Rider details (when assigned)
├─ Quick contact options
├─ Delivery address shown
├─ Automatic refresh updates status
└─ Push notification on status change
```

---

## 7. User Account (Daraz Pattern)

### Account Menu (Daraz Pattern)

```
┌──────────────────────────────────┐
│ ← Profile                        │
├──────────────────────────────────┤
│                                  │
│ [Profile Photo]                  │
│ Username                         │
│ user@example.com                 │
│ +88 01700123456                  │
│ [EDIT PROFILE]                   │
│                                  │
├──────────────────────────────────┤
│                                  │
│ YOUR ACTIVITY                    │
│ 💰 Wallet      [BDT 5,000]       │
│ ❤️  Wishlist    [12 items]        │
│ 🏪 Selling      [10 products]    │
│ ⭐ Reviews      [5 reviews]       │
│ 📍 My Addresses [4 addresses]    │
│                                  │
├──────────────────────────────────┤
│                                  │
│ ACCOUNT SETTINGS                 │
│ 🔐 Password & Security           │
│ 📧 Email & Phone                 │
│ 🔔 Notification Settings         │
│ 🕐 Activity log                  │
│                                  │
├──────────────────────────────────┤
│                                  │
│ MORE                             │
│ ❓ Help Center                    │
│ 📋 Terms & Conditions            │
│ 🛡️  Privacy Policy               │
│ ⭐ Rate App (4.8★)               │
│ 🔗 Share App / Refer             │
│                                  │
│ [LOGOUT]                         │
│                                  │
└──────────────────────────────────┘

Daraz Pattern:
├─ Profile photo with edit option
├─ Quick stats (wallet, wishlist, etc.)
├─ Grouped menu items
├─ Icons for visual distinction
├─ Settings well-organized
├─ Help/Support accessible
├─ Logout at bottom
└─ Swipe actions on menu items (optional)
```

---

## 8. Key Design Differences from Web

```
Mobile (Daraz-Pattern):
1. Full-screen immersive experience
2. Bottom navigation (always visible)
3. Vertical scroll-first design
4. Touch-optimized buttons (44x44 minimum)
5. Simplified forms (fewer fields)
6. Fast loading (optimized images)
7. Real-time notifications (push)
8. Offline capabilities
9. Gesture-based navigation
10. Single column layouts

Web (Current):
1. Sidebar + content area
2. Top navigation menu
3. Multi-column layouts
4. Mouse/keyboard optimized
5. Comprehensive forms
6. More detailed information
7. In-app notifications
8. Requires connectivity
9. Menu-based navigation
10. Grid layouts possible
```

---

## 9. Daraz Success Factors to Replicate

```
1. Fast Checkout
   ├─ 2-3 steps only
   ├─ Pre-filled addresses
   └─ One-click payment options

2. Transparent Tracking
   ├─ Real-time status updates
   ├─ Push notifications
   └─ Rider contact info

3. Trust Signals
   ├─ Seller ratings prominent
   ├─ Verified buyer reviews
   ├─ Product authenticity badges
   └─ Money-back guarantee

4. Discounts & Deals
   ├─ Flash sales with countdown
   ├─ Category-wide promotions
   ├─ Seasonal campaigns
   └─ Loyalty rewards

5. Mobile-First Content
   ├─ High-quality images
   ├─ Video product demos
   ├─ User-generated content
   └─ Live seller interactions

6. Performance
   ├─ Fast page loads (<2s)
   ├─ Smooth scrolling (60fps)
   ├─ Minimal data usage
   └─ Works on 2G/3G networks

7. Communication
   ├─ In-app chat with sellers
   ├─ Order updates via push
   ├─ Help support integrated
   └─ Q&A on products

8. Personalization
   ├─ Recommendations on homepage
   ├─ Search history
   ├─ Saved items across devices
   └─ Personalized deals
```

---

## 10. Implementation Checklist

```
Phase 1 (MVP):
☐ Bottom tab navigation (5 tabs)
☐ Homepage with hero carousel
☐ Category quick links
☐ Trending/Flash sale sections
☐ Search with auto-complete
☐ Product detail page
☐ Cart management
☐ 3-step checkout
☐ Order confirmation
☐ Basic order tracking
☐ Account profile
☐ Address management

Phase 2 (Expansion):
☐ Order filters/tabs
☐ Wishlist with multiple lists
☐ Product reviews & ratings
☐ Seller shop pages
☐ Real-time chat
☐ Advanced payment methods
☐ Return/refund flow
☐ Seller dashboard
☐ Push notifications
☐ Analytics integration

Phase 3 (Polish):
☐ Performance optimization
☐ Offline capabilities
☐ Advanced filters
☐ Personalized recommendations
☐ Dark mode (optional)
☐ Accessibility audit
☐ Multi-language support
☐ A/B testing framework

Phase 4 (Growth):
☐ AI recommendations
☐ Live streaming
☐ Loyalty program
☐ Advanced seller tools
☐ Community features (Q&A)
☐ Influencer integrations
☐ International expansion
```

---

**Daraz Pattern Alignment Version**: 1.0  
**Last Updated**: March 2026  
**Focus**: Mobile-first design following proven market leader patterns
