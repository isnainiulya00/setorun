# SETORUN

Aplikasi manajemen hafalan (mutabaah) untuk halaqoh — **Flutter** (mobile) + **Django REST API** + **PostgreSQL**.

Dokumen ini panduan utama untuk tim. Detail teknis per modul ada di:

- [setorun_backend/README.md](setorun_backend/README.md) — Django, database, API
- [setorun_mobile/README.md](setorun_mobile/README.md) — Flutter, struktur UI, koneksi API

---

## Daftar isi

1. [Gambaran proyek](#gambaran-proyek)
2. [Struktur repository](#struktur-repository)
3. [Persyaratan sistem](#persyaratan-sistem)
4. [Quick start (tim baru)](#quick-start-tim-baru)
5. [Alur aplikasi](#alur-aplikasi)
6. [Skema database](#skema-database)
7. [Autentikasi (JWT)](#autentikasi-jwt)
8. [API yang sudah tersedia](#api-yang-sudah-tersedia)
9. [Akun demo](#akun-demo)
10. [Konfigurasi lingkungan](#konfigurasi-lingkungan)
11. [Menjalankan backend + mobile](#menjalankan-backend--mobile)
12. [Roadmap fitur](#roadmap-fitur)
13. [Troubleshooting](#troubleshooting)
14. [Konvensi tim](#konvensi-tim)

---

## Gambaran proyek

| Lapisan | Teknologi | Folder |
|---------|-----------|--------|
| Mobile | Flutter 3.x | `setorun_mobile/` |
| API | Django 5 + DRF + SimpleJWT | `setorun_backend/` |
| Database | PostgreSQL (production) / SQLite (dev cepat) | — |

**Prinsip penting:**

- **Bukan Firebase** untuk auth/database utama.
- **Guru** tidak bisa register di app — akun dibuat lewat Django Admin / seed / SQL.
- **Murid** bisa register sendiri, pilih halaqoh, lalu langsung masuk dashboard (tanpa pilih halaqoh manual lagi).
- UI mobile: tema emerald/teal, minimalis — **jangan redesign total** tanpa koordinasi tim.

---

## Struktur repository

```
setorun/
├── README.md                 ← Anda di sini (panduan tim)
├── setorun_backend/          ← Django API
│   ├── api/                  ← Models, views, serializers, auth JWT
│   ├── schema.sql            ← DDL PostgreSQL referensi
│   ├── requirements.txt
│   ├── .env.example
│   └── README.md
└── setorun_mobile/           ← Flutter app
    ├── lib/
    │   ├── config/           ← URL API
    │   ├── models/
    │   ├── services/         ← HTTP, auth, SharedPreferences
    │   ├── providers/        ← State (Provider)
    │   ├── screens/          ← UI per fitur
    │   └── app.dart          ← AuthGate (routing by role)
    └── README.md
```

---

## Persyaratan sistem

### Semua developer

| Tool | Versi disarankan |
|------|------------------|
| Git | Terbaru |
| Python | 3.11+ |
| pip / venv | — |
| PostgreSQL | 14+ (production & staging) |
| Flutter SDK | 3.11+ (lihat `pubspec.yaml`) |
| Android Studio / VS Code | Untuk emulator & debug |

### Opsional

- **pgAdmin** atau **DBeaver** — inspeksi database
- **Postman / Bruno** — uji API tanpa mobile

---

## Quick start (tim baru)

### 1. Clone & masuk folder

```powershell
cd path\to\setorun
```

### 2. Backend (5 menit, mode SQLite)

```powershell
cd setorun_backend
# Jika "No module named venv.__main__" → pakai virtualenv (lihat Troubleshooting)
py -m pip install virtualenv
py -m virtualenv venv
.\venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
```

Edit `.env`, pastikan:

```env
USE_SQLITE=True
```

Lalu:

```powershell
python manage.py migrate
python manage.py seed_demo
python manage.py runserver 0.0.0.0:8000
```

Backend aktif di: **http://127.0.0.1:8000**

### 3. Mobile

Terminal baru:

```powershell
cd setorun_mobile
flutter pub get
flutter run
```

### 4. Tes login

| Role | Email | Password |
|------|-------|----------|
| Murid | `murid@setorun.id` | `murid12345` |
| Guru | `guru@setorun.id` | `guru12345` |

---

## Alur aplikasi

### Murid (student)

```
Register (email, nama, gender, password, pilih halaqoh)
    → JWT disimpan di SharedPreferences
    → Dashboard Murid (Home, Chat, Mutabaah, Quran, Profil)

Login
    → Cek email di tabel murid / guru
    → Jika murid → Dashboard Murid (halaqoh dari database, tanpa layar pilih halaqoh)
```

### Guru (teacher)

```
Register di app → TIDAK DIDUKUNG

Login (akun dari admin)
    → Dashboard Guru (Home, Chat, Quran, Profil, + aksi dari Home)
```

### Logout

- Hapus token JWT di SharedPreferences
- Kembali ke layar login

---

## Skema database

Skema resmi (PostgreSQL) ada di [`setorun_backend/schema.sql`](setorun_backend/schema.sql).

### Diagram relasi

```
guru (1) ──────< (1) halaqoh
                    │
                    │ (1:N, nullable)
                    ▼
                  murid
                    │
                    │ (1:N)
                    ▼
                mutabaah
```

### Tabel ringkas

| Tabel | Isi utama |
|-------|-----------|
| `guru` | `nama`, `gender`, `email`, `password_2` |
| `halaqoh` | `nama`, `gender`, `guru_id` (UNIQUE — satu guru satu halaqoh) |
| `murid` | `nama`, `gender`, `email`, `password_2`, `halaqoh_id` |
| `mutabaah` | `murid_id`, `tanggal`, `nama_surah`, `ayat`, `note`, `keterangan` |

### ENUM

| Nama | Nilai |
|------|-------|
| `user_gender` | `male`, `fem` |
| `mutabaah_note` | `ziyadah`, `murajaah` |

### Catatan password

- Kolom di DB: **`password_2`**
- Di Django disimpan **ter-hash** (bukan plain text), via `set_password()` / `check_password()` pada model `Guru` dan `Murid`.

### Membuat guru baru (tim backend)

1. Django Admin: `http://127.0.0.1:8000/admin/` (butuh `createsuperuser` untuk login admin Django)
2. Atau insert ke tabel `guru`, lalu buat baris `halaqoh` dengan `guru_id` yang sama
3. Atau perintah: `python manage.py seed_demo` (hanya data demo)

---

## Autentikasi (JWT)

### Cara kerja

1. Client kirim `POST /api/auth/login/` dengan `email` + `password`.
2. Server cek email di **`guru`**, lalu **`murid`**.
3. Response berisi `access`, `refresh`, dan objek `user`.
4. Request berikutnya: header `Authorization: Bearer <access_token>`.

### Isi token (payload penting)

| Claim | Nilai |
|-------|-------|
| `user_type` | `guru` atau `murid` |
| `user_id` | ID di tabel terkait |
| `email` | Email akun |
| `nama` | Nama tampilan |

### Response `user` (untuk Flutter)

| Field | Contoh | Keterangan |
|-------|--------|------------|
| `role` | `student` / `teacher` | Untuk routing UI |
| `role_display` | `Murid` / `Guru` | Label Indonesia |
| `full_name` | `Isnaini` | Sama dengan `nama` di DB |
| `gender` | `male` / `fem` | |
| `halaqoh` | `1` | ID halaqoh (null jika belum ada) |
| `halaqoh_detail` | `{ id, nama, name, gender, guru_name }` | Nested object |

---

## API yang sudah tersedia

Base URL: `http://127.0.0.1:8000/api` (sesuaikan host di mobile — lihat bawah).

### Auth

| Method | Path | Auth | Keterangan |
|--------|------|------|------------|
| POST | `/auth/login/` | Tidak | Login guru atau murid |
| POST | `/auth/register/` | Tidak | **Murid saja** |
| POST | `/auth/logout/` | Bearer | Client tetap hapus token lokal |
| GET | `/auth/profile/` | Bearer | Profil akun login |
| PATCH | `/auth/profile/` | Bearer | Update `full_name`, `email`, `gender` |

### Halaqoh

| Method | Path | Auth | Keterangan |
|--------|------|------|------------|
| GET | `/halaqoh/` | Tidak | List untuk dropdown register |
| GET | `/halaqoh/me/` | Bearer | Halaqoh milik user login |

### Contoh: Login

**Request**

```http
POST /api/auth/login/
Content-Type: application/json

{
  "email": "murid@setorun.id",
  "password": "murid12345"
}
```

**Response (200)**

```json
{
  "access": "<jwt_access>",
  "refresh": "<jwt_refresh>",
  "user": {
    "id": 1,
    "email": "murid@setorun.id",
    "full_name": "Isnaini",
    "nama": "Isnaini",
    "gender": "fem",
    "role": "student",
    "role_display": "Murid",
    "halaqoh": 1,
    "halaqoh_detail": {
      "id": 1,
      "nama": "Halaqoh Al-Fatih",
      "name": "Halaqoh Al-Fatih",
      "gender": "fem",
      "guru_name": "Ustazah Isna"
    }
  }
}
```

### Contoh: Register murid

**Request**

```http
POST /api/auth/register/
Content-Type: application/json

{
  "email": "baru@email.com",
  "full_name": "Ahmad Fadillah",
  "gender": "male",
  "password": "password12345",
  "password_confirm": "password12345",
  "halaqoh_id": 1
}
```

**Response (201)** — sama format dengan login (langsung dapat token).

### Contoh: Profile (Bearer token)

```http
GET /api/auth/profile/
Authorization: Bearer <access_token>
```

---

## Akun demo

Diisi otomatis oleh:

```powershell
python manage.py seed_demo
```

| Role | Email | Password | Halaqoh |
|------|-------|----------|---------|
| Guru | `guru@setorun.id` | `guru12345` | Halaqoh Al-Fatih (via relasi 1-1) |
| Murid | `murid@setorun.id` | `murid12345` | Halaqoh Al-Fatih |

---

## Konfigurasi lingkungan

### Backend — file `.env`

Salin dari `.env.example`:

```powershell
cd setorun_backend
copy .env.example .env
```

| Variable | Contoh | Keterangan |
|----------|--------|------------|
| `SECRET_KEY` | string panjang | Wajib beda di production |
| `DEBUG` | `True` / `False` | `False` di production |
| `ALLOWED_HOSTS` | `localhost,127.0.0.1,10.0.2.2` | Tambah IP server |
| `USE_SQLITE` | `True` | Dev tanpa PostgreSQL |
| `DB_NAME` | `setorun_db` | Jika `USE_SQLITE=False` |
| `DB_USER` | `postgres` | |
| `DB_PASSWORD` | `***` | |
| `DB_HOST` | `localhost` | |
| `DB_PORT` | `5432` | |

### Mobile — URL API

File: `setorun_mobile/lib/config/api_config.dart`

| Lingkungan | URL default |
|------------|-------------|
| Android Emulator | `http://10.0.2.2:8000/api` |
| iOS Simulator / Windows | `http://127.0.0.1:8000/api` |
| HP fisik (LAN) | Override saat run |

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
```

Ganti `192.168.1.10` dengan IP laptop yang menjalankan `runserver`.

---

## Menjalankan backend + mobile

### Urutan yang benar

1. Jalankan **backend dulu** (`runserver`)
2. Baru jalankan **Flutter**
3. Pastikan firewall mengizinkan port **8000** jika tes dari HP fisik

### PostgreSQL (staging / production)

```sql
CREATE DATABASE setorun_db;
```

```powershell
# .env
USE_SQLITE=False
DB_NAME=setorun_db
DB_USER=postgres
DB_PASSWORD=<password>
```

Opsi A — Django migrate (disarankan):

```powershell
python manage.py migrate
python manage.py seed_demo
```

Opsi B — DDL manual lalu migrate:

```powershell
psql -U postgres -d setorun_db -f schema.sql
python manage.py migrate
```

### Reset database development

Jika model berubah atau data kacau:

```powershell
cd setorun_backend
Remove-Item db.sqlite3 -ErrorAction SilentlyContinue
$env:USE_SQLITE="True"
python manage.py migrate
python manage.py seed_demo
```

---

## Roadmap fitur

| Status | Fitur |
|--------|-------|
| Selesai | Auth JWT, register murid, login role-based, profil dasar, list halaqoh |
| UI ada, belum API penuh | Chat, Mutabaah CRUD, Quran API, Video call (Jitsi), edit profil lanjutan |
| Rencana | Realtime chat (Channels/polling), mutabaah API guru, dark mode, ganti password |

Update baris ini saat PR merge fitur baru.

---

## Troubleshooting

### Mobile: "Tidak dapat terhubung ke server"

- Backend sudah `runserver 0.0.0.0:8000`?
- Emulator Android pakai `10.0.2.2`, bukan `localhost`
- HP fisik: IP LAN + `--dart-define=API_BASE_URL=...`
- `INTERNET` permission & cleartext sudah di `AndroidManifest.xml` (dev HTTP)

### Login gagal padahal akun benar

- Jalankan ulang `seed_demo`
- Email harus persis (mis. `murid@setorun.id`)
- Cek backend log di terminal

### `No module named venv.__main__` (gagal buat virtual env)

Instalasi Python Anda **tidak lengkap** — folder `Lib\venv` kosong.

**Solusi cepat (disarankan):**

```powershell
cd setorun_backend
py -m pip install virtualenv
py -m virtualenv venv
.\venv\Scripts\activate
pip install -r requirements.txt
```

**Solusi permanen:** install ulang Python 3.11 dari [python.org](https://www.python.org/downloads/), centang **"Install launcher"** dan **"pip"**, lalu di "Customize" pastikan **venv** tercentang.

### `ModuleNotFoundError: dotenv`

```powershell
pip install -r requirements.txt
```

### Migrasi error setelah pull

```powershell
python manage.py migrate
```

Jika masih gagal di dev: reset SQLite (lihat [Reset database](#reset-database-development)).

### Register: "Email sudah terdaftar"

Email unik di **guru** dan **murid** — tidak boleh duplikat antar tabel.

### CORS error (web / testing)

Di development `DEBUG=True` → CORS allow all. Production: set `CORS_ALLOWED_ORIGINS` di `.env`.

---

## Konvensi tim

### Branch & commit

- Satu fitur = satu branch (mis. `feat/mutabaah-api`)
- Commit message jelas: `feat: ...`, `fix: ...`, `docs: ...`

### Backend

- Model harus selaras `schema.sql` — ubah skema = update SQL + model + migrasi + README
- Endpoint baru: dokumentasikan di `setorun_backend/README.md` dan tabel API di README root ini
- Jangan commit file `.env` (sudah di `.gitignore`)

### Mobile

- Jangan taruh logic bisnis di `main.dart` — pakai `services/` + `providers/`
- Layar baru: taruh di `lib/screens/` sesuai subfolder (`student/`, `teacher/`, `shared/`, `auth/`)
- Pertahankan tema teal/emerald

### Testing manual minimum sebelum PR

- [ ] Login murid & guru
- [ ] Register murid baru
- [ ] Logout → kembali login
- [ ] Restart app → masih login (persistent token)
- [ ] Profile menampilkan nama & halaqoh benar

---

## Kontak & dokumentasi lanjutan

| Topik | File |
|-------|------|
| Django detail | [setorun_backend/README.md](setorun_backend/README.md) |
| Flutter detail | [setorun_mobile/README.md](setorun_mobile/README.md) |
| DDL PostgreSQL | [setorun_backend/schema.sql](setorun_backend/schema.sql) |

Jika ada bagian yang kurang jelas, tambahkan issue di repo atau update README ini via PR `docs: ...`.
