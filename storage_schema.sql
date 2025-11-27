-- 1. STORAGE BUCKET
-- Create a new storage bucket for media
insert into storage.buckets (id, name, public)
values ('nixen_media', 'nixen_media', true);

-- Policy: Allow authenticated users to upload media
create policy "Authenticated users can upload media"
on storage.objects for insert
with check (
  bucket_id = 'nixen_media' 
  and auth.role() = 'authenticated'
);

-- Policy: Allow public access to view media
create policy "Public access to view media"
on storage.objects for select
using ( bucket_id = 'nixen_media' );

-- 2. STORIES TABLE
create table public.stories (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) not null,
  media_url text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  expires_at timestamp with time zone default timezone('utc'::text, now() + interval '24 hours') not null
);

alter table public.stories enable row level security;

create policy "Everyone can view active stories"
on public.stories for select
using ( expires_at > now() );

create policy "Users can upload stories"
on public.stories for insert
with check ( auth.uid() = user_id );
