# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

- **Primary Consumers**: Modern, fashion and lifestyle shoppers browsing and purchasing apparel and accessories on mobile (Android and iOS). They seek a fluid, distraction-free discovery experience with effortless filtering, quick visual previews, transparent pricing, and instant multi-step checkout.
- **Store Administrators**: E-commerce catalog managers and store operators using the web admin dashboard to monitor sales metrics, manage product listings and variants, update promotional banners, and oversee orders.

## Product Purpose

NextLook is a modern cross-platform e-commerce platform that connects retail fashion shoppers with curated clothing, footwear, and lifestyle accessories. Success means providing an intuitive, polished shopping journey—from discovery and category exploration through personalized wishlist management to rapid address selection, secure payment processing, and real-time order tracking.

## Positioning

A sleek, mobile-first shopping experience built with Flutter that delivers native smoothness, curated visual discovery (real portrait and product category avatars, interactive flash sale timers, and synchronized section browsing), paired with a dedicated web operational dashboard for real-time inventory and promotional management.

## Operating Context

- **Consumer Experience**: Smartphone touchscreens (Android & iOS) in varying lighting conditions and network environments. Users navigate via persistent bottom navigation (Home, Categories, Wishlist, Cart, Profile), scroll through multi-tier product feeds, search with debounced keyword queries, and review orders via milestone timelines.
- **Administrative Experience**: Desktop web browser dashboard accessed by administrators managing inventory, banners, and categories.
- **Backend Architecture**: REST API powered by Node.js/TypeScript and Prisma ORM on PostgreSQL, hosted on Render with Cloudinary asset storage.

## Capabilities and Constraints

- **Mobile Client (Flutter)**:
  - Riverpod 2.x reactive state management.
  - GoRouter declarative routing with sub-routes for products, categories, search, checkout, orders, and addresses.
  - Multi-step checkout flow (Address Selection -> Delivery Method -> Payment Options -> Order Review & Success).
  - Currency conversion and multi-currency pricing display.
  - Google Sign-In and JWT-based authentication with guest browsing support.
  - Offline-resilient image caching via `cached_network_image`.
- **Web Admin (React + Vite)**:
  - React 19 + TypeScript + Tailwind CSS with Lucide icons and Recharts data visualization.
  - Real-time product variant, inventory, banner, and category management.
- **Constraints**:
  - Code changes must maintain docstrings and comments.
  - Strict adherence to the 5 core categories: Men, Women, Kids, Shoes, Accessories.

## Brand Commitments

- **Name**: NextLook
- **Color Palette**: Primary Purple (`#6C63FF`), Deep Navy (`#1E1E2D`), Soft Light Grey / Background (`#F8F9FC`), Surface White (`#FFFFFF`), Border Subtle (`#E5E7EB`).
- **Typography**: Poppins font family across all mobile headings, body, and button elements.
- **Visual Identity**: Established in `The_App_UI.png` reference spec—rounded card containers (16px radius), subtle drop-shadows, circular category avatars with real person headshots (Men, Women, Kids) and crisp product shots (Shoes, Accessories).

## Evidence on Hand

- Reference UI design sheet: [`nextlook/assets/images/The_App_UI.png`](file:///home/abpro/Documents/AndroidStudioProjects/NextLook-App/nextlook/assets/images/The_App_UI.png).
- Category avatar assets: [`nextlook/assets/images/categories/`](file:///home/abpro/Documents/AndroidStudioProjects/NextLook-App/nextlook/assets/images/categories/).
- App launcher icon and splash assets: [`nextlook/assets/images/APP_Icon.jpg`](file:///home/abpro/Documents/AndroidStudioProjects/NextLook-App/nextlook/assets/images/APP_Icon.jpg).
- Backend Prisma schema: [`backend/prisma/schema.prisma`](file:///home/abpro/Documents/AndroidStudioProjects/NextLook-App/backend/prisma/schema.prisma).
- 98 automated widget and unit tests ensuring UI component and flow integrity.

## Product Principles

1. **Frictionless Discovery**: Keep products front and center with minimal chrome, responsive debounce search, intuitive section headers, and instant visual category navigation.
2. **Speed & Reliability**: Optimize list rendering, image caching, and skeleton loaders so browsing feels instant even on mobile network connections.
3. **Clarity Over Clutter**: Preserve clean visual hierarchy with consistent cards, clear price formatting, and unambiguous status indicators.
4. **Seamless Multi-Step Checkout**: Ensure addressing, delivery, and payment selections are transparent, error-resistant, and verifiable before final order submission.

## Accessibility & Inclusion

- High-contrast text labels against light backgrounds meeting WCAG AA standards.
- Minimum 48x48dp interactive touch targets across navigation bars, buttons, and category chips.
- Clear error states, fallback icons for network image loading failures, and informative empty state screens across all feature views.
