# Sparkle Ecommerce - Detailed Project Structure

## 🏗️ Architectural Overview
Sparkle Ecommerce follows the **Clean Architecture** pattern, divided into three distinct layers. This structure ensures that the core business logic is independent of external frameworks, databases, or UI concerns.

### Dependency Flow
`Sparkle.Api` -> `Sparkle.Infrastructure` -> `Sparkle.Domain`

*   **Sparkle.Domain**: The center. Has NO dependencies.
*   **Sparkle.Infrastructure**: Depends on Domain.
*   **Sparkle.Api**: Depends on both.

---

## 🔷 1. Sparkle.Domain (The Core Layer)
**Path**: `Sparkle.Domain/`
**Role**: Defines the "What". It contains the heart of the business logic, entities, and rules.

### 📂 Key Components
*   **Entities (`/Entities`)**:
    *   **Catalog**:
        *   `Product.cs`: Core product definition (Title, Price, Stock).
        *   `Category.cs`: Hierarchical organization of products.
        *   `ProductVariant.cs`: Handles Size/Color variations (SKUs).
    *   **Orders**:
        *   `Order.cs`: The central transaction record. Links User, Seller, and OrderItems.
        *   `Cart.cs`: Transient state for user shopping sessions before checkout.
    *   **Users**:
        *   `User.cs`: Extends IdentityUser with application-specific profile data.
*   **Enums (`/Enums`)**:
    *   `OrderStatus`: Defines standard states (Pending -> Confirmed -> Shipped -> Delivered).
    *   `PaymentMethod`: Supported gateways (Bkash, COD, Card).

### ⚙️ How It Works
The Domain layer is purely C# classes (POCOs). It doesn't know about SQL or HTTP.
*   **Example**: When you ask "What is a Product?", `Sparkle.Domain` provides the answer: "A Product has a Title, Price, and related Variants."

---

## 🔶 2. Sparkle.Infrastructure (The Implementation Layer)
**Path**: `Sparkle.Infrastructure/`
**Role**: Defines the "How". It implements the interfaces defined in Domain and handles external plumbing (Database, APIs).

### 📂 Key Components
*   **Data Access (`/Data`)**:
    *   `ApplicationDbContext.cs`: The Entity Framework Core context. It maps Domain entities to SQL Server tables.
    *   `DbInitializer.cs`: logic to seed initial data (Admin user, default categories).
*   **Migrations (`/Migrations`)**:
    *   Auto-generated code that keeps the SQL schema in sync with Domain entities.
*   **Services (`/Services`)**:
    *   **EmailService**: Uses SMTP to send emails to users.
    *   **ImageService**: Handles file uploads to `wwwroot` or external storage.
    *   **Payment implementations**: Logic for processing payments.

### ⚙️ How It Works
*   **Database Translation**: When the App asks for "Order #123", `Infrastructure` translates that request into a SQL query: `SELECT * FROM Orders WHERE Id = 123`.
*   **Dependency Injection**: It registers itself with the API so the API can use these services without knowing the implementation details.

---

## 🚀 3. Sparkle.Api (The Presentation Layer)
**Path**: `Sparkle.Api/`
**Role**: The "Face". It handles user interaction, routing, and presenting data.

### 📂 Key Components
*   **Controllers (`/Controllers`)**:
    *   **HomeController**: Manages the storefront landing page.
    *   **CheckoutController**: Orchestrates the complex flow of validating a Cart, creating an Order, and processing Payment.
    *   **AuthController**: manages user session (Login/Register).
*   **Views (`/Views`)**:
    *   **Razor Pages (.cshtml)**: The HTML templates rendered to the browser.
    *   **Shared Components**: `_ProductCard.cshtml` used in listings.
*   **Areas (`/Areas`)**:
    *   **Admin Area**: A completely separate MVC structure inside `/Areas/Admin` for the Backoffice Dashboard.
*   **Hubs (`/Hubs`)**:
    *   **NotificationHub**: Enables real-time server-to-client push notifications (e.g., "New Order Received").
*   **Static Assets (`/wwwroot`)**:
    *   CSS, JavaScript, and Images that are served directly to the browser.

### ⚙️ How It Works
1.  **Incoming Request**: A user clicks "Checkout".
2.  **Routing**: The request hits `CheckoutController`.
3.  **Orchestration**:
    *   Controller asks **Domain** rules: "Is the Cart valid?"
    *   Controller asks **Infrastructure**: "Does the user have a saved address?"
4.  **Response**: Controller returns `Views/Checkout/Index.cshtml` populated with the data.

---

## 🔄 Interaction Example: Placing an Order

1.  **User Action**: User clicks "Place Order" on the frontend (**Api**).
2.  **Controller**: `CheckoutController` receives the POST request.
3.  **Validation**: It checks `Sparkle.Domain.Order` rules (e.g., "Must have items").
4.  **Persistence**: It calls `_context.Orders.Add(order)` (**Infrastructure**).
5.  **Commit**: `_context.SaveChanges()` translates this to an SQL INSERT.
6.  **Notification**: SignalR (**Api**) sends a "Ding!" to the Seller's Dashboard.
