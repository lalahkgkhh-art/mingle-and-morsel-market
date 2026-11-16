CREATE TABLE public.menu_reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id uuid NOT NULL REFERENCES public.menu_items(id) ON DELETE CASCADE,
  author_name text NOT NULL DEFAULT '',
  rating integer NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment text NOT NULL DEFAULT '',
  approved boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX menu_reviews_item_idx ON public.menu_reviews(item_id);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.menu_reviews TO anon, authenticated;
GRANT ALL ON public.menu_reviews TO service_role;

ALTER TABLE public.menu_reviews ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read reviews" ON public.menu_reviews FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Guests add reviews pending approval" ON public.menu_reviews FOR INSERT TO anon, authenticated WITH CHECK (approved = false);
CREATE POLICY "Passwordless review moderation" ON public.menu_reviews FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Passwordless review deletion" ON public.menu_reviews FOR DELETE TO anon, authenticated USING (true);