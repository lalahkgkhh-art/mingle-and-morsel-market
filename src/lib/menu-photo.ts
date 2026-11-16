export const MENU_PHOTO_BUCKET = "menu-photos";
export const MENU_PHOTO_MAX_BYTES = 15 * 1024 * 1024;
const NAME = /^[0-9a-f-]{36}\.jpg$/;

export function isMenuPhotoName(name: string): boolean {
  return NAME.test(name);
}

export function menuPhotoUrl(name: string): string {
  return `/api/public/menu-photo/${name}`;
}

/** Shrinks a photo in the browser so the menu stays fast on phones. */
export async function compressMenuPhoto(file: File, maxSide = 1600, quality = 0.85): Promise<Blob> {
  const bitmap = await createImageBitmap(file);
  const scale = Math.min(1, maxSide / Math.max(bitmap.width, bitmap.height));
  const canvas = document.createElement("canvas");
  canvas.width = Math.round(bitmap.width * scale);
  canvas.height = Math.round(bitmap.height * scale);
  const ctx = canvas.getContext("2d");
  if (!ctx) throw new Error("Fotoğraf işlenemedi.");
  ctx.drawImage(bitmap, 0, 0, canvas.width, canvas.height);
  bitmap.close();
  return new Promise((resolve, reject) =>
    canvas.toBlob((blob) => (blob ? resolve(blob) : reject(new Error("Fotoğraf işlenemedi."))), "image/jpeg", quality),
  );
}
