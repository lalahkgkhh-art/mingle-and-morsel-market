import { createFileRoute } from "@tanstack/react-router";
import { createMenuClient } from "@/lib/menu.functions";
import { isMenuPhotoName, MENU_PHOTO_BUCKET } from "@/lib/menu-photo";

// Public on purpose: guests scanning the QR code must see product photos.
// Only files from the menu photo bucket with generated names are served.
export const Route = createFileRoute("/api/public/menu-photo/$name")({
  server: {
    handlers: {
      GET: async ({ params }) => {
        if (!isMenuPhotoName(params.name)) return new Response("Not found", { status: 404 });
        const client = createMenuClient(process.env["SUPABASE_URL"], process.env["SUPABASE_PUBLISHABLE_KEY"]);
        const { data, error } = await client.storage.from(MENU_PHOTO_BUCKET).download(params.name);
        if (error || !data) return new Response("Not found", { status: 404 });
        return new Response(data, {
          headers: {
            "content-type": data.type || "image/jpeg",
            "cache-control": "public, max-age=31536000, immutable",
          },
        });
      },
    },
  },
});
