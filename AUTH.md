# Sparkle Ecommerce - Authentication Guide

## Login URLs

| Role | URL | Notes |
|------|-----|-------|
| **User/Customer** | `/auth/login` | loginType=user (default) |
| **Seller** | `/auth/login` | loginType=seller |
| **Admin** | `/auth/admin-login` or `/admin/login` | Admin-only page |
| **Register User** | `/auth/register` | New customer signup |
| **Register Seller** | `/auth/register-seller` | New seller application |

---

## Admin Login

| Field | Value |
|-------|-------|
| Email | `admin@sparkle.local` |
| Password | `Admin@123` |
| Role | Admin |
| Redirect | `/Admin/Dashboard` |

---

## Customer/User Login

| Field | Value |
|-------|-------|
| Email | `user@sparkle.local` |
| Password | `User@123` |
| Role | User |
| Redirect | `/` (Homepage) |

---

## Seller Logins (25 sellers seeded)

All sellers use password: `Vendor@123`

| # | Email | Shop Name | City | Rating |
|---|-------|-----------|------|--------|
| 1 | dailyessentials@sparkle.local | Daily Essentials BD | Dhaka | 4.8 |
| 2 | dailymart@sparkle.local | DailyMart BD | Chittagong | 4.7 |
| 3 | homeneeds@sparkle.local | HomeNeeds BD | Dhaka | 4.6 |
| 4 | mobilebazar@sparkle.local | Mobile Bazar Bangladesh | Sylhet | 4.8 |
| 5 | freshmart@sparkle.local | Fresh Mart BD | Dhaka | 4.4 |
| 6 | beautyzone@sparkle.local | Beauty Zone Cosmetics | Dhaka | 4.9 |
| 7 | sportsworld@sparkle.local | Sports World BD | Khulna | 4.3 |
| 8 | computerplus@sparkle.local | Computer Plus Solutions | Dhaka | 4.7 |
| 9 | bookshop@sparkle.local | Book Lovers Paradise | Rajshahi | 4.6 |
| 10 | babyshop@sparkle.local | Baby Care Heaven | Dhaka | 4.8 |
| 11 | jewelrypalace@sparkle.local | Jewelry Palace BD | Dhaka | 4.9 |
| 12 | pharmaeasy@sparkle.local | PharmaEasy Bangladesh | Dhaka | 4.8 |
| 13 | petworld@sparkle.local | Pet World Bangladesh | Dhaka | 4.5 |
| 14 | camerahub@sparkle.local | Camera Hub BD | Dhaka | 4.7 |
| 15 | autoparts@sparkle.local | Auto Parts Bangladesh | Chittagong | 4.4 |
| 16 | musicstore@sparkle.local | Music Store Bangladesh | Dhaka | 4.6 |
| 17 | gardenstore@sparkle.local | Garden Store BD | Dhaka | 4.5 |
| 18 | travelgear@sparkle.local | Travel Gear Bangladesh | Sylhet | 4.7 |
| 19 | artcraft@sparkle.local | Art & Craft Corner | Dhaka | 4.6 |
| 20 | fitnessgear@sparkle.local | Fitness Gear Pro | Dhaka | 4.8 |
| 21 | toysrus@sparkle.local | Toys R Us Bangladesh | Chittagong | 4.7 |
| 22 | electroniccity@sparkle.local | Electronic City BD | Dhaka | 4.6 |
| 23 | medicalequip@sparkle.local | Medical Equipment BD | Dhaka | 4.8 |
| 24 | officemaster@sparkle.local | Office Master BD | Dhaka | 4.5 |
| 25 | kidszone@sparkle.local | Kids Zone Fashion | Dhaka | 4.7 |

Seller login redirect: `/Seller/Dashboard`

---

## Google OAuth

- Not configured by default
- Set `Google:ClientId` and `Google:ClientSecret` in appsettings to enable
- Only works for User/Customer login (not Seller or Admin)

---

## JWT API Auth

| Setting | Value |
|---------|-------|
| Issuer | `Sparkle` |
| Audience | `SparkleClient` |
| Token Lifetime | 60 minutes |
| Refresh Token | 7 days |

---

## Role Separation Rules

- Admin **cannot** login via `/auth/login` (redirected to admin-login)
- Seller **cannot** login via user panel (shown error to use Seller login)
- User **cannot** login via Seller panel (shown error to use User login)
- New sellers are `Pending` status until admin approves
- Rejected sellers cannot login (shown reset message)
