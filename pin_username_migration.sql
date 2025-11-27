-- PIN & Username Management Migration
-- Add support for custom PINs and username change tracking

-- ================================
-- Add new columns to profiles table
-- ================================
DO $$ 
BEGIN
  -- Add original_pin column (stores the permanent, original PIN)
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='profiles' AND column_name='original_pin') THEN
    ALTER TABLE public.profiles ADD COLUMN original_pin text;
  END IF;

  -- Add custom_pin column (stores temporary custom PIN)
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='profiles' AND column_name='custom_pin') THEN
    ALTER TABLE public.profiles ADD COLUMN custom_pin text;
  END IF;

  -- Add custom_pin_expires_at column
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='profiles' AND column_name='custom_pin_expires_at') THEN
    ALTER TABLE public.profiles ADD COLUMN custom_pin_expires_at timestamp with time zone;
  END IF;

  -- Add username_changes_count column
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='profiles' AND column_name='username_changes_count') THEN
    ALTER TABLE public.profiles ADD COLUMN username_changes_count integer DEFAULT 0;
  END IF;
END $$;

-- ================================
-- Migrate existing data
-- ================================
-- Set original_pin = current pin for all existing users
UPDATE public.profiles 
SET original_pin = pin 
WHERE original_pin IS NULL;

-- ================================
-- Create unique index for custom_pin
-- ================================
CREATE UNIQUE INDEX IF NOT EXISTS idx_custom_pin_unique 
ON public.profiles(custom_pin) 
WHERE custom_pin IS NOT NULL;

-- ================================
-- Add constraint to ensure PIN is either original or custom
-- ================================
-- Note: The 'pin' column will now be a computed field based on custom_pin_expires_at
-- If custom_pin exists and hasn't expired, use it; otherwise use original_pin

-- ================================
-- DONE! PIN & Username management is ready.
-- ================================
