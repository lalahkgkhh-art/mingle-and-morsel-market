import { createFileRoute } from "@tanstack/react-router";
import { createMenuClient } from "@/lib/menu.functions";

// Public on purpose: any guest may spin. The database function picks a prize that
// still has stock today and records it, so guests cannot choose their own prize.
export const Route = createFileRoute("/api/public/wheel-spin")({
  server: {
    handlers: {
      POST: async () => {
        const client = createMenuClient(process.env["SUPABASE_URL"], process.env["SUPABASE_PUBLISHABLE_KEY"]);
        const { data, error } = await client.rpc("spin_wheel");
        if (error || typeof data !== "number") return Response.json({ error: "unavailable" }, { status: 503 });
        return Response.json({ index: data }, { headers: { "cache-control": "no-store" } });
      },
    },
  },
});
