import { useState, type FormEvent } from "react";
import { useServerFn } from "@tanstack/react-start";
import * as DialogPrimitive from "@radix-ui/react-dialog";
import { CheckCircle2, MessageSquareText, Send, X } from "lucide-react";
import { toast } from "sonner";
import { sendComment } from "@/lib/menu.functions";
import { commentSchema } from "@/lib/menu-schema";

const field = "w-full rounded-2xl bg-input px-4 py-3 text-base outline-none placeholder:text-muted-foreground focus:ring-1 focus:ring-ring";

// Guests write to the café privately: comments are never shown on the menu.
export function CommentBox() {
  const send = useServerFn(sendComment);
  const [open, setOpen] = useState(false);
  const [sent, setSent] = useState(false);
  const [busy, setBusy] = useState(false);

  async function submit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const values = new FormData(e.currentTarget);
    const parsed = commentSchema.safeParse({ author_name: values.get("author_name") ?? "", message: values.get("message") ?? "" });
    if (!parsed.success) { toast.error(parsed.error.issues[0]?.message ?? "Lütfen yorumunuzu yazın."); return; }
    setBusy(true);
    try { await send({ data: parsed.data }); setSent(true); }
    catch { toast.error("Yorum gönderilemedi, lütfen tekrar deneyin."); }
    finally { setBusy(false); }
  }

  return <>
    <section className="mt-10 rounded-3xl bg-card p-5 text-center">
      <MessageSquareText className="mx-auto size-7 text-primary" strokeWidth={1.5} />
      <h2 className="mt-2 font-semibold">Görüşünüz bizim için değerli</h2>
      <p className="mt-1 text-sm text-muted-foreground">Öneri, teşekkür ya da şikâyet… Yorumunuz yalnızca işletmeye iletilir.</p>
      <button type="button" onClick={() => { setSent(false); setOpen(true); }} className="mt-4 inline-flex items-center gap-2 rounded-full bg-primary px-5 py-2.5 text-sm font-medium text-primary-foreground">
        <MessageSquareText className="size-4" />Yorum yaz
      </button>
    </section>

    <DialogPrimitive.Root open={open} onOpenChange={(o) => { if (!busy) setOpen(o); }}>
      <DialogPrimitive.Portal>
        <DialogPrimitive.Overlay className="fixed inset-0 z-50 bg-overlay backdrop-blur-sm data-[state=open]:animate-in data-[state=open]:fade-in-0" />
        <DialogPrimitive.Content aria-describedby={undefined} className="fixed left-1/2 top-1/2 z-50 w-[calc(100%-2.5rem)] max-w-sm -translate-x-1/2 -translate-y-1/2 rounded-3xl bg-card p-5 shadow-2xl outline-none data-[state=open]:animate-in data-[state=open]:fade-in-0 data-[state=open]:zoom-in-95">
          <DialogPrimitive.Close aria-label="Kapat" className="absolute right-3 top-3 flex size-9 items-center justify-center rounded-full bg-secondary text-foreground"><X className="size-4" /></DialogPrimitive.Close>
          {sent ? <div className="py-6 text-center">
            <CheckCircle2 className="mx-auto size-12 text-success" strokeWidth={1.5} />
            <DialogPrimitive.Title className="mt-3 text-lg font-semibold">Teşekkürler!</DialogPrimitive.Title>
            <p className="mt-1 text-sm text-muted-foreground">Yorumunuz işletmeye iletildi.</p>
            <DialogPrimitive.Close className="mt-5 rounded-full bg-secondary px-5 py-2 text-sm font-medium">Kapat</DialogPrimitive.Close>
          </div> : <form onSubmit={submit} className="space-y-3">
            <DialogPrimitive.Title className="pr-10 text-lg font-semibold">Yorum yaz</DialogPrimitive.Title>
            <p className="-mt-1 text-xs text-muted-foreground">Yorumunuzu yalnızca işletme görür.</p>
            <input name="author_name" maxLength={60} placeholder="Adınız (isteğe bağlı)" className={field} />
            <textarea name="message" required maxLength={1000} rows={5} placeholder="Yorumunuzu yazın..." className={`${field} resize-none`} />
            <button type="submit" disabled={busy} className="flex w-full items-center justify-center gap-2 rounded-full bg-primary py-3 text-sm font-medium text-primary-foreground disabled:opacity-60">
              <Send className="size-4" />{busy ? "Gönderiliyor..." : "Gönder"}
            </button>
          </form>}
        </DialogPrimitive.Content>
      </DialogPrimitive.Portal>
    </DialogPrimitive.Root>
  </>;
}
