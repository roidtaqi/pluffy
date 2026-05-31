#!/usr/bin/env sh
set -eu

if [ "${DB_CONNECTION:-sqlite}" = "pgsql" ] && [ -z "${DB_URL:-}" ]; then
  echo "ERROR: DB_URL wajib diisi saat DB_CONNECTION=pgsql. Tambahkan reference variable Postgres.DATABASE_URL pada service Pluffy." >&2
  exit 1
fi

php artisan migrate --force
