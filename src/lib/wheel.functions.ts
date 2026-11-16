import { createServerFn } from "@tanstack/react-start";
import { createMenuClient } from "./menu.functions";
import { wheelSchema, wheelDay, type Prize } from "./wheel-schema";

const menuClient = () => createMenuClient(process.env["SUPABASE_URL"], process.env["SUPABASE_PUBLISHABLE_KEY"]);

// Like the rest of the panel, wheel management is passwordless at the owner's request.
export const getWheelAdmin = createServerFn({ method: "GET" }).handler(async () => {
  const client = menuClient();
  const [settings, wins] = await Promise.all([
    client.from("wheel_settings").select("*").eq("id", 1).single(),
    client.from("wheel_wins").select("prize, count").eq("day", wheelDay()),
  ]);
  if (settings.error || wins.error) throw new Error("Çark ayarları yüklenemedi.");
  const s = settings.data;
  return {
    title: s.title, subtitle: s.subtitle, max_spins: s.max_spins,
    prizes: (s.prizes ?? []) as unknown as Prize[],
    wins: Object.fromEntries((wins.data ?? []).map((w) => [w.prize, w.count])) as Record<string, number>,
  };
});

export const saveWheel = createServerFn({ method: "POST" }).inputValidator((input) => wheelSchema.parse(input)).handler(async ({ data }) => {
  const result = await menuClient().from("wheel_settings")
    .update({ ...data, prizes: data.prizes, updated_at: new Date().toISOString() }).eq("id", 1).select("id").single();
  if (result.error) throw new Error("Çark ayarları kaydedilemedi.");
  return { ok: true };
});

export const resetWheelToday = createServerFn({ method: "POST" }).handler(async () => {
  const result = await menuClient().from("wheel_wins").delete().eq("day", wheelDay());
  if (result.error) throw new Error("Bugünkü sayılar sıfırlanamadı.");
  return { ok: true };
});
