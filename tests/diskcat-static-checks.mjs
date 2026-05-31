import { existsSync, readFileSync } from 'node:fs';
import assert from 'node:assert/strict';

const html = readFileSync(new URL('../index.html', import.meta.url), 'utf8');
const readOptional = (path) => {
  const url = new URL(path, import.meta.url);
  return existsSync(url) ? readFileSync(url, 'utf8') : '';
};
const sql = readOptional('../supabase/diskcat-self-owned-cloud.sql');
const readme = readOptional('../README.md');
const cloudSetup = readOptional('../docs/CLOUD_SETUP.md');

assert.match(html, /function saveEvent\(\)[\s\S]*Add a drive first/, 'saveEvent must block footage saves without a selected drive');
assert.match(html, /data-action="edit-event"[\s\S]*aria-label="Edit footage"/, 'event edit icon must have an accessible label');
assert.match(html, /data-action="del-event"[\s\S]*aria-label="Delete footage"/, 'event delete icon must have an accessible label');
assert.match(html, /@media \(hover:none\),\(pointer:coarse\)[\s\S]*\.row-actions/, 'row actions must be visible on touch devices');
assert.doesNotMatch(html, /https:\/\/[a-z0-9-]+\.supabase\.co/, 'index.html must not ship with a default Supabase project URL');
assert.doesNotMatch(html, /service[_-]?role/i, 'index.html must never mention or embed a Supabase service-role key');
assert.match(html, /Cloud sync/, 'index.html must expose cloud sync UI');
assert.match(html, /Start local/, 'empty onboarding must offer a local-first start');
assert.match(html, /Setup steps/, 'cloud UI must include a guided setup wizard');
assert.match(html, /Copy SQL/, 'cloud UI must let users copy the Supabase SQL setup');
assert.match(html, /Test connection/, 'cloud UI must include a connection test action');
assert.match(html, /Last synced/, 'cloud UI must show sync freshness');
assert.match(html, /target\.closest\('#empty-demo'\)/, 'sample data card must respond when child text is clicked');
assert.match(sql, /alter table public\.archives enable row level security/i, 'cloud SQL must enable RLS on archives');
assert.match(sql, /alter table public\.drives enable row level security/i, 'cloud SQL must enable RLS on drives');
assert.match(sql, /alter table public\.events enable row level security/i, 'cloud SQL must enable RLS on events');
assert.match(sql, /diskcat_public_read_archive/i, 'cloud SQL must include token-gated public read RPC');
assert.match(sql, /revoke all on public\.archives from anon/i, 'cloud SQL must revoke anonymous direct archive access');
assert.match(readme + cloudSetup, /does not host your cloud data/i, 'docs must explain that DiskCat does not host user cloud data');
assert.match(readme, /Why DiskCat instead of a spreadsheet/i, 'README must explain why DiskCat is more useful than a spreadsheet');
assert.match(readme, /Where your data lives/i, 'README must clearly explain data ownership modes');
assert.match(readme, /maintainer does not host your cloud data/i, 'README must clearly state maintainer is not hosting user cloud data');

console.log('diskcat-static-checks: ok');
