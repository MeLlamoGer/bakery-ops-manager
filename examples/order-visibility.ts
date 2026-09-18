export type OrderStatus =
  | 'pendiente'
  | 'confirmado'
  | 'en_produccion'
  | 'entregado'
  | 'cancelado';

export const ACTIVE_ORDER_STATUSES = new Set<OrderStatus>([
  'pendiente',
  'confirmado',
  'en_produccion',
]);

export const ORDERS_QUERY_LIMIT = 500;

export function archiveCutoffDate(): string {
  const date = new Date();
  date.setDate(date.getDate() - 7);
  return date.toISOString().slice(0, 10);
}

/**
 * Delivered/cancelled orders move out of the operational list one week after
 * their delivery date. Active orders remain visible even when their delivery
 * date is old so they cannot disappear from the kitchen/sales workflow.
 */
export function filterVisibleOrders<T extends { delivery_date: string; status: OrderStatus }>(
  orders: T[],
  cutoff: string = archiveCutoffDate(),
): T[] {
  return orders.filter(
    (order) => order.delivery_date >= cutoff || ACTIVE_ORDER_STATUSES.has(order.status),
  );
}

/**
 * Equivalent PostgREST filter. Applying the archive rule in the database is
 * important because the query is ordered + limited; filtering only in memory
 * could spend the limit on old delivered orders and hide future active work.
 */
export function visibleOrdersOrFilter(cutoff: string = archiveCutoffDate()): string {
  const statuses = [...ACTIVE_ORDER_STATUSES].join(',');
  return `delivery_date.gte.${cutoff},status.in.(${statuses})`;
}
