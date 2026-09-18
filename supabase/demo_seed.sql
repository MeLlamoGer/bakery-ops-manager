-- Synthetic demo data only.
-- No production customer information or client pricing is included in this repository.

INSERT INTO customers (name, phone, address, neighborhood, notes) VALUES
  ('Cliente Demo Uno', '099000001', 'Calle Demo 101', 'Centro', 'Datos sintéticos'),
  ('Cliente Demo Dos', '099000002', NULL, 'Pocitos', 'Datos sintéticos'),
  ('Empresa Demo SAS', '099000003', NULL, NULL, 'Cuenta corporativa ficticia');

INSERT INTO products (name, category, price, unit, active) VALUES
  ('Croissant clásico', 'Panadería', 100.00, 'unidad', true),
  ('Caja surtida', 'Boxes', 1200.00, 'caja', true),
  ('Torta personalizada', 'Tortas', 2500.00, 'unidad', true),
  ('Pan artesanal', 'Panadería', 180.00, 'unidad', true);
