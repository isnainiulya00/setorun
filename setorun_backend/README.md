# SETORUN — Backend (Django REST API)

API server untuk aplikasi mobile SETORUN. Panduan tim lengkap juga ada di [README root](../README.md).

---

## Stack

| Komponen | Paket |
|----------|--------|
| Framework | Django 5.x |
| API | Django REST Framework |
| Auth | djangorestframework-simplejwt (custom: guru / murid) |
| DB | PostgreSQL (prod) / SQLite (dev) |
| CORS | django-cors-headers |
| Config | python-dotenv |

---

## Struktur folder

```
setorun_backend/
├── api/
│   ├── models.py          # Guru, Halaqoh, Murid, Mutabaah
│   ├── serializers.py
│   ├── views.py
│   ├── urls.py
│   ├── authentication.py  # SetorunJWTAuthentication
│   ├── tokens.py          # JWT claims user_type + user_id
│   ├── admin.py
│   └── management/commands/
│       └── seed_demo.py
├── setorun_backend/
│   ├── settings.py
│   └── urls.py            # /api/ → api.urls
├── schema.sql             # DDL PostgreSQL referensi
├── requirements.txt
├── .env.example
└── manage.py
```

---

## Skema database

### DDL

File lengkap: [`schema.sql`](schema.sql)

### Model Django ↔ Tabel SQL

| Model | Tabel | Catatan |
|-------|-------|---------|
| `Guru` | `guru` | Tidak pakai `django.contrib.auth.User` |
| `Halaqoh` | `halaqoh` | `guru_id` UNIQUE (OneToOne) |
| `Murid` | `murid` | Bisa register dari API |
| `Mutabaah` | `mutabaah` | CRUD API belum diekspos (model siap) |

### Field penting

**guru / murid**

- `nama` — nama tampilan
- `gender` — `male` | `fem`
- `email` — unique, dipakai login
- `password_2` — password ter-hash

**mutabaah**

- `note` — `ziyadah` | `murajaah`
- `keterangan` — opsional

---

## Setup lokal

### 1. Virtual environment

```powershell
cd setorun_backend
py -m pip install virtualenv
py -m virtualenv venv
.\venv\Scripts\activate
pip install -r requirements.txt
```

> **Catatan Windows:** Jika `python -m venv venv` gagal dengan error `No module named venv.__main__`, artinya modul `venv` bawaan Python tidak terpasang. Gunakan perintah `virtualenv` di atas, atau install ulang Python dengan komponen **venv** enabled.

### 2. Environment

```powershell
copy .env.example .env
```

**Development cepat (tanpa PostgreSQL):**

```env
USE_SQLITE=True
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1,10.0.2.2
```

**PostgreSQL:**

```env
USE_SQLITE=False
DB_NAME=setorun_db
DB_USER=postgres
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432
```

Buat database:

```sql
CREATE DATABASE setorun_db;
```

### 3. Migrasi & data demo

```powershell
python manage.py migrate
python manage.py seed_demo
```

### 4. Superuser Django Admin (opsional)

Untuk kelola data lewat `/admin/`:

```powershell
python manage.py createsuperuser
```

Login admin Django **bukan** akun guru di tabel `guru` — itu user terpisah di tabel `auth_user` bawaan Django.

### 5. Jalankan server

```powershell
python manage.py runserver 0.0.0.0:8000
```

- API: http://127.0.0.1:8000/api/
- Admin: http://127.0.0.1:8000/admin/

---

## Autentikasi

### Tidak ada `AUTH_USER_MODEL` custom

User login adalah instance **`Guru`** atau **`Murid`**, bukan model User Django.

### JWT

Class: `api.authentication.SetorunJWTAuthentication`

| Claim | Arti |
|-------|------|
| `user_type` | `guru` atau `murid` |
| `user_id` | Primary key di tabel tersebut |

### Login flow (kode)

1. `LoginSerializer` terima `email`, `password`
2. Cari di `Guru`, lalu `Murid`
3. `check_password()` pada `password_2`
4. Generate token via `get_tokens_for_account()`
5. Return `access`, `refresh`, `user` (dict dari `AccountSerializer.from_account()`)

### Register

- Hanya **`MuridRegisterSerializer`** → insert ke tabel `murid`
- Validasi email unik di **guru ∪ murid**
- Response 201 langsung berisi token (auto login)

---

## Daftar endpoint

Prefix: `/api/`

### Auth

#### `POST /api/auth/login/`

**Body**

```json
{
  "email": "murid@setorun.id",
  "password": "murid12345"
}
```

**Response 200**

```json
{
  "access": "...",
  "refresh": "...",
  "user": { "...": "..." }
}
```

**Error 400** — `{"detail": "Email atau kata sandi salah."}`

---

#### `POST /api/auth/register/`

**Body** (murid saja)

```json
{
  "email": "baru@email.com",
  "full_name": "Nama Lengkap",
  "gender": "male",
  "password": "minimal8karakter",
  "password_confirm": "minimal8karakter",
  "halaqoh_id": 1
}
```

| Field | Aturan |
|-------|--------|
| `gender` | `male` atau `fem` |
| `password` | Validasi Django password validators |
| `halaqoh_id` | Harus ID halaqoh yang ada |

---

#### `POST /api/auth/logout/`

Header: `Authorization: Bearer <access>`

Response: `{"detail": "Berhasil logout."}`

Client **wajib** hapus token di SharedPreferences; server tidak blacklist token (MVP).

---

#### `GET /api/auth/profile/`

Header: Bearer token

Response: objek `user` sama seperti di login.

---

#### `PATCH /api/auth/profile/`

Header: Bearer token

**Body** (semua opsional)

```json
{
  "full_name": "Nama Baru",
  "email": "emailbaru@setorun.id",
  "gender": "fem"
}
```

---

### Halaqoh

#### `GET /api/halaqoh/`

Public (tanpa token). Untuk dropdown register murid.

**Response** — array:

```json
[
  {
    "id": 1,
    "nama": "Halaqoh Al-Fatih",
    "name": "Halaqoh Al-Fatih",
    "gender": "fem",
    "guru_name": "Ustazah Isna"
  }
]
```

---

#### `GET /api/halaqoh/me/`

Header: Bearer token

- Murid → halaqoh dari `murid.halaqoh_id`
- Guru → halaqoh dari relasi OneToOne `guru.halaqoh`

**404** jika belum punya halaqoh.

---

## Management commands

| Command | Fungsi |
|---------|--------|
| `python manage.py migrate` | Terapkan migrasi |
| `python manage.py seed_demo` | Guru + halaqoh + murid demo |
| `python manage.py createsuperuser` | Admin Django |
| `python manage.py makemigrations` | Setelah ubah model |

---

## Akun demo (`seed_demo`)

| Tabel | Email | Password | Keterangan |
|-------|-------|----------|------------|
| guru | guru@setorun.id | guru12345 | Punya halaqoh Al-Fatih |
| murid | murid@setorun.id | murid12345 | Terdaftar di halaqoh yang sama |

---

## Menambah guru + halaqoh manual

### Via Django Admin

1. `createsuperuser` → login `/admin/`
2. Tambah **Guru** (isi `password_2` plain — **perlu di-hash manual** lewat shell, atau gunakan seed/command)

**Disarankan via shell:**

```powershell
python manage.py shell
```

```python
from api.models import Guru, Halaqoh, UserGender

g = Guru(nama='Ust. Budi', gender=UserGender.MALE, email='budi@setorun.id')
g.set_password('password123')
g.save()

Halaqoh.objects.create(nama='Halaqoh Putra A', gender=UserGender.MALE, guru=g)
```

### Aturan bisnis

- Satu **guru** hanya boleh punya **satu halaqoh** (`guru_id` UNIQUE).
- **Murid** boleh banyak per halaqoh.

---

## Pengujian API (curl)

```powershell
# Login
curl -X POST http://127.0.0.1:8000/api/auth/login/ ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"murid@setorun.id\",\"password\":\"murid12345\"}"

# List halaqoh
curl http://127.0.0.1:8000/api/halaqoh/

# Profile (ganti TOKEN)
curl http://127.0.0.1:8000/api/auth/profile/ ^
  -H "Authorization: Bearer TOKEN"
```

---

## Migrasi & perubahan skema

Setelah ubah `api/models.py`:

```powershell
python manage.py makemigrations api
python manage.py migrate
```

Jika konflik di dev SQLite:

```powershell
Remove-Item db.sqlite3
python manage.py migrate
python manage.py seed_demo
```

Production PostgreSQL: **jangan** hapus DB sembarangan — buat migrasi forward atau backup dulu.

---

## Production checklist

- [ ] `DEBUG=False`
- [ ] `SECRET_KEY` kuat & rahasia
- [ ] `USE_SQLITE=False` + PostgreSQL
- [ ] `ALLOWED_HOSTS` berisi domain/IP server
- [ ] HTTPS (reverse proxy: Nginx / Caddy)
- [ ] `CORS_ALLOWED_ORIGINS` hanya domain app yang diizinkan
- [ ] Gunicorn + systemd / Docker
- [ ] Backup database terjadwal

---

## Troubleshooting backend

| Masalah | Solusi |
|---------|--------|
| `No module named 'dotenv'` | `pip install -r requirements.txt` |
| `relation "guru" does not exist` | `python manage.py migrate` |
| Login 401/400 | Pastikan `seed_demo` atau password di-hash dengan `set_password` |
| IntegrityError halaqoh | `guru_id` sudah dipakai halaqoh lain (OneToOne) |
| Port 8000 busy | `runserver 0.0.0.0:8001` + update URL di Flutter |

---

## Roadmap API

- [ ] CRUD `/api/mutabaah/` (guru: create/update/delete, murid: list read)
- [ ] Chat endpoints / WebSocket
- [ ] Video room (Jitsi) metadata
- [ ] Change password endpoint
- [ ] Proxy Quran API

Update checklist saat fitur selesai.
