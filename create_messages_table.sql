-- إنشاء جدول الرسائل مع كل الميزات الجديدة
CREATE TABLE IF NOT EXISTS public.messages (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  sender_id uuid REFERENCES public.profiles(id) NOT NULL,
  receiver_id uuid REFERENCES public.profiles(id) NOT NULL,
  content text NOT NULL,
  type text DEFAULT 'text' CHECK (type IN ('text', 'nudge', 'flash')),
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  
  -- ميزات الأمان
  expires_at timestamp with time zone,
  delete_after_read boolean DEFAULT FALSE,
  view_once boolean DEFAULT FALSE,
  is_encrypted boolean DEFAULT FALSE,
  viewed_by text[] DEFAULT '{}',
  
  CONSTRAINT sender_not_receiver CHECK (sender_id != receiver_id)
);

-- تفعيل Row Level Security
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;

-- السماح للمستخدمين برؤية رسائلهم فقط
DROP POLICY IF EXISTS "Users can view their own messages" ON public.messages;
CREATE POLICY "Users can view their own messages"
ON public.messages FOR SELECT
USING (
  auth.uid() = sender_id OR auth.uid() = receiver_id
);

-- السماح للمستخدمين بإرسال رسائل
DROP POLICY IF EXISTS "Users can send messages" ON public.messages;
CREATE POLICY "Users can send messages"
ON public.messages FOR INSERT
WITH CHECK (
  auth.uid() = sender_id
);

-- إنشاء Indexes لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_messages_sender ON public.messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_receiver ON public.messages(receiver_id);
CREATE INDEX IF NOT EXISTS idx_messages_created ON public.messages(created_at);
CREATE INDEX IF NOT EXISTS idx_messages_expires_at ON public.messages(expires_at) WHERE expires_at IS NOT NULL;
