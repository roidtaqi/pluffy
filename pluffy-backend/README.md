# Pluffy Backend

Backend Laravel untuk aplikasi pemesanan Pluffy dan portal admin dapur.

## Endpoint Penting

- Status backend: `/`
- Health check: `/up`
- Produk publik: `/api/products`
- Registrasi user: `/api/register`
- Login user: `/api/login`
- Portal admin: `/admin`

## Menjalankan Secara Lokal

```bash
composer install
cp .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve --host=0.0.0.0 --port=8000
```

## Deployment Publik Dengan Railway

Railway dapat mendeteksi Laravel melalui Railpack dan menjalankannya dengan
FrankenPHP serta Caddy. Pluffy menyediakan `railway.json` untuk menjalankan
migrasi database sebelum deploy dan memeriksa endpoint `/up` sebelum versi baru
diaktifkan.

Backend ini tidak menjalankan `npm install`. API dan portal admin menggunakan
Laravel Blade tanpa aset Vite, sehingga image Railway cukup dibangun dengan
PHP dan Composer.

### 1. Buat Layanan Database

Di Railway, buat project baru lalu tambahkan layanan PostgreSQL.

### 2. Hubungkan Repository

Buat layanan baru dari repository GitHub Pluffy. Karena backend berada di dalam
monorepo Flutter, atur:

```text
Root Directory: /pluffy-backend
Config File: /pluffy-backend/railway.json
```

### 3. Tambahkan Environment Variables

Salin isi `.env.railway.example` ke tab Variables layanan backend. Isi nilai
berikut dengan nilai asli:

```text
APP_KEY
APP_URL
PLUFFY_FRONTEND_URLS
PLUFFY_ADMIN_EMAIL
PLUFFY_ADMIN_PASSWORD
MAIL_HOST
MAIL_USERNAME
MAIL_PASSWORD
```

Gunakan nilai `PLUFFY_ADMIN_EMAIL` dan `PLUFFY_ADMIN_PASSWORD` tersebut untuk
login ke portal `/admin`. Jangan menyertakan tanda kutip pada nilai variable.

Fitur lupa password mengirim kode verifikasi melalui SMTP. Isi `MAIL_HOST`,
`MAIL_PORT`, `MAIL_USERNAME`, `MAIL_PASSWORD`, dan `MAIL_FROM_ADDRESS` dengan
akun email transaksional milik Pluffy. Gunakan `MAIL_MAILER=log` hanya untuk
pengembangan lokal.

Buat `APP_KEY` dengan:

```bash
php artisan key:generate --show
```

`DB_URL=${{Postgres.DATABASE_URL}}` mengambil koneksi database dari layanan
PostgreSQL Railway di project yang sama.

### 4. Buat Domain HTTPS

Di tab Networking layanan backend, pilih **Generate Domain**. Railway akan
memberikan domain HTTPS seperti:

```text
https://pluffy-backend-production.up.railway.app
```

Gunakan domain tersebut untuk `APP_URL`.

Biarkan Railway menyediakan variable `PORT` secara otomatis. Railpack akan
menjalankan Caddy pada nilai tersebut dan Railway dapat mendeteksi target port
domain. URL publik tetap ditulis tanpa port, misalnya:

```text
https://pluffy-backend-production.up.railway.app/up
```

### 5. Isi Produk Awal

Setelah deploy pertama berhasil, jalankan sekali dari Railway shell:

```bash
php artisan db:seed --force
```

Seeder aman dijalankan ulang dan tidak menggandakan produk.

### 6. Build Aplikasi Handphone

Dari root repository Flutter:

```bash
flutter build apk --release \
  --dart-define=PLUFFY_API_BASE_URL=https://DOMAIN-BACKEND-KAMU/api
```

APK hasil production tidak lagi bergantung pada alamat IP Wi-Fi laptop.

## Worker Dan Cron Opsional

Pluffy belum membutuhkan worker atau cron untuk fitur saat ini. Jika nanti
notifikasi email atau pekerjaan terjadwal ditambahkan, buat layanan Railway
tambahan dengan start command:

```bash
chmod +x ./railway/run-worker.sh && sh ./railway/run-worker.sh
```

atau:

```bash
chmod +x ./railway/run-cron.sh && sh ./railway/run-cron.sh
```

## Pemeriksaan Setelah Deploy

```bash
curl -I https://DOMAIN-BACKEND-KAMU/up
curl https://DOMAIN-BACKEND-KAMU/api/products
curl -I https://DOMAIN-BACKEND-KAMU/admin
```

Respons yang diharapkan:

- `/up`: HTTP `200`
- `/api/products`: JSON produk
- `/admin`: redirect ke `/admin/login`
