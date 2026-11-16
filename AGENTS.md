<!-- LOVABLE:BEGIN -->
> [!IMPORTANT]
> This project is connected to [Lovable](https://lovable.dev). Avoid rewriting
> published git history — force pushing, or rebasing/amending/squashing commits
> that are already pushed — as it rewrites history on Lovable's side and the
> user will likely lose their project history.
>
> Commits you push to the connected branch sync back to Lovable and show up in
> the editor, so keep the branch in a working state.

## What Lovable manages

Rules outside this block are the project's own. Change the pieces below in
Lovable, not by hand. With the [Lovable MCP](https://mcp.lovable.dev)
connected, `send_message` asks Lovable to do it; otherwise ask the user to
use the editor.

- **Database.** Do not add or edit `supabase/migrations/` or `drizzle/`.
  Ask Lovable to change the schema.
- **Generated files.** Do not edit a file whose header says it is automatically
  generated.
- **AI gateway.** Keep model calls on Lovable's gateway, and keep
  `LOVABLE_API_KEY` out of browser code.
- **Connectors.** Lovable provides native connectors. `list_connectors` shows
  which are enabled; `add_connector` only returns the dashboard link. When a
  connector is enabled, calls go through the connector gateway and need
  `LOVABLE_API_KEY`. When Lovable does not provide one, users can bring their
  own key and store it in Secrets.
- **Secrets.** Lovable manages them. Do not put secret values in the repo.
<!-- LOVABLE:END -->
## Application architecture

- Keep menu management at the public `/dashboard` route and use publishable-key server functions with menu-table RLS; this supports credential-free management without exposing privileged account access.
- Keep the guest menu at `/` and filter out unavailable products in its server function; the QR code must target this public menu, never the management or sign-in page.
- Resolve QR destinations to the current public origin, with the verified deployment URL as the editor-preview fallback; this prevents printed codes from pointing to an editor sign-in wall.
- Project was imported from GitHub (mingle-at-the-table); the menu data lives in Lovable Cloud tables menu_categories and menu_items.
- Uploaded product photos go to the private menu-photos storage bucket and are served through /api/public/menu-photo/$name; the workspace blocks public buckets, and this keeps menu data small.
- Guest comments live in guest_comments and are listed only in the management panel; the guest menu server function never returns them (menu_reviews is deprecated).
