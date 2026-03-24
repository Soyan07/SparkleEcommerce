# Sparkle Ecommerce - Mobile UI/UX Design Guide

Design standards and specifications for the mobile application.

---

## 1. Design System Overview

### Color Palette

#### Primary Colors
```
Brand Primary (Orange):     #FF6B35
Brand Secondary (Teal):     #0E9B6B
Dark Gray (Text):           #1F2937
Light Gray (Background):    #F3F4F6
White:                      #FFFFFF
Black:                      #000000
```

#### Semantic Colors
```
Success/Positive:           #10B981 (Green)
Warning:                    #F59E0B (Amber)
Error/Danger:               #EF4444 (Red)
Info:                       #3B82F6 (Blue)
Disabled/Inactive:          #D1D5DB (Gray)
Link Color:                 #0E9B6B (Teal)
```

#### Status Badge Colors
```
Pending:                    #F59E0B (Amber)
Confirmed:                  #38B000 (Green)
SellerPreparing:            #3B82F6 (Blue)
OutForDelivery:             #8B5CF6 (Purple)
Delivered:                  #10B981 (Green)
Failed/Error:               #EF4444 (Red)
Cancelled:                  #6B7280 (Gray)
Return:                     #FF6B35 (Orange)
```

### Typography

#### Font Family
```
Primary Font:     Inter / SF Pro Display / Roboto
Heading Font:     Inter Bold / SF Pro Display Bold
Monospace:        SF Mono / Roboto Mono (for codes)
Web Safe:         System fonts (platform native)
```

#### Font Scale
```
Display (48px):     Font Weight 700, Line Height 1.2
Heading 1 (32px):   Font Weight 700, Line Height 1.2
Heading 2 (24px):   Font Weight 700, Line Height 1.3
Heading 3 (20px):   Font Weight 700, Line Height 1.3
Heading 4 (18px):   Font Weight 700, Line Height 1.4
Body Large (18px):  Font Weight 400, Line Height 1.5
Body (16px):        Font Weight 400, Line Height 1.5
Body Small (14px):  Font Weight 400, Line Height 1.5
Caption (12px):     Font Weight 400, Line Height 1.5
Label (12px):       Font Weight 600, Line Height 1.5
```

### Spacing Scale (8px Grid System)
```
0   = 0px
1   = 4px
2   = 8px
3   = 12px
4   = 16px
5   = 20px
6   = 24px
7   = 28px
8   = 32px
10  = 40px
12  = 48px
16  = 64px
20  = 80px
24  = 96px
```

### Border Radius
```
None:       0px
Small:      4px
Medium:     8px
Large:      12px
Extra Large:16px
Full (Circle):50%
```

### Shadow System
```
Elevation 0:    No shadow
Elevation 1:    0px 1px 2px rgba(0,0,0,0.05)
Elevation 2:    0px 1px 3px rgba(0,0,0,0.1), 0px 1px 2px rgba(0,0,0,0.06)
Elevation 3:    0px 10px 15px -3px rgba(0,0,0,0.1)
Elevation 4:    0px 20px 25px -5px rgba(0,0,0,0.1)
```

---

## 2. Layout & Navigation

### Bottom Tab Navigation (Primary Navigation)

```
┌─────────────────────────────────────┐
│     APPLICATION CONTENT AREA        │
│                                     │
│                                     │
│                                     │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│ 🏠  🔍  ❤️  📦  👤                │
│ Home Search Wishlist Orders Account  │
└─────────────────────────────────────┘
```

#### Tab Structure (5 Tabs)
1. **Home** - Homepage, categories, banner
2. **Search** - Product search, filters, results
3. **Wishlist** - Saved products, wishlists
4. **Orders** - Order history, tracking
5. **Account** - Profile, settings, logout

#### Tab Bar Specifications
- Height: 64px (56px content + 8px safe area)
- Background: White (#FFFFFF)
- Border Top: 1px #E5E7EB
- Icon Size: 24x24px
- Active Color: #FF6B35 (Primary)
- Inactive Color: #6B7280 (Gray)
- Label Font: 12px, Weight 500
- Icon + Label padding: 8px vertical

### Header/Top Bar

#### Standard Header
```
┌──────────────────────────────────────┐
│ ← | Title/Content | ⋯                │
└──────────────────────────────────────┘
Height: 56px
```

- Back button (left, if not home)
- Title/Content (center)
- Right action button (search, menu, etc.)
- Status bar color: Primary color or white

#### Homepage Header (Special)
```
┌──────────────────────────────────────┐
│ 🏠 Sparkle | 🔍 | 📍 Location | ⋯    │
└──────────────────────────────────────┘
```

- Logo/Title (left)
- Search icon (if space)
- Location selector
- Menu/settings

### Screen Layouts

#### Full Screen Layout
```
┌─ Status Bar (20px) ────────────┐
├─ Header (56px) ────────────────┤
├─ Safe Area Content             │
│                                 │
│ [Content fills vertical space]  │
│                                 │
├─ [Tab Navigation (64px)] ───────┤
└─ Safe Area (bottom) ────────────┘

Total Safe Area: Device - Status - Header - Tab Size
```

#### Safe Area Considerations
- **Top Safe Area**: 20px (status bar)
- **Bottom Safe Area**: 34px (notch) to 64px (tab bar)
- **Left/Right Safe Area**: 0px (full width)
- **Padding**: Always add 16px horizontal padding inside safe area

---

## 3. Navigation Patterns - Daraz Style

### Homepage Navigation Structure

```
Homepage
├── Hero Banner (Carousel)
│   └── Tap Banner → Promotion/Category Page
│
├── Category Quick Links (Horizontal Scroll)
│   ├── 8-12 Categories
│   └── Tap Category → Category Listing Page
│
├── Flash Sale Section
│   └── View All → Flash Sale Page
│
├── Trending Products Section
│   └── View All → Trending Products Page
│
├── Personalized Sections
│   └── View All → Browse All/Category Page
│
└── Bottom Tab Navigation
    └── Navigate to Other Main Sections
```

### Product Discovery Flow

```
Browse Products:
├── Tap Category/Search
├── Filter & Sort Options (Drawer/Modal)
├── Product Grid (with pagination)
│   └── Tap Product → Product Detail Page
│       ├── Review Product
│       ├── Add to Cart
│       └── Proceed to Checkout
└── Back to Previous Screen
```

### Checkout Navigation Flow

```
Checkout:
├── Cart Screen
│   └── Proceed to Checkout
├── Address Selection (Step 1)
│   └── Add/Select Address
├── Payment Selection (Step 2)
│   └── Choose Payment Method
├── Order Review (Step 3)
│   └── Confirm & Place Order
├── Order Confirmation
│   ├── View Order Details
│   ├── Track Order
│   └── Continue Shopping
└── Back to Home
```

---

## 4. Component Library

### Button Components

#### Primary Button (CTA)
```
Appearance:
├── Background: #FF6B35
├── Text Color: White
├── Height: 44px
├── Border Radius: 8px
├── Padding: 12px 24px
├── Font: 16px, Weight 600
├── Shadow: Elevation 2

States:
├── Default: Normal
├── Hover: Darker shade (#E55A23)
├── Active/Pressed: Darker (#D14B13)
├── Disabled: #D1D5DB with opacity 50%
└── Loading: Spinner inside button
```

#### Secondary Button
```
Appearance:
├── Background: #F3F4F6
├── Text Color: #1F2937
├── Border: 1px #D1D5DB
├── Height: 44px
├── Border Radius: 8px
└── Same padding/font as primary

States: Similar to primary
```

#### Ghost/Link Button
```
Appearance:
├── Background: Transparent
├── Text Color: #FF6B35 (primary)
├── No Border
├── Height: 44px
├── Underline on hover (optional)

States:
├── Default: Normal text
├── Hover: Darker color or underline
└── Active: Color change
```

#### Icon Button
```
Appearance:
├── Size: 40x40px or 48x48px (minimum touch target)
├── Icon Size: 24x24px
├── Border Radius: 4px (or circular for some)
├── Padding: 8px

States:
├── Default: Gray icon on transparent
├── Active/Selected: Primary color background + white icon
└── Disabled: Gray icon with 50% opacity
```

### Input Fields

#### Text Input
```
Appearance:
├── Height: 44px
├── Padding: 12px 16px
├── Background: #F3F4F6
├── Border: 1px #D1D5DB
├── Border Radius: 8px
├── Font: 16px, Normal weight
├── Placeholder Color: #9CA3AF

States:
├── Default: As described
├── Focused: Border color #FF6B35, Shadow elevation 2
├── Filled: Dark text #1F2937
├── Disabled: Background #E5E7EB, Text gray, no interaction
├── Error: Border #EF4444, Error icon on right, error message below
└── Success: Border #10B981, Check icon on right
```

#### Textarea
```
Similar to text input but:
├── Height: Min 100px, expandable
├── Resize: Yes (vertical only)
└── Line Height: 1.5
```

#### Dropdown/Select
```
Appearance:
├── Same as text input
├── Dropdown arrow on right (gray)
├── On tap: Open modal/list selector
└── Selected value displayed
```

#### Checkbox
```
Appearance:
├── Size: 24x24px
├── Border Radius: 4px
├── Border: 2px #D1D5DB
├── Unchecked: Transparent background

States:
├── Unchecked: As described
├── Checked: Background #FF6B35, White checkmark, border none
└── Disabled: Gray background, disabled state
```

#### Radio Button
```
Appearance:
├── Size: 24x24px
├── Circular
├── Border: 2px #D1D5DB
├── Unchecked: Transparent background

States:
├── Unchecked: As described
├── Checked: Inner circle #FF6B35, outer border same color
└── Disabled: Gray
```

#### Toggle Switch
```
Appearance:
├── Width: 56px
├── Height: 32px
├── Border Radius: Full (16px)
├── Padding: 2px

States:
├── Off: Gray background #D1D5DB, white circle left
├── On: Primary background #FF6B35, white circle right
└── Disabled: Gray with reduced opacity
```

### Cards & Containers

#### Product Card (Grid View)
```
┌──────────────────────┐
│    Product Image     │ (Height: 180px, full width)
├──────────────────────┤
│ Product Name...      │ (2 lines max, truncate)
├──────────────────────┤
│ ⭐ 4.5 (250)        │ (Rating + reviews)
├──────────────────────┤
│ BDT 2,500            │ (Price prominent)
│ BDT 3,500 [STRIKE]   │ (Original price)
├──────────────────────┤
│ [+ ADD TO CART] ▥    │ (Action buttons, 50/50 split)
└──────────────────────┘

Card Dimensions:
├── Width: 50% of screen - 8px margin (grid 2 columns)
├── Height: 280-300px
├── Border Radius: 8px
├── Padding: 0 (no padding, image bleeds)
├── Shadow: Elevation 1
└── Spacing: 8px gap between items
```

#### Product Card (List/Detail)
```
┌────────────────────────────────────┐
│ Image | Name, Price, Rating, Seller│
│ (100) | Add to Cart, Wishlist       │
└────────────────────────────────────┘

Dimensions:
├── Height: 120px
├── Full width
├── Padding: 12px
├── Image: 100x100px
├── Content: Flex column right side
└── Shadow: Elevation 0 or 1
```

#### Order/List Item Card
```
┌────────────────────────────────────┐
│ Order ID: ORD-2023-001234          │
│ Status: Out for Delivery ●         │
│ Payment: Rs 2,500 | 2 items        │
│ Expected: Jun 15 | Track Order →   │
└────────────────────────────────────┘

Dimensions:
├── Full width
├── Padding: 16px
├── Margin: 8px
├── Border Radius: 8px
├── Background: White
└── Shadow: Elevation 1
```

#### Seller Card
```
┌──────────────────────────┐
│ [Logo] Seller Name       │
│ ⭐ 4.8 | 1000s followers │
│ Response Time: 2 hours   │
│ [Follow] [Visit Shop] →  │
└──────────────────────────┘

Dimensions:
├── Width: Full or grid (2-3 columns)
├── Padding: 12px
├── Border: 1px #E5E7EB
└── Border Radius: 8px
```

### Rating Component

#### Star Rating Display
```
⭐⭐⭐⭐☆ (4.0)

Specifications:
├── Star Size: 16px (display), 24px (interactive)
├── Colors: #FCD34D (filled), #D1D5DB (empty)
├── Spacing: 2px between stars
├── Next to number: 12px gap
└── Font: 14px, medium weight
```

#### Star Rating Input
```
☆ ☆ ☆ ☆ ☆  (Tap to rate)

Specifications:
├── Star Size: 36px
├── Touch Area: 44x44px
├── Spacing: 8px
├── Colors: Gray (default), Orange (hovered/selected)
└── Feedback: Haptic on select
```

### Badge/Chip Components

#### Product Feature Badges
```
[Sparkle ⭐] [Free Shipping] [Trending]

Specifications:
├── Background: Light gray #F3F4F6 or Color-specific
├── Text Color: Dark gray or Color-specific
├── Padding: 4px 8px
├── Border Radius: 12px
├── Font: 12px, Medium weight
├── Max Width: Fit content
└── Examples:
    ├── Free Shipping: Green theme
    ├── Discount: Red/Orange theme
    ├── Featured: Blue theme
    └── Sale/Trending: Orange theme
```

#### Status Badge (Order/Product)
```
● Pending  ● Shipped  ● Delivered  ● Cancelled

Specifications:
├── Height: 24px
├── Padding: 4px 12px
├── Border Radius: 12px
├── Font: 12px, Medium weight
├── Dot Size: 8px
├── Color: According to status (see color table above)
└── Text Color: White (on colored background)
```

### Modals & Dialogs

#### Alert Dialog
```
┌─────────────────────────────────┐
│ Title (Important)                │
├─────────────────────────────────┤
│ Message text                     │
│ goes here, can be              │
│ multiple lines.                  │
├─────────────────────────────────┤
│ [Cancel]      [Confirm/Delete]  │
└─────────────────────────────────┘

Specifications:
├── Max Width: 90% or 320px
├── Padding: 24px
├── Border Radius: 12px
├── Z-Index: Above everything
├── Backdrop: Black 40% opacity
├── Button Spacing: 12px gap
└── Title Font: 18px, Bold
```

#### Bottom Sheet Modal
```
┌─────────────────────────────────┐
│ ⁼⁼ (Drag indicator)              │
│ Filter Options                   │
├─────────────────────────────────┤
│ Content area (scrollable)        │
│                                  │
│                                  │
├─────────────────────────────────┤
│ [Cancel] [Apply Filters]         │
└─────────────────────────────────┘

Specifications:
├── Width: 100%
├── Max Height: 90% of screen
├── Rounded corners: Top 12px
├── Padding: 16px
├── Drag handle: 4x40px bar
├── Border Top: 1px #E5E7EB
├── Animation: Slide up from bottom
└── Dismiss: Swipe down or outside
```

### Toast/Snackbar Notifications

#### Toast Message
```
✓ Product added to cart (auto fade after 3sec)

Specifications:
├── Position: Bottom (above tab bar, 16px margin)
├── Width: 90% or max 400px
├── Height: Auto (min 44px)
├── Padding: 12px 16px
├── Border Radius: 8px
├── Background: Dark (success green for success)
├── Text Color: White
├── Icon Size: 20px
├── Icon Margin: 12px right
├── Font: 14px
├── Duration: 3-5 seconds (auto dismiss)
├── Animation: Slide up with fade
└── Z-Index: High (above modals)
```

### Dividers & Separators

#### Horizontal Divider
```
─────────────────────

Specifications:
├── Height: 1px
├── Color: #E5E7EB
├── Margin: 16px vertical
└── Width: Full width
```

#### Section Divider with Text
```
─── OR ───

Specifications:
├── Color: #D1D5DB
├── Text Color: #6B7280
├── Font: 12px, Medium weight
├── Margin: 16px vertical
└── Balanced spacing around text
```

---

## 5. Screen Design Specifications

### Homepage Design Pattern

```
┌─────────────────────────────────────┐
│ Status Bar (20px)                   │
├─────────────────────────────────────┤
│ Header (56px)  🏠 Sparkle | 🔍 | 📍 │
├─────────────────────────────────────┤
│ ┌───────────────────────────────────┤
│ │ [HERO CAROUSEL (200px)]           │
│ │ Auto-scroll, tap to action        │
│ └───────────────────────────────────┤
│                                      │
│ Quick Categories (horizontal scroll) │
│ [Electronics][Fashion][Home]...      │
│                                      │
│ ┌────────┬─────────┐                │
│ │ Product│ Product │  Flash Sale    │
│ │  Image │  Image  │    Section     │
│ │ Price  │ Price   │   (Grid 2 col) │
│ └────────┴─────────┘                │
│                                      │
│ [Trending Products Section]          │
│ [Recommended For You Section]        │
│                                      │
├─────────────────────────────────────┤
│ Bottom Tab Nav (64px)                │
└─────────────────────────────────────┘
```

### Category/Search Results Page

```
┌─────────────────────────────────────┐
│ Header (56px)  ← Category | ⋯       │
├─────────────────────────────────────┤
│ Filters (Collapsible Bar)            │
│ [Filter 🔽] [Sort 🔽]               │
├─────────────────────────────────────┤
│ ┌────────┬─────────┐                │
│ │Product │ Product │  Product Grid  │
│ │ Card   │ Card    │  (Grid 2 col)  │
│ └────────┴─────────┘                │
│                                      │
│ ┌────────┬─────────┐                │
│ │Product │ Product │  Load More /   │
│ │ Card   │ Card    │  Pagination    │
│ └────────┴─────────┘                │
│                                      │
├─────────────────────────────────────┤
│ Bottom Tab Nav (64px)                │
└─────────────────────────────────────┘
```

### Product Detail Page

```
┌──────────────────────────────────────┐
│ Header (56px)  ← Details | ⋯         │
├──────────────────────────────────────┤
│ [Image Carousel] (200px height)      │
│ Auto indicators, tap to zoom         │
├──────────────────────────────────────┤
│ ⭐ 4.5 (250) | Sparkle ⭐           │
│ iPhone 14 Pro                        │
├──────────────────────────────────────┤
│ BDT 120,000                          │
│ BDT 150,000 [Save 30%]               │
├──────────────────────────────────────┤
│ Color:  [Gold] [Silver] [Deep Purple]│
│ Storage: [128GB] [256GB] [512GB]     │
│ Qty:  [-] 1 [+]                      │
├──────────────────────────────────────┤
│ ┌─ STICKY FOOTER (88px) ──────────────┤
│ │ [ADD TO CART] [BUY NOW] [❤️]       │
│ └──────────────────────────────────────┤
│                                        │
│ Shipping: Free | Est. Jun 15           │
│ Seller: Apple Shop ⭐ 4.7             │
│ [Follow] [Chat with Seller]            │
│                                        │
│ Description Tab | Specs | Reviews      │
│ Full description...                    │
│                                        │
│ Reviews Section                        │
│ ⭐⭐⭐⭐ (4.5)  [5★] [4★] ...        │
│ Top Reviews...                         │
│                                        │
├──────────────────────────────────────┤
│ Bottom Tab Nav (64px)                 │
└──────────────────────────────────────┘
```

### Cart Page

```
┌──────────────────────────────────────┐
│ Header (56px)  [Cart] (3)            │
├──────────────────────────────────────┤
│ Cart Items                            │
│                                       │
│ ┌────────────────────────────────────┤
│ │ [Img] iPhone 14 Pro | Gold        │
│ │      BDT 120,000 | Qty: [−] 1 [+] │
│ │      Remove | Wishlist             │
│ └────────────────────────────────────┤
│                                       │
│ ┌────────────────────────────────────┤
│ │ [Img] AirPods Pro | White         │
│ │      BDT 25,000 | Qty: [−] 2 [+]  │
│ │      Remove | Wishlist             │
│ └────────────────────────────────────┤
│                                       │
│ Continue Shopping                     │
│                                       │
├──────────────────────────────────────┤
│ PRICE SUMMARY                         │
│ Subtotal        BDT 170,000           │
│ Discount        −BDT 20,000           │
│ Promo Code      [Enter] [Apply]       │
│ Shipping        FREE                  │
│ Tax             BDT 5,000             │
│ ──────────────────────────────────────│
│ TOTAL           BDT 155,000           │
├──────────────────────────────────────┤
│ [Proceed to Checkout] (Sticky)        │
└──────────────────────────────────────┘
```

### Checkout: Address Selection

```
┌──────────────────────────────────────┐
│ Header (56px)  [Checkout] 1 of 3     │
├──────────────────────────────────────┤
│ STEP 1: DELIVERY ADDRESS              │
│                                        │
│ Saved Addresses:                       │
│                                        │
│ ◉ Home                                │
│   456 Dhanmondi, Dhaka 1205           │
│   Phone: 01700123456                  │
│   [Edit] [Delete] [Make Default]      │
│                                        │
│ ○ Office                              │
│   789 Gulshan, Dhaka 1212             │
│   Phone: 01800456789                  │
│   [Edit]                              │
│                                        │
│ + Add New Address                     │
│                                        │
│ MAP: [Selected address map]           │
│ Est. Delivery: Jun 15-17               │
│                                        │
├──────────────────────────────────────┤
│ [Back] [Next Step: Payment] (Sticky)  │
└──────────────────────────────────────┘
```

### Checkout: Payment Method

```
┌──────────────────────────────────────┐
│ Header (56px)  [Checkout] 2 of 3     │
├──────────────────────────────────────┤
│ STEP 2: PAYMENT METHOD                │
│                                        │
│ ◉ Cash on Delivery                    │
│   Pay when delivered                  │
│                                        │
│ ○ Bkash                               │
│   Mobile wallet payment               │
│                                        │
│ ○ Nagad                               │
│   Mobile wallet payment               │
│                                        │
│ ○ Card Payment                        │
│   Credit/Debit card                   │
│                                        │
│ ○ Bank Transfer                       │
│   Direct bank transfer                │
│                                        │
│ ○ Sparkle Wallet                      │
│   Balance: BDT 5,000                  │
│                                        │
│ NOTES (Optional):                      │
│ [Special instructions for seller]     │
│                                        │
├──────────────────────────────────────┤
│ [Back] [Next Step: Review] (Sticky)   │
└──────────────────────────────────────┘
```

### Checkout: Order Review & Confirmation

```
┌──────────────────────────────────────┐
│ Header (56ps)  [Checkout] 3 of 3     │
├──────────────────────────────────────┤
│ ORDER REVIEW                          │
│                                        │
│ Items (2):                             │
│ • iPhone 14 Pro x1  BDT 120,000       │
│ • AirPods Pro x2    BDT 50,000        │
│ ──────────────────────────────────────│
│ Subtotal            BDT 170,000       │
│ Discount            −BDT 20,000       │
│ Shipping            FREE              │
│ Tax                 BDT 5,000         │
│ ──────────────────────────────────────│
│ TOTAL               BDT 155,000       │
│                                        │
│ Address: 456 Dhanmondi, Dhaka         │
│ Payment: Cash on Delivery             │
│ Est. Delivery: Jun 15-17               │
│                                        │
│ ☐ I agree to Terms & Conditions      │
│                                        │
├──────────────────────────────────────┤
│ [Back] [Place Order] (Sticky)         │
└──────────────────────────────────────┘
```

### Order Confirmation Page

```
┌──────────────────────────────────────┐
│ [✓] Order Confirmed!                 │
│                                        │
│ Order #ORD-2023-001234                │
│ Order Date: June 14, 2023              │
│                                        │
│ Payment Status: Awaiting (COD)         │
│ Est. Delivery: Jun 15-17               │
│                                        │
│ Items (2 items):                       │
│ • iPhone 14 Pro          BDT 120,000   │
│ • AirPods Pro x2         BDT 50,000    │
│                                        │
│ Total Amount: BDT 155,000              │
│                                        │
│ [View Order Details] [Track Order]    │
│                                        │
│ ┌──────────────────────────────────┤  │
│ │ 🎉 You saved BDT 20,000! 🎉     │  │
│ │ Next time use code: NEXT15      │  │
│ └──────────────────────────────────┤  │
│                                        │
├──────────────────────────────────────┤
│ [Continue Shopping]                   │
└──────────────────────────────────────┘
```

---

## 6. Mobile-Specific Design Patterns (Daraz-like)

### Hero Banner Carousel
```
Auto-rotating banner (5-second interval):
├── Previous/Next indicators
├── Dot indicators (bottom)
├── Tap to navigate to promotion
└── Swipe to manual navigate

Dimensions:
├── Height: 200-220px
├── Width: Full screen
├── Padding: 0 (edge-to-edge)
└── Image Aspect: 16:9 or device ratio
```

### Horizontal Scroll Sections
```
[Product 1] [Product 2] [Product 3] →

Specifications:
├── Height: 240-280px (for cards)
├── Scroll direction: Horizontal left
├── Momentum scrolling: Enabled
├── Snap to item: Recommended
├── Show 1.5-2 items visible
├── Padding: 16px sides
└── Gap between items: 8px
```

### Infinite Scroll / Pagination
```
On reaching 80% of list:
├── AutoLoad next page
├── Show loading spinner
├── Append new items
└── Keep scroll position

Alternatively:
├── Show "Load More" button
├── Tap to load next batch
└── Visible loading state
```

### Search Auto-Complete
```
User types:
├── Show recent searches
├── Show popular searches
├── Show matching suggestions (real-time)
├── Tap suggestion → Navigate to results
└── Max 5-8 suggestions visible
```

---

## 7. Responsive Design Specifications

### Screen Size Breakpoints
```
Mobile Phones:
├── Small (320px):      Old devices (minimal support)
├── Normal (375px):     iPhone/Android phones
├── Large (414px):      Plus/XL models
└── XL (480px):         Landscape mode

Tablet:
├── Medium (600px):     Basic tablets
└── Large (900px):      Large tablets (iPad)
```

### Responsive Adjustments
```
Small phones (320-375px):
├── Grid: 1 column for some lists
├── Font: Reduce by 1-2px if needed
├── Padding: Reduce to 12px internal
└── Button height: 40px (still min 44dp touch)

Normal phones (375-414px):
├── Grid: 2 columns (standard)
├── Font: As designed
├── Padding: 16px
└── Button height: 44px

Large phones (480px+):
├── Grid: 2-3 columns
├── Padding: 20px
└── Button height: 48px

Landscape:
├── Reduce vertical space
├── Use side-by-side layouts more
├── Sticky header (reduced height)
└── Collapsed bottom nav (icons only)
```

---

## 8. Animation & Interaction

### Micro-interactions
```
Button Tap:
├── Visual feedback (0.1s color change)
├── Haptic feedback (light tap)
└── Action completes (0.3-0.5s)

Loading State:
├── Spinner animation (rotating)
├── Duration: Indeterminate until loaded
└── Show after 200ms (prevent flash)

Form Validation:
├── Real-time as user types
├── Error icon appears (0.2s)
├── Error message fades in
└── Success check icon (0.3s)

Toast Notification:
├── Slide up from bottom (0.3s)
├── Display (3-5s)
├── Slide out/fade (0.2s)
└── Total lifetime: 3.5-5.2s
```

### Gesture Support
```
Swipe Left/Right:
├── Navigate between tabs
├── Swipe left: Next tab
├── Swipe right: Previous tab
└── 60px threshold

Swipe Up/Down:
├── Dismiss bottom sheet
├── Swipe down: Close
├── 30% of height threshold

Pinch:
├── Product image zoom
├── Min scale: 1x
├── Max scale: 4x

Long Press:
├── Image save/share options
├── Duration: 500ms
└── Haptic feedback (heavy)

Pull Refresh:
├── Pull down to refresh
├── Show progress indicator
├── Refresh data on release
└── Snap back (auto-animate)
```

### Page Transitions
```
Push (Navigate Forward):
├── Slide left/up (0.3s)
├── Subtle fade
├── Easing: Ease-out

Pop (Navigate Back):
├── Slide right/down (0.25s)
├── Slight fade
├── Easing: Ease-out

Modal/Dialog Appear:
├── Fade in + scale (0.25s)
├── Start scale: 0.95
├── Easing: Ease-out

Disappear:
├── Reverse animation
├── Duration: 0.2s
└── Easing: Ease-in
```

---

## 9. Accessibility (A11y) Specifications

### Color Contrast
```
Text on Background:
├── Large Text (18px+): Min 3:1 ratio
├── Normal Text: Min 4.5:1 ratio
├── UI Components: Min 3:1 ratio

Examples:
├── #1F2937 (text) on #FFFFFF (bg): 12.63:1 ✓
├── #FF6B35 (primary) on #FFFFFF: 4.72:1 ✓
├── #6B7280 (gray) on #FFFFFF: 4.54:1 ✓
└── Avoid hard-to-read combinations
```

### Touch Target Size
```
Minimum Touch Target: 44x44 dp (density pixels)
├── Standard: 44x44 dp
├── Compact elements: Min 40x40 dp
├── Spacing between targets: Min 8dp
└── Example: Button height 44px, width 100%+
```

### Text Accessibility
```
Font Size:
├── Body text: Min 14px (Normal vision)
├── Small text: Min 12px (acceptable)
├── Link text: Same as body
└── Labels: 12-14px

Line Height:
├── Body: 1.5 (21px for 14px font)
├── Headings: 1.2-1.3
└── Improves readability

Letter Spacing:
├── Normal: -0.2px (default)
├── Maintain readability
└── Avoid excessive spacing
```

### Screen Reader Support
```
Labels:
├── All form inputs have labels
├── Labels associated (for attribute)
├── Aria-label for icon buttons
└── Aria-labelledby for sections

Status Messages:
├── Use aria-live="polite"
├── For toast notifications
├── For form errors
└── Announce dynamically loaded content

List Markup:
├── Use semantic HTML lists
├── <ul>, <ol>, <li> tags
├── Proper nesting
└── Screen reader announces count

Buttons vs Links:
├── Buttons: <button> for actions
├── Links: <a> for navigation
└── Never use divs as buttons
```

### Focus Management
```
Focus Indicators:
├── Visible focus ring (outline)
├── Min 2px width
├── High contrast color
├── No blur effects

Focus Order:
├── Natural reading order (top-left to bottom-right)
├── Tab order matches visual order
├── No focus traps
└── Easy navigation with Tab key

Focus on Modals:
├── Focus moves to modal on open
├── Focus trapped within modal
├── Focus returns on close
└── Escape key closes (optional)
```

---

## 10. Dark Mode Support (Optional Future)

### Dark Color Palette
```
Dark Background:     #111827
Dark Surface:        #1F2937
Dark Border:         #374151
Dark Text:           #F3F4F6
Dark Secondary:      #D1D5DB

Brand Colors:        Keep same (Orange, Teal)
Status Colors:       Keep same (Green, Red, etc)
```

### Implementation
- System preference detection
- Manual toggle in settings
- Consistent across all screens
- Proper contrast ratios maintained

---

**UI/UX Design Version**: 2.0  
**Last Updated**: March 2026  
**Design System**: Mobile-First
