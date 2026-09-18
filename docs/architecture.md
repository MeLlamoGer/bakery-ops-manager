# Architecture

## Problem

The client was coordinating bakery orders through manual workflows. The application centralizes the lifecycle from customer/order capture to production and payment tracking.

## Main boundaries

### Web application
The Next.js application exposes role-aware operational screens for sales and kitchen workflows.

### Authentication
Supabase Auth identifies users. A public `profiles` table maps users to the application roles:
- `admin`
- `ventas`
- `cocina`

### Relational data model
PostgreSQL stores customers, products, orders, order items, payments, reservations, expenses and bundle/discount rules.

### Realtime
Operational screens subscribe to changes so the kitchen and sales views can reflect updates without manual refreshes.

## Order totals

The database, not only the UI, owns the final order total. Triggers recompute totals after item changes and when shipping/discount inputs change.

Keeping calculation rules close to the data reduces drift between multiple screens and makes persisted totals consistent.

## Historical price snapshots

Each order item stores the product name and price used when the order was created. Catalog updates therefore do not rewrite historical orders.

## Production planning

Active order items are aggregated by delivery date and product to produce daily/weekly production views. This converts sales data into an actionable kitchen workload.

## Portfolio scope

The public repository intentionally documents architecture and representative database/security work instead of mirroring the private client repository.
