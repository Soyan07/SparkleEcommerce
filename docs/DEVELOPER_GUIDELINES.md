====================================================
SPARKLE ECOMMERCE SYSTEM – DEVELOPER GUIDELINE
====================================================

Purpose:
This document defines the strict development rules, flow, and UI/UX behavior
for the Sparkle Ecommerce System to ensure stability, consistency, and
error-free operation.

----------------------------------------------------
1. GENERAL DEVELOPMENT RULES
----------------------------------------------------
- Do NOT change existing UI/UX without approval
- No breaking changes in logic or database structure
- All features must be backward compatible
- Follow clean architecture (Controller → Service → Repository)
- Proper validation is mandatory at every layer
- All actions must return clear success or error messages

----------------------------------------------------
2. USER ROLES
----------------------------------------------------
1. Admin
   - Manage users, sellers, products, orders, reports
   - Full system access

2. Seller
   - Add and manage products
   - View and process orders
   - Manage inventory and delivery status

3. Customer
   - Browse products
   - Place orders
   - Track delivery
   - Make payments

----------------------------------------------------
3. TRENDING PRODUCT CARD (MANDATORY)
----------------------------------------------------
Each product card must display:
- Product Image
- Product Name
- Price (Discounted price if available)
- Rating (Stars + count)
- Trending / Hot badge (if applicable)
- Stock status (In Stock / Out of Stock)
- Add to Cart button
- Wishlist icon

Rules:
- Card must be responsive
- Lazy-load images
- Show skeleton loader while loading

----------------------------------------------------
4. ORDER FLOW (0 TO DELIVERY)
----------------------------------------------------
Step 1: Product Browsing
- Load products with pagination
- Show loaders during fetch

Step 2: Add to Cart
- Validate stock before adding
- Show success message on add
- Show error if stock unavailable

Step 3: Checkout
- Validate address
- Validate payment method
- Re-check stock before order confirmation

Step 4: Payment
- Wallet / Online / COD
- Handle payment failure gracefully

Step 5: Order Confirmation
- Generate Order ID
- Reduce product stock
- Notify seller and customer

Step 6: Delivery Process
- Order Status Flow:
  Pending → Confirmed → Packed → Shipped → Delivered
- Allow tracking at every step

----------------------------------------------------
5. ERROR HANDLING RULES
----------------------------------------------------
- Never show raw system errors
- Use user-friendly messages only
- Log technical errors internally

Common Error Messages:
- "Something went wrong. Please try again."
- "Invalid input provided."
- "Payment failed. Please retry."
- "Product is out of stock."

----------------------------------------------------
6. SUCCESS MESSAGE RULES
----------------------------------------------------
Success messages must be:
- Short
- Clear
- Positive

Examples:
- "Product added to cart successfully."
- "Order placed successfully."
- "Payment completed successfully."
- "Profile updated successfully."

----------------------------------------------------
7. UI/UX STRICT RULES
----------------------------------------------------
- Use consistent colors and fonts
- No sudden layout shifts
- All buttons must show loading state
- Disable buttons during API calls
- Toast/Snackbar for feedback messages

----------------------------------------------------
8. PERFORMANCE RULES
----------------------------------------------------
- API response time < 500ms
- Use caching where applicable
- Avoid unnecessary API calls
- Optimize database queries

----------------------------------------------------
9. SECURITY RULES
----------------------------------------------------
- Validate all inputs (server-side mandatory)
- Protect APIs with authentication & authorization
- Never expose sensitive data
- Use HTTPS only

----------------------------------------------------
10. FINAL NOTE
----------------------------------------------------
Any violation of this guideline may cause:
- System instability
- UI inconsistency
- User dissatisfaction

Follow this document strictly for a smooth, scalable,
and production-ready ecommerce system.

====================================================
END OF DOCUMENT
====================================================
