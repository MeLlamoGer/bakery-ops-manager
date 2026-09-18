-- Simplified, privacy-safe example of the payment-history design.
--
-- Individual payments are stored as ledger entries while aggregate
-- payment_amount/payment_status values on orders are maintained by triggers.

CREATE TABLE order_payments (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
  notes TEXT,
  paid_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_order_payments_order ON order_payments(order_id);
CREATE INDEX idx_order_payments_paid_at ON order_payments(paid_at DESC);

CREATE OR REPLACE FUNCTION recalc_order_payment_amount()
RETURNS TRIGGER AS $$
DECLARE
  target_order_id UUID;
BEGIN
  target_order_id := COALESCE(NEW.order_id, OLD.order_id);

  UPDATE orders
  SET payment_amount = COALESCE(
    (SELECT SUM(amount) FROM order_payments WHERE order_id = target_order_id),
    0
  )
  WHERE id = target_order_id;

  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION recalc_order_payment_status()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.payment_amount IS DISTINCT FROM OLD.payment_amount
     OR NEW.total IS DISTINCT FROM OLD.total THEN
    NEW.payment_status := CASE
      WHEN COALESCE(NEW.payment_amount, 0) <= 0 THEN 'pendiente'
      WHEN COALESCE(NEW.payment_amount, 0) >= COALESCE(NEW.total, 0)
           AND COALESCE(NEW.total, 0) > 0 THEN 'completo'
      ELSE 'parcial'
    END;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- The portfolio version intentionally omits the historical broad RLS policy.
-- See examples/rls-hardening.sql for the role-based access model.
