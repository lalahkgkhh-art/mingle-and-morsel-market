CREATE TABLE public.wheel_settings (
  id integer PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  title text NOT NULL DEFAULT '🎡 Lucky Wheel',
  subtitle text NOT NULL DEFAULT 'Spin the wheel and win a surprise prize!',
  max_spins integer NOT NULL DEFAULT 2 CHECK (max_spins >= 0),
  prizes jsonb NOT NULL DEFAULT '[]'::jsonb,
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, UPDATE ON public.wheel_settings TO anon, authenticated;
GRANT ALL ON public.wheel_settings TO service_role;
ALTER TABLE public.wheel_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read wheel settings" ON public.wheel_settings FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Passwordless panel edits wheel settings" ON public.wheel_settings FOR UPDATE TO anon, authenticated USING (true) WITH CHECK (true);

INSERT INTO public.wheel_settings (id, prizes) VALUES (1, '[
 {"t":"Free Coffee","e":"☕","c":"#8d5524","limit":1},
 {"t":"10 Birr Off","e":"💸","c":"#2f9e44","limit":null},
 {"t":"Free Juice","e":"🍹","c":"#f08c00","limit":1},
 {"t":"50 Birr Off","e":"💰","c":"#1c7ed6","limit":3},
 {"t":"Free Dessert","e":"🍰","c":"#d6336c","limit":1},
 {"t":"100 Birr Off","e":"🎁","c":"#7048e8","limit":1},
 {"t":"Free Tea","e":"🫖","c":"#0b7285","limit":2},
 {"t":"20 Birr Off","e":"💵","c":"#e8590c","limit":null},
 {"t":"Maybe Next Time","e":"😊","c":"#868e96","limit":null,"x":true}
]'::jsonb);

CREATE TABLE public.wheel_wins (
  day date NOT NULL,
  prize text NOT NULL,
  count integer NOT NULL DEFAULT 0,
  PRIMARY KEY (day, prize)
);
GRANT SELECT, DELETE ON public.wheel_wins TO anon, authenticated;
GRANT ALL ON public.wheel_wins TO service_role;
ALTER TABLE public.wheel_wins ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read wheel wins" ON public.wheel_wins FOR SELECT TO anon, authenticated USING (true);
CREATE POLICY "Passwordless panel resets wheel wins" ON public.wheel_wins FOR DELETE TO anon, authenticated USING (true);

-- Picks a prize that still has stock today and records the win in one step,
-- so daily limits hold across every guest's phone.
CREATE OR REPLACE FUNCTION public.spin_wheel()
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_prizes jsonb;
  v_today date := (now() AT TIME ZONE 'Europe/Istanbul')::date;
  v_ok integer[] := '{}';
  v_idx integer;
  v_prize jsonb;
  v_limit integer;
  v_won integer;
  i integer;
BEGIN
  PERFORM pg_advisory_xact_lock(hashtext('spin_wheel'));
  SELECT prizes INTO v_prizes FROM public.wheel_settings WHERE id = 1;
  IF v_prizes IS NULL OR jsonb_array_length(v_prizes) = 0 THEN
    RETURN NULL;
  END IF;
  FOR i IN 0 .. jsonb_array_length(v_prizes) - 1 LOOP
    v_prize := v_prizes -> i;
    IF v_prize ->> 'limit' IS NULL THEN
      v_ok := v_ok || i;
    ELSE
      v_limit := (v_prize ->> 'limit')::integer;
      SELECT count INTO v_won FROM public.wheel_wins WHERE day = v_today AND prize = v_prize ->> 't';
      IF v_limit - COALESCE(v_won, 0) > 0 THEN
        v_ok := v_ok || i;
      END IF;
    END IF;
  END LOOP;
  IF array_length(v_ok, 1) IS NULL THEN
    FOR i IN 0 .. jsonb_array_length(v_prizes) - 1 LOOP
      IF COALESCE((v_prizes -> i ->> 'x')::boolean, false) THEN v_ok := ARRAY[i]; END IF;
    END LOOP;
    IF array_length(v_ok, 1) IS NULL THEN v_ok := ARRAY[0]; END IF;
  END IF;
  v_idx := v_ok[1 + floor(random() * array_length(v_ok, 1))::integer];
  INSERT INTO public.wheel_wins (day, prize, count) VALUES (v_today, v_prizes -> v_idx ->> 't', 1)
    ON CONFLICT (day, prize) DO UPDATE SET count = public.wheel_wins.count + 1;
  RETURN v_idx;
END;
$$;
REVOKE ALL ON FUNCTION public.spin_wheel() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.spin_wheel() TO anon, authenticated, service_role;