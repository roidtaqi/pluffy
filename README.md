# Pluffy

Pluffy is a Flutter ordering app with a Laravel backend and admin portal.

## Local URLs

- Flutter web app: `http://127.0.0.1:8082`
- Laravel backend: `http://127.0.0.1:8000`
- Laravel admin: `http://127.0.0.1:8000/admin`

## Local Admin Login

The local admin credentials are read from `pluffy-backend/.env`:

- `PLUFFY_ADMIN_EMAIL`
- `PLUFFY_ADMIN_PASSWORD`

## Build Flutter Web

For local:

```bash
flutter build web --release \
  --dart-define=PLUFFY_API_BASE_URL=http://127.0.0.1:8000/api
```

## Run On A Physical Phone

When testing on a real phone, do not use `127.0.0.1` for the backend URL.
On the phone, `127.0.0.1` means the phone itself, not your laptop.

Start Laravel so it accepts network connections:

```bash
cd pluffy-backend
php artisan serve --host=0.0.0.0 --port=8000
```

Find your laptop IP:

```bash
hostname -I
```

Then run Flutter with that IP:

```bash
flutter run \
  --dart-define=PLUFFY_API_BASE_URL=http://192.168.1.11:8000/api
```

If your Wi-Fi changes, the laptop IP may change too. Re-run `hostname -I`
and update the `PLUFFY_API_BASE_URL` value.

For semi-publish/deploy:

```bash
flutter build web --release \
  --dart-define=PLUFFY_API_BASE_URL=https://your-backend-domain.com/api
```

## Backend Production Checklist

Use `pluffy-backend/.env.production.example` as the production template.

Before sharing the app publicly:

- Set `APP_ENV=production`
- Set `APP_DEBUG=false`
- Set `APP_URL` to the real backend URL
- Set `PLUFFY_FRONTEND_URLS` to the real frontend URL
- Replace `PLUFFY_ADMIN_PASSWORD` with a strong password
- Replace `PLUFFY_DEMO_USER_PASSWORD` or skip demo seeding
- Keep `SESSION_SECURE_COOKIE=true` on HTTPS
- Keep `SANCTUM_EXPIRATION` enabled so customer bearer tokens expire
- Run `php artisan key:generate` if `APP_KEY` is empty
- Run migrations and seeders as needed
- Serve Laravel over HTTPS

### Backend Deploy Commands

Run these on the production backend server from `pluffy-backend`:

```bash
composer install --no-dev --optimize-autoloader
cp .env.production.example .env
php artisan key:generate
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

Only run seeders on production if you intentionally want starter products/demo data:

```bash
php artisan db:seed --force
```

### Flutter Web Production Build

Build the public frontend with the real backend API URL:

```bash
flutter build web --release \
  --dart-define=PLUFFY_API_BASE_URL=https://api.your-domain.com/api
```

Upload the contents of `build/web` to the frontend host.

### Production Smoke Test

After deployment, verify:

- `https://api.your-domain.com` shows the Pluffy backend status page
- `https://api.your-domain.com/api/products` returns products
- `https://api.your-domain.com/api/orders` returns `401` without a token
- `https://api.your-domain.com/admin` redirects to admin login
- Register/login works from the public frontend
- A customer can place an order
- Admin can move the order status from `placed` to `preparing`
