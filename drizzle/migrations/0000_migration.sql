CREATE TABLE public.menu_categories (
  id text PRIMARY KEY DEFAULT gen_random_uuid()::text,
  name text NOT NULL CHECK (length(trim(name)) > 0),
  position integer NOT NULL DEFAULT 0
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.menu_categories TO anon, authenticated;
GRANT ALL ON public.menu_categories TO service_role;
ALTER TABLE public.menu_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Passwordless menu category management" ON public.menu_categories FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
COMMENT ON POLICY "Passwordless menu category management" ON public.menu_categories IS 'Owner-requested public passwordless menu management; anyone can create, edit and delete categories.';

CREATE TABLE public.menu_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL CHECK (length(trim(name)) > 0),
  category_id text NOT NULL REFERENCES public.menu_categories(id) ON DELETE RESTRICT,
  description text NOT NULL DEFAULT '',
  price numeric NOT NULL CHECK (price >= 0),
  old_price numeric CHECK (old_price > price),
  image text NOT NULL DEFAULT 'espresso',
  available boolean NOT NULL DEFAULT true,
  position integer NOT NULL DEFAULT 0
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.menu_items TO anon, authenticated;
GRANT ALL ON public.menu_items TO service_role;
ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Passwordless menu item management" ON public.menu_items FOR ALL TO anon, authenticated USING (true) WITH CHECK (true);
COMMENT ON POLICY "Passwordless menu item management" ON public.menu_items IS 'Owner-requested public passwordless menu management; hidden items remain readable by the management panel.';

INSERT INTO public.menu_categories (id, name, position) VALUES
  ('sicak','Sıcak Kahve',1),('soguk','Soğuk Kahve',2),('frappe','Frappuccino',3),('mocha','Mocha',4);
INSERT INTO public.menu_items (name, category_id, price, old_price, image, description, position) VALUES
  ('Espresso','sicak',65,80,'espresso','Yoğun ve aromatik',1),
  ('Flat White','sicak',140,170,'flatwhite','İpeksi süt köpüğü',2),
  ('Cappuccino','sicak',120,NULL,'flatwhite','Klasik İtalyan',3),
  ('Americano','sicak',90,NULL,'espresso','Sıcak su ve espresso',4),
  ('Iced Latte','soguk',150,NULL,'icedlatte','Buz, süt ve espresso',5),
  ('Cold Brew','soguk',160,NULL,'icedlatte','18 saat demlenmiş',6),
  ('Karamel Frappuccino','frappe',190,220,'frappe','Karamel soslu',7),
  ('Vanilya Frappuccino','frappe',180,NULL,'frappe','Kremalı vanilya',8),
  ('Mocha','mocha',160,NULL,'flatwhite','Çikolata ve espresso',9),
  ('Iced Mocha','mocha',170,NULL,'icedlatte','Buzlu çikolatalı',10);