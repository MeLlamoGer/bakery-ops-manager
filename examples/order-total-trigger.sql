-- Representative database logic from the anonymized client project.
--
-- The database owns the persisted total so multiple UI screens cannot drift
-- apart. Final total:
--   MAX(0, SUM(items) - bundle_discount - order_discount) + shipping_cost

CREATE OR REPLACE FUNCTION recalculate_order_total()
RETURNS TRIGGER AS $$
DECLARE
  target_order_id UUID;
BEGIN
  target_order_id := COALESCE(NEW.order_id, OLD.order_id);

  UPDATE orders
  SET total = GREATEST(
    COALESCE(
      (SELECT SUM(subtotal) FROM order_items WHERE order_id = target_order_id),
      0
    )
    - COALESCE(bundle_discount_amount, 0)
    - COALESCE(discount_amount, 0),
    0
  ) + COALESCE(shipping_cost, 0)
  WHERE id = target_order_id;

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION recalculate_order_total_on_order_change()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.bundle_discount_amount IS DISTINCT FROM OLD.bundle_discount_amount
     OR NEW.discount_amount IS DISTINCT FROM OLD.discount_amount
     OR NEW.shipping_cost IS DISTINCT FROM OLD.shipping_cost THEN
    NEW.total := GREATEST(
      COALESCE(
        (SELECT SUM(subtotal) FROM order_items WHERE order_id = NEW.id),
        0
      )
      - COALESCE(NEW.bundle_discount_amount, 0)
      - COALESCE(NEW.discount_amount, 0),
      0
    ) + COALESCE(NEW.shipping_cost, 0);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
