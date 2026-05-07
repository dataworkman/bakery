# Bakery App

## Password reset email setup

Password reset uses Action Mailer. Set these environment variables in production:

- `APP_HOST` (e.g. `bakery.example.com`)
- `SMTP_ADDRESS` (e.g. `smtp.gmail.com`)
- `SMTP_PORT` (default: `587`)
- `SMTP_USERNAME`
- `SMTP_PASSWORD`
- `SMTP_DOMAIN` (usually same as `APP_HOST`)
- `SMTP_AUTHENTICATION` (default: `plain`)
- `SMTP_ENABLE_STARTTLS_AUTO` (default: `true`)

After deployment, verify:

1. Request password reset from `/passwords/new`
2. Confirm reset email arrives
3. Confirm email link host matches `APP_HOST`

## Quick production checks (Kamal)

```bash
bin/kamal app exec --reuse "printenv | grep -E 'APP_HOST|SMTP_'"
bin/kamal app exec --reuse "bin/rails runner 'p ActionMailer::Base.smtp_settings'"
bin/kamal app exec --reuse "bin/rails runner 'u=User.first; PasswordsMailer.reset(u).deliver_now; puts :ok'"
bin/kamal app logs -f
```
