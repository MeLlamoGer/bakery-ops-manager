# Engineering notes

A few implementation details are more representative of the project than screenshots alone.

## Operational visibility is a data-query problem

The order screen needs two apparently conflicting behaviors:

- old completed/cancelled orders should leave the daily operational list;
- an unfinished order must never disappear simply because its scheduled date is old.

The visibility rule is therefore encoded both as a small domain utility and as a PostgREST filter. Applying it only after fetching data would be incorrect once the query is sorted and limited: old rows could consume the limit before future active orders are fetched.

See [order-visibility.ts](../examples/order-visibility.ts).

## Persisted totals belong close to the data

Several screens consume the order total: sales, production, balances and payment state. Calculating totals independently in each client view caused a risk of inconsistent values.

The database trigger in [order-total-trigger.sql](../examples/order-total-trigger.sql) centralizes the persisted total and reacts both to item mutations and to changes in discounts/shipping.

One real maintenance bug found during development was that shipping cost had been added to the product UI but not to the persisted total trigger. Fixing that required:

1. aligning the formula with the UI;
2. recalculating existing orders that had item rows;
3. allowing the payment-status trigger to re-evaluate balances.

That kind of cross-layer debugging is one of the reasons this project is useful portfolio evidence.

## Payments are a ledger, not just a number

A single `payment_amount` field cannot explain whether a customer paid in one transfer or several installments.

The later design stores individual payment entries while maintaining aggregate fields on the order for fast dashboards and backwards compatibility. See [payment-ledger.sql](../examples/payment-ledger.sql).

## Security review

The portfolio review also exposed that the earliest RLS rules were too permissive for the kitchen role. The public hardening example documents the corrected role model instead of hiding the evolution of the project.
