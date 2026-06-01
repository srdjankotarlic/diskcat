# DiskCat Cloud Setup

DiskCat works offline by default. Optional cloud sync is self-owned: DiskCat does not host your cloud data, and the public app does not include the maintainer's database, account, or private keys.

Each team that wants sync creates its own Supabase project. That team owns the data, users, limits, backups, and billing settings for that project.

## What Cloud Mode Adds

- Same archive on multiple computers.
- Owner/editor/viewer roles.
- Public read-only link without an account.
- Editor/viewer invite links for people who should sign in.
- Project/root folder filters stay synced, so teams can see every drive and shoot related to the same job folder.
- Optional folder inventory records stay synced too. DiskCat stores searchable names, paths, file types, and attached drive/project metadata, not the actual media files.
- Local export/import still works as a backup.

Cloud mode is designed for small production teams. It syncs the whole archive after edits, so the newest save wins if two editors change the same archive at the same time.

## Free Setup

Supabase has a Free plan suitable for small DiskCat archives. Check the current limits before using it for serious work: https://supabase.com/pricing

1. Create a Supabase account and project.
2. Open **SQL Editor** in that project.
3. Paste and run the whole file: `supabase/diskcat-self-owned-cloud.sql`.
4. Open **Project Settings -> API**.
5. Copy the project URL.
6. Copy the **anon / publishable** key.
7. Never paste any private admin key into DiskCat.
8. Open DiskCat, click **Cloud sync**, paste the URL and public key, then click **Save connection**.
9. Click **Test connection**. If it fails, check the URL, public key, and whether the SQL ran successfully.
10. Create an account or sign in.
11. Click **Create cloud archive**.
12. Click **Sync local to cloud** if you already have local data.

The in-app Cloud sync panel also includes **Copy SQL**, **Setup docs**, the active archive ID, and **Last synced** so users can see whether the archive is connected.

## Sharing

Owner:

- **Public read-only link**: anyone with the link can view without an account. They cannot edit.
- **Viewer invite**: invited user signs in and can view the live archive.
- **Editor invite**: invited user signs in and can add or edit drives and footage.

Viewer:

- Can search, open drives, export, and view.
- Cannot add, edit, import, clear, or delete.

Editor:

- Can add/edit/delete drives, footage, and folder inventory.
- Cannot create invite links unless made owner in the database.

## Install On Mac

1. Open DiskCat in Chrome.
2. Click the install icon in the address bar, or open Chrome menu and choose the install app option.
3. Confirm install.
4. DiskCat opens like a normal Mac app and can also work offline.

Chrome's official web app instructions are here: https://support.google.com/chrome/answer/9658361

## Security Notes

- Browser apps must use only the public URL and anon/publishable key.
- Row Level Security is enabled by `supabase/diskcat-self-owned-cloud.sql`.
- Anonymous users cannot directly read the tables.
- Public no-account viewing goes through `diskcat_public_read_archive(token)`.
- If you no longer want a public link to work, disable `public_read_enabled` or clear `public_read_token` in your Supabase `archives` table.

## Who Is Responsible For Data?

The person or company that creates the Supabase project is responsible for that project's data. DiskCat does not host your cloud data. The maintainer of the public GitHub version is not storing other people's archives.
