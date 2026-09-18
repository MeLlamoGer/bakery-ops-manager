# Case study

## Context

The client is a small artisan-bakery operation. Order information had to move between sales and kitchen work, while payments, delivery dates, product quantities and customer details all needed to stay consistent.

The engineering challenge was less about algorithmic complexity and more about **turning a real, evolving workflow into reliable software**.

## What the system needed to coordinate

A single order touches several concerns:

1. customer/contact information;
2. products and quantities;
3. delivery/pickup date;
4. production workload;
5. discounts and shipping;
6. one or more payment events;
7. order state;
8. printable/operational views for different users.

Treating those as disconnected screens would create duplicated business logic. The project therefore moved important invariants into the data layer where practical.

## Examples of engineering decisions

### Historical pricing

Catalog prices are mutable; order history is not.

Order items therefore keep price/name snapshots rather than deriving an old sale from the product's current catalog row.

### Order totals

Totals are consumed in several places. PostgreSQL triggers own the persisted formula so the sales UI, payment status and reporting views share the same value.

A maintenance bug later exposed exactly why this mattered: shipping cost had been introduced in the UI but was missing from the persisted calculation. The fix required updating the database formula and reconciling historical totals rather than patching only one screen.

### Active-order visibility

Completed/cancelled orders eventually leave the day-to-day operational list. Unfinished orders must remain visible even if their scheduled date has passed.

That rule is applied in the database query before `ORDER BY/LIMIT`, not only in memory after fetching rows. Otherwise archived records can consume the query limit and hide active work.

### Payment history

A scalar `payment_amount` is convenient for dashboards but cannot explain installments. The later design adds a payment ledger and derives the aggregate.

## Collaboration

This was a collaborative project built through a small software studio, not a solo portfolio exercise.

My contribution included client discovery/requirements translation, implementation and maintenance work, operational data modeling, and iterating on the delivered system with the team and client.

The public repository deliberately avoids attributing every line of the private production code to one person.

## Why this repository is a case study

Publishing the original production repository would expose information that does not belong in a portfolio and could blur client/team ownership.

Instead, this repository demonstrates the architecture and representative technical decisions with synthetic examples while keeping the production source private.
