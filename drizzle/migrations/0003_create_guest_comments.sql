CREATE TABLE public.guest_comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  author_name text NOT NULL DEFAULT '',
  message text NOT NULL,
  is_read boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

GRANT SELECT, INSERT, UPDATE, DELETE ON public.guest_comments TO anon, authenticated;
GRANT ALL ON public.guest_comments TO service_role;

ALTER TABLE public.guest_comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Guests send comments as unread" ON public.guest_comments FOR INSERT TO anon, authenticated WITH CHECK (is_read = false);
CREATE POLICY "Passwordless panel reads comments" ON public.guest_comments FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Passwordless panel marks comments" ON public.guest_comments FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Passwordless panel deletes comments" ON public.guest_comments FOR DELETE TO anon, authenticated USING (true);

COMMENT ON TABLE public.menu_reviews IS 'DEPRECATED: replaced by guest_comments (comments go only to the management panel)';