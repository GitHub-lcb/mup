-- Confirm the admin user email manually
UPDATE auth.users
SET email_confirmed_at = now()
WHERE email = 'lcb@admin.com';

-- Also confirm any other admin emails just in case
UPDATE auth.users
SET email_confirmed_at = now()
WHERE email LIKE '%@admin.com' AND email_confirmed_at IS NULL;
