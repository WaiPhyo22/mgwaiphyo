-- ============================================================
-- Portfolio Admin Dashboard – Supabase Database Setup
--
-- Steps:
--   1. Go to https://supabase.com and open your project
--   2. Navigate to SQL Editor (left sidebar)
--   3. Paste this entire file and click Run
-- ============================================================

-- ── Tables ──────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS profile (
  id BIGINT PRIMARY KEY DEFAULT 1,
  full_name TEXT DEFAULT 'Wai Phyo',
  tagline TEXT DEFAULT 'Senior Web Engineer · Laravel & Full-Stack Developer',
  location TEXT DEFAULT 'Yangon, Myanmar',
  bio1 TEXT DEFAULT '',
  bio2 TEXT DEFAULT '',
  bio3 TEXT DEFAULT '',
  email TEXT DEFAULT 'waiphyo055192@gmail.com',
  github_url TEXT DEFAULT 'https://github.com/WaiPhyo22',
  linkedin_url TEXT DEFAULT 'https://www.linkedin.com/in/wai-phyo-10512b280/',
  youtube_url TEXT DEFAULT 'https://www.youtube.com/@waiphyoyaw',
  facebook_url TEXT DEFAULT 'https://www.facebook.com/way.phyo.353/',
  hero_image_url TEXT DEFAULT '',
  about_image_url TEXT DEFAULT ''
);

CREATE TABLE IF NOT EXISTS projects (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  subtitle TEXT DEFAULT '',
  description_items JSONB DEFAULT '[]'::jsonb,
  tech_tags JSONB DEFAULT '[]'::jsonb,
  icon TEXT DEFAULT 'fa-code',
  icon_color TEXT DEFAULT 'icon-blue',
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS skills (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  icon_class TEXT DEFAULT 'fas fa-code',
  sort_order INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS experience (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  company TEXT DEFAULT '',
  period TEXT DEFAULT '',
  description_items JSONB DEFAULT '[]'::jsonb,
  project_tags JSONB DEFAULT '[]'::jsonb,
  sort_order INT DEFAULT 0
);

-- ── Row Level Security ───────────────────────────────────────

ALTER TABLE profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE experience ENABLE ROW LEVEL SECURITY;

-- Public can read everything (portfolio is public)
DROP POLICY IF EXISTS "Public read profile"     ON profile;
DROP POLICY IF EXISTS "Public read projects"    ON projects;
DROP POLICY IF EXISTS "Public read skills"      ON skills;
DROP POLICY IF EXISTS "Public read experience"  ON experience;
CREATE POLICY "Public read profile"     ON profile     FOR SELECT USING (true);
CREATE POLICY "Public read projects"    ON projects    FOR SELECT USING (true);
CREATE POLICY "Public read skills"      ON skills      FOR SELECT USING (true);
CREATE POLICY "Public read experience"  ON experience  FOR SELECT USING (true);

-- Only authenticated users (admin) can write
DROP POLICY IF EXISTS "Auth write profile"     ON profile;
DROP POLICY IF EXISTS "Auth write projects"    ON projects;
DROP POLICY IF EXISTS "Auth write skills"      ON skills;
DROP POLICY IF EXISTS "Auth write experience"  ON experience;
CREATE POLICY "Auth write profile"     ON profile     FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Auth write projects"    ON projects    FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Auth write skills"      ON skills      FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Auth write experience"  ON experience  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ── Seed default profile row ─────────────────────────────────

INSERT INTO profile (
  id, full_name, tagline, location, email,
  github_url, linkedin_url, youtube_url, facebook_url
) VALUES (
  1,
  'Wai Phyo',
  'Senior Web Engineer · Laravel & Full-Stack Developer',
  'Yangon, Myanmar',
  'waiphyo055192@gmail.com',
  'https://github.com/WaiPhyo22',
  'https://www.linkedin.com/in/wai-phyo-10512b280/',
  'https://www.youtube.com/@waiphyoyaw',
  'https://www.facebook.com/way.phyo.353/'
) ON CONFLICT (id) DO NOTHING;

-- ── Contact Messages ────────────────────────────────────────

CREATE TABLE IF NOT EXISTS contact_messages (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE contact_messages ENABLE ROW LEVEL SECURITY;

-- Anyone can submit a message (public portfolio contact form)
DROP POLICY IF EXISTS "Public insert messages" ON contact_messages;
CREATE POLICY "Public insert messages" ON contact_messages FOR INSERT WITH CHECK (true);

-- Only authenticated admins can read, update (mark read), or delete messages
DROP POLICY IF EXISTS "Auth read messages"   ON contact_messages;
DROP POLICY IF EXISTS "Auth update messages" ON contact_messages;
DROP POLICY IF EXISTS "Auth delete messages" ON contact_messages;
CREATE POLICY "Auth read messages"   ON contact_messages FOR SELECT TO authenticated USING (true);
CREATE POLICY "Auth update messages" ON contact_messages FOR UPDATE TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Auth delete messages" ON contact_messages FOR DELETE TO authenticated USING (true);

-- ── Admin Users (for user list in dashboard) ────────────────

CREATE TABLE IF NOT EXISTS admin_users (
  id UUID PRIMARY KEY,
  email TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Authenticated admins can view and delete the user list
DROP POLICY IF EXISTS "Auth read admin_users"    ON admin_users;
DROP POLICY IF EXISTS "Auth delete admin_users"  ON admin_users;
DROP POLICY IF EXISTS "Allow insert admin_users" ON admin_users;
CREATE POLICY "Auth read admin_users"    ON admin_users FOR SELECT TO authenticated USING (true);
CREATE POLICY "Auth delete admin_users"  ON admin_users FOR DELETE TO authenticated USING (true);

-- Anyone can insert (registration happens before email confirmation)
CREATE POLICY "Allow insert admin_users" ON admin_users FOR INSERT WITH CHECK (true);

-- ── Hero slideshow extra columns (safe to run on existing DB) ───────────────
ALTER TABLE profile ADD COLUMN IF NOT EXISTS hero_image_url_2 TEXT DEFAULT '';
ALTER TABLE profile ADD COLUMN IF NOT EXISTS hero_image_url_3 TEXT DEFAULT '';

-- ── About slideshow extra columns ────────────────────────────────────────────
ALTER TABLE profile ADD COLUMN IF NOT EXISTS about_image_url_2 TEXT DEFAULT '';
ALTER TABLE profile ADD COLUMN IF NOT EXISTS about_image_url_3 TEXT DEFAULT '';

-- ── Storage Bucket for Profile Images ───────────────────────
-- Creates a public bucket so uploaded photos can be served
-- without authentication. Run once in the SQL Editor.

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'profile-images',
  'profile-images',
  true,
  5242880,                      -- 5 MB max per file
  ARRAY['image/jpeg','image/png','image/webp','image/gif']
)
ON CONFLICT (id) DO NOTHING;

-- Anyone can read images (public portfolio)
DROP POLICY IF EXISTS "Public read profile images" ON storage.objects;
CREATE POLICY "Public read profile images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'profile-images');

-- Only logged-in admins can upload / replace / delete
DROP POLICY IF EXISTS "Auth upload profile images" ON storage.objects;
CREATE POLICY "Auth upload profile images"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'profile-images');

DROP POLICY IF EXISTS "Auth update profile images" ON storage.objects;
CREATE POLICY "Auth update profile images"
  ON storage.objects FOR UPDATE TO authenticated
  USING (bucket_id = 'profile-images');

DROP POLICY IF EXISTS "Auth delete profile images" ON storage.objects;
CREATE POLICY "Auth delete profile images"
  ON storage.objects FOR DELETE TO authenticated
  USING (bucket_id = 'profile-images');

-- ── Done ─────────────────────────────────────────────────────
-- After running this, go to Authentication → Users in your
-- Supabase dashboard and create your admin user account.
-- Re-run the admin_users block above if you already ran setup.sql before.
