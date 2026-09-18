-- Representative portfolio hardening for Supabase/PostgreSQL.
-- The production repository remains private.

CREATE OR REPLACE FUNCTION public.current_profile_role()
RETURNS TEXT
LANGUAGE SQL
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM public.profiles WHERE id = auth.uid();
$$;

REVOKE ALL ON FUNCTION public.current_profile_role() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.current_profile_role() TO authenticated;

-- Users may update their own display name, but cannot self-assign roles.
REVOKE INSERT, UPDATE, DELETE ON public.profiles FROM authenticated;
GRANT SELECT ON public.profiles TO authenticated;
GRANT UPDATE(full_name) ON public.profiles TO authenticated;

DROP POLICY IF EXISTS "profiles_select" ON profiles;
DROP POLICY IF EXISTS "profiles_update" ON profiles;
DROP POLICY IF EXISTS "profiles_insert" ON profiles;

CREATE POLICY "profiles_select" ON profiles
FOR SELECT TO authenticated
USING (id = auth.uid() OR public.current_profile_role() = 'admin');

CREATE POLICY "profiles_update_own_name" ON profiles
FOR UPDATE TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Kitchen users can read the operational state, while sales/admin own mutations.
DROP POLICY IF EXISTS "customers_all" ON customers;
CREATE POLICY "customers_read" ON customers
FOR SELECT TO authenticated USING (true);

CREATE POLICY "customers_write" ON customers
FOR ALL TO authenticated
USING (public.current_profile_role() IN ('admin', 'ventas'))
WITH CHECK (public.current_profile_role() IN ('admin', 'ventas'));

DROP POLICY IF EXISTS "products_select" ON products;
DROP POLICY IF EXISTS "products_insert" ON products;
DROP POLICY IF EXISTS "products_update" ON products;
DROP POLICY IF EXISTS "products_delete" ON products;

CREATE POLICY "products_read" ON products
FOR SELECT TO authenticated USING (true);

CREATE POLICY "products_write" ON products
FOR ALL TO authenticated
USING (public.current_profile_role() IN ('admin', 'ventas'))
WITH CHECK (public.current_profile_role() IN ('admin', 'ventas'));

DROP POLICY IF EXISTS "orders_all" ON orders;

CREATE POLICY "orders_read" ON orders
FOR SELECT TO authenticated USING (true);

CREATE POLICY "orders_write" ON orders
FOR ALL TO authenticated
USING (public.current_profile_role() IN ('admin', 'ventas'))
WITH CHECK (public.current_profile_role() IN ('admin', 'ventas'));

DROP POLICY IF EXISTS "order_items_all" ON order_items;

CREATE POLICY "order_items_read" ON order_items
FOR SELECT TO authenticated USING (true);

CREATE POLICY "order_items_write" ON order_items
FOR ALL TO authenticated
USING (public.current_profile_role() IN ('admin', 'ventas'))
WITH CHECK (public.current_profile_role() IN ('admin', 'ventas'));

-- New signups always receive a safe default role.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name, role)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email, 'Usuario'),
    'ventas'
  );
  RETURN NEW;
END;
$$;
