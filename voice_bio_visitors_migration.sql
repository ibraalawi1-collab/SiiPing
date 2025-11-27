-- Voice Bio & Profile Visitors Migration
-- Add voice bio support and profile visitor tracking

-- ================================
-- STEP 1: Add columns to profiles table
-- ================================
DO $$ 
BEGIN
  -- Add voice_bio_url column
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='profiles' AND column_name='voice_bio_url') THEN
    ALTER TABLE public.profiles ADD COLUMN voice_bio_url text;
  END IF;

  -- Add track_visitors column
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                 WHERE table_name='profiles' AND column_name='track_visitors') THEN
    ALTER TABLE public.profiles ADD COLUMN track_visitors boolean DEFAULT true;
  END IF;
END $$;

-- ================================
-- STEP 2: Create profile_visits table
-- ================================
CREATE TABLE IF NOT EXISTS public.profile_visits (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  profile_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  visitor_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
  visited_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(profile_id, visitor_id, visited_at)
);

-- ================================
-- STEP 3: Create indexes
-- ================================
CREATE INDEX IF NOT EXISTS idx_profile_visits_profile 
ON public.profile_visits(profile_id, visited_at DESC);

CREATE INDEX IF NOT EXISTS idx_profile_visits_visitor 
ON public.profile_visits(visitor_id);

-- ================================
-- STEP 4: Enable RLS and create policies
-- ================================
ALTER TABLE public.profile_visits ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view their profile visitors" ON public.profile_visits;
CREATE POLICY "Users can view their profile visitors"
ON public.profile_visits FOR SELECT
USING (auth.uid() = profile_id);

DROP POLICY IF EXISTS "Authenticated users can log visits" ON public.profile_visits;
CREATE POLICY "Authenticated users can log visits"
ON public.profile_visits FOR INSERT
WITH CHECK (auth.uid() = visitor_id AND visitor_id != profile_id);

-- ================================
-- STEP 5: Create storage bucket for voice bios
-- ================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('voice_bios', 'voice_bios', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for voice_bios bucket
DO $$
BEGIN
  -- Allow authenticated users to upload their voice bio
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'objects' 
    AND policyname = 'Authenticated users can upload voice bio'
  ) THEN
    CREATE POLICY "Authenticated users can upload voice bio"
    ON storage.objects FOR INSERT
    WITH CHECK (
      bucket_id = 'voice_bios' 
      AND auth.role() = 'authenticated'
    );
  END IF;

  -- Allow public access to view voice bios
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE tablename = 'objects' 
    AND policyname = 'Public access to voice bios'
  ) THEN
    CREATE POLICY "Public access to voice bios"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'voice_bios');
  END IF;
END $$;

-- ================================
-- DONE! Voice Bio & Profile Visitors ready.
-- ================================
