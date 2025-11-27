-- Community Features Subscription Migration
-- Add voice room count tracking and channel subscription requirements

-- ================================
-- Add voice_room_count to profiles
-- ================================
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='profiles' AND column_name='voice_room_count') THEN
    ALTER TABLE public.profiles ADD COLUMN voice_room_count integer DEFAULT 0;
  END IF;
END $$;

-- ================================
-- Add channel_subscription_expires_at to profiles
-- ================================
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='profiles' AND column_name='channel_subscription_expires_at') THEN
    ALTER TABLE public.profiles ADD COLUMN channel_subscription_expires_at timestamp with time zone;
  END IF;
END $$;

-- ================================
-- DONE! Community subscription features ready.
-- ================================
-- Voice Rooms: 3 free uses, then payment required
-- Channels: Monthly subscription required
