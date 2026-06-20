# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A static portfolio website for Wai Phyo (Senior Web Engineer) with a Supabase-backed admin dashboard. No build step, no package manager, no framework — pure HTML/CSS/JS served by XAMPP locally and deployed to Vercel.

## Development

Open files directly in a browser via XAMPP (`http://localhost/waiphyo/`) or use a Live Server extension. There are no build, lint, or test commands.

To set up the database, paste `setup.sql` into the Supabase SQL Editor and run it. This creates all tables, enables RLS, and seeds the default profile row.

## Architecture

### File responsibilities

| File | Role |
|---|---|
| `index.html` | Public portfolio — **hardcoded** static content (skills, projects, experience) |
| `admin.html` | Admin dashboard — single-page app with sidebar navigation and Supabase CRUD |
| `login.html` | Auth page — sign in + register tabs using Supabase Auth |
| `styles.css` | Shared styles for `index.html` and `script.js` only; `admin.html` has its own inline `<style>` |
| `script.js` | Client-side behavior for `index.html` (navbar, animations, particles) |
| `supabase-config.js` | Exports `SUPABASE_URL` and `SUPABASE_ANON_KEY` as plain globals; loaded by `admin.html` and `login.html` |
| `setup.sql` | Full DB schema + RLS policies; run once in Supabase SQL Editor |
| `waiphyo_req.html` | Old Bootstrap-based draft — not linked or used in production |

### Content architecture: two separate worlds

**`index.html` content is hardcoded HTML.** Skills, projects, and experience entries in the portfolio are static — they do not fetch from Supabase. The admin panel manages content in the database, but changes only appear on the portfolio if you manually update `index.html` as well (or wire up dynamic loading).

**`admin.html` is fully dynamic.** It reads from and writes to four Supabase tables: `profile`, `projects`, `skills`, `experience`, and `admin_users`.

### Supabase setup

- **Auth**: Supabase Auth handles login/registration. The anon key is used client-side.
- **RLS**: Public can `SELECT` all tables (portfolio is public). Only `authenticated` users can write. `admin_users` additionally allows anon `INSERT` so registration works before email confirmation.
- **Admin user tracking**: The `admin_users` table (id UUID, email, created_at) mirrors Supabase Auth users. Populated client-side on registration in `login.html`. Deleting a row from this table removes them from the dashboard list but does not delete the Supabase Auth account — that requires the Supabase dashboard.

### Admin panel navigation pattern

`admin.html` uses a `goTo(name)` function that shows/hides `<section id="sec-{name}">` elements and calls the matching `load*()` function. To add a new section: add a `.sb-link[data-sec]` in the sidebar, a `<section class="section" id="sec-{name}">` in `.content`, an entry in `SEC_TITLES`, a branch in `goTo()`, and the corresponding `load*()` function.

### Deployment

Vercel (`vercel.json`): `cleanUrls: true`, `trailingSlash: false`. Push to the connected Git repo to deploy.
