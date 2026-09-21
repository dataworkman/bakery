# Bakery App

Rails 8 app for managing custom cake orders across branches. Staff sign up, a master user approves them, and approved staff create and review orders (grouped by branch or date). Only master users can delete orders or manage staff.

## Local development

```bash
bin/setup            # install gems, prepare the database
bin/dev              # Rails server + Tailwind watcher
bin/rails test       # test suite
```

## First admin (master) account

Sign-ups are never auto-approved. Create the first master account from the console instead:

```bash
bin/rails users:create_master EMAIL=owner@example.com PASSWORD=choose-a-long-password
# production (Kamal)
bin/kamal app exec --reuse "bin/rails users:create_master EMAIL=owner@example.com PASSWORD=..."
```

Running it for an existing email promotes that user to an approved master (the password is only changed if `PASSWORD` is given).

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
