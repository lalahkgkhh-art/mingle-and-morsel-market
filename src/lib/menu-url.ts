export const publishedMenuUrl = "https://mingle-at-the-table.lovable.app/";

export function guestMenuUrl(origin: string): string | null {
  try {
    const url = new URL(origin);
    const host = url.hostname;
    if (url.protocol !== "https:" || host === "localhost" || host === "127.0.0.1" || host.startsWith("id-preview--") || host.startsWith("preview--") || host.endsWith(".lovableproject.com")) return null;
    return `${url.origin}/`;
  } catch {
    return null;
  }
}

export function resolvedGuestMenuUrl(origin: string): string {
  return guestMenuUrl(origin) ?? publishedMenuUrl;
}