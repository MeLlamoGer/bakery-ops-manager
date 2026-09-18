# Data model

The production system used PostgreSQL through Supabase. This diagram is intentionally simplified and anonymized.

```mermaid
erDiagram
    PROFILES ||--o{ ORDERS : creates
    CUSTOMERS ||--o{ ORDERS : places
    ORDERS ||--|{ ORDER_ITEMS : contains
    PRODUCTS ||--o{ ORDER_ITEMS : referenced_by
    ORDERS ||--o{ ORDER_PAYMENTS : receives
    CUSTOMERS ||--o{ RESERVATIONS : makes
    RESERVATIONS ||--o| ORDERS : converted_to
    PROFILES ||--o{ EXPENSES : records

    PROFILES {
      uuid id PK
      text role
      text full_name
    }

    CUSTOMERS {
      uuid id PK
      text name
      text phone
    }

    PRODUCTS {
      uuid id PK
      text name
      decimal current_price
      boolean active
    }

    ORDERS {
      uuid id PK
      text order_number
      date delivery_date
      text status
      decimal total
      decimal payment_amount
      text payment_status
    }

    ORDER_ITEMS {
      uuid id PK
      uuid order_id FK
      uuid product_id FK
      text product_name_snapshot
      decimal unit_price_snapshot
      int quantity
      decimal subtotal
    }

    ORDER_PAYMENTS {
      uuid id PK
      uuid order_id FK
      decimal amount
      timestamptz paid_at
    }
```

## Price snapshots

`ORDER_ITEMS` stores the product name and unit price used at the moment of the sale.

That is intentional duplication. A bakery may change its current catalog price tomorrow, but that should not alter the financial history of an order already placed today.

## Aggregate + ledger pattern

Payments eventually evolved into two representations:

- `ORDER_PAYMENTS` preserves individual payment events;
- aggregate fields on `ORDERS` make operational dashboards cheap to query.

Database triggers keep those representations synchronized.

## Reservations

Reservations are modeled separately from confirmed orders because the business workflow treats them differently. A reservation can later be converted into an order without forcing incomplete reservations to satisfy every invariant of a confirmed order.

## Authorization boundary

Application roles live in `PROFILES`, linked to Supabase Auth users. Row Level Security uses those profiles to enforce read/write capabilities close to the database.
