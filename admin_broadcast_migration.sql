-- Admin Dashboard & Broadcast System Migration
-- Add support for app-wide notifications and admin analytics

-- ================================
-- STEP 1: Create app_notifications table
-- ================================
CREATE TABLE IF NOT EXISTS public.app_notifications (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  title text NOT NULL,
  content text NOT NULL,
  image_url text,
  action_url text,
  created_by uuid REFERENCES public.profiles(id) NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ================================
-- STEP 2: Create user_notification_reads table
-- ================================
CREATE TABLE IF NOT EXISTS public.user_notification_reads (
  user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  notification_id uuid REFERENCES public.app_notifications(id) ON DELETE CASCADE NOT NULL,
  read_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  PRIMARY KEY (user_id, notification_id)
);

-- ================================
-- STEP 3: Enable RLS and create policies
-- ================================
ALTER TABLE public.app_notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Everyone can view app notifications" ON public.app_notifications;
CREATE POLICY "Everyone can view app notifications"
ON public.app_notifications FOR SELECT
USING (true);

DROP POLICY IF EXISTS "Admins can create notifications" ON public.app_notifications;
CREATE POLICY "Admins can create notifications"
ON public.app_notifications FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role = 'admin'
  )
);

DROP POLICY IF EXISTS "Admins can delete notifications" ON public.app_notifications;
CREATE POLICY "Admins can delete notifications"
ON public.app_notifications FOR DELETE
USING (
  EXISTS (
    SELECT 1 FROM public.profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role = 'admin'
  )
);

-- User notification reads policies
ALTER TABLE public.user_notification_reads ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their own read status" ON public.user_notification_reads;
CREATE POLICY "Users can view their own read status"
ON public.user_notification_reads FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can mark notifications as read" ON public.user_notification_reads;
CREATE POLICY "Users can mark notifications as read"
ON public.user_notification_reads FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- ================================
-- STEP 4: Create indexes
-- ================================
CREATE INDEX IF NOT EXISTS idx_app_notifications_created_at 
ON public.app_notifications(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_user_notification_reads_user 
ON public.user_notification_reads(user_id);

-- ================================
-- DONE! Admin Dashboard & Broadcast System ready.
-- ================================
