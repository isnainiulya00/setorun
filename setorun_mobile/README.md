# SETORUN — Mobile (Flutter)

Aplikasi Android/iOS untuk murid dan guru halaqoh. Panduan tim lengkap: [README root](../README.md).

---

## Stack

| Komponen | Paket |
|----------|--------|
| UI | Flutter 3.x (Material 3) |
| Font | google_fonts (Poppins) |
| HTTP | dio |
| State | provider |
| Session | shared_preferences (JWT) |
| Backend | Django REST API (bukan Firebase) |

---

## Persyaratan

- Flutter SDK ≥ 3.11 (lihat `environment.sdk` di `pubspec.yaml`)
- Backend SETORUN sudah jalan di port **8000**
- Emulator / device dengan akses ke host backend

---

## Setup

```powershell
cd setorun_mobile
flutter pub get
flutter run
```

### Menghubungkan ke backend

File: `lib/config/api_config.dart`

| Device | URL default |
|--------|-------------|
| Android Emulator | `http://10.0.2.2:8000/api` |
| Windows / iOS Simulator | `http://127.0.0.1:8000/api` |
| HP fisik (Wi‑Fi sama) | Override IP laptop |

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.5:8000/api
```

Backend harus dijalankan dengan:

```powershell
python manage.py runserver 0.0.0.0:8000
```

---

## Struktur `lib/`

```
lib/
├── main.dart                 # Entry + MultiProvider
├── app.dart                  # AuthGate (routing by role)
├── config/
│   └── api_config.dart       # Base URL API
├── models/
│   ├── user_model.dart
│   └── halaqoh_model.dart
├── services/
│   ├── api_client.dart       # Dio + interceptor Bearer
│   ├── auth_service.dart     # login, register, profile, logout
│   └── storage_service.dart  # SharedPreferences JWT
├── providers/
│   └── auth_provider.dart    # Status auth global
└── screens/
    ├── auth/
    │   └── login_screen.dart
    ├── student/
    │   ├── dashboard_screen.dart
    │   ├── home_page.dart
    │   ├── mutabaah_page.dart
    │   └── halaqoh_selection_screen.dart  # legacy, tidak dipakai flow baru
    ├── teacher/
    │   ├── teacher_dashboard_screen.dart
    │   └── fill_mutabaah_screen.dart
    └── shared/
        ├── chat_page.dart
        ├── quran_page.dart
        ├── profile_page.dart
        └── video_call_screen.dart
```

---

## Alur autentikasi (mobile)

```
App start
  → AuthProvider.initialize()
  → Ada token di SharedPreferences?
       Ya → GET /api/auth/profile/
       Tidak → LoginScreen

Login berhasil
  → Simpan access + refresh + user JSON
  → role == teacher → TeacherDashboardScreen
  → role == student  → DashboardScreen (tanpa pilih halaqoh)

Register (murid)
  → POST /api/auth/register/ (+ gender, halaqoh_id)
  → Langsung dapat token → Dashboard murid

Logout
  → POST /api/auth/logout/ (opsional)
  → Hapus SharedPreferences
  → AuthGate → LoginScreen
```

---

## Layar per role

### Murid — bottom nav

| Tab | File | Status data |
|-----|------|-------------|
| Home | `student/home_page.dart` | Dummy / lokal |
| Chat | `shared/chat_page.dart` | Dummy |
| Mutabaah | `student/mutabaah_page.dart` | Dummy |
| Quran | `shared/quran_page.dart` | Dummy / partial API |
| Profil | `shared/profile_page.dart` | Terhubung API (nama, email, halaqoh) |

### Guru — bottom nav

| Tab | File |
|-----|------|
| Home | `teacher_dashboard_screen.dart` (embedded) |
| Chat | `shared/chat_page.dart` |
| Quran | `shared/quran_page.dart` |
| Profil | `shared/profile_page.dart` |

Aksi cepat di Home guru: video call, isi mutabaah, chat (navigasi ke layar terkait).

---

## Kunci SharedPreferences

| Key | Isi |
|-----|-----|
| `access_token` | JWT access |
| `refresh_token` | JWT refresh |
| `user_data` | JSON profil user |

---

## Model data (JSON API)

### UserModel

| Field API | Property Dart |
|-----------|---------------|
| `id` | `id` |
| `email` | `email` |
| `full_name` / `nama` | `fullName` |
| `gender` | `gender` (`male` / `fem`) |
| `role` | `role` (`student` / `teacher`) |
| `halaqoh_detail` | `halaqoh` (HalaqohModel) |

Helper:

- `isStudent` / `isTeacher`
- `uiRole` → `"Murid"` / `"Guru"`
- `genderLabel` → `"Laki-laki"` / `"Perempuan"`

### HalaqohModel

Menerima `name` atau `nama` dari API.

---

## Tes manual

1. Backend + `seed_demo` aktif
2. `flutter run`
3. Login `murid@setorun.id` / `murid12345` → dashboard murid, profil tampil nama + halaqoh
4. Logout → login screen
5. Tutup app, buka lagi → masih login
6. Login `guru@setorun.id` / `guru12345` → dashboard guru
7. Daftar akun murid baru (mode Daftar) → pilih gender + halaqoh

---

## Android khusus

`android/app/src/main/AndroidManifest.xml`:

- `INTERNET` permission
- `android:usesCleartextTraffic="true"` — untuk HTTP dev (hapus/atur di production HTTPS)

---

## Troubleshooting mobile

| Gejala | Penyebab umum | Solusi |
|--------|---------------|--------|
| Connection error | Backend mati / URL salah | Cek `api_config.dart`, jalankan `runserver 0.0.0.0:8000` |
| Emulator tidak connect | Salah host | Android: `10.0.2.2`, bukan `127.0.0.1` |
| HP fisik gagal | Firewall / beda subnet | IP LAN + `dart-define` |
| Login snackbar error | Kredensial / seed | `python manage.py seed_demo` |
| Build symlink error (Windows) | Developer Mode | Aktifkan Developer Mode di Windows Settings |

---

## Menambah fitur baru (panduan singkat)

1. **Endpoint baru** — tambah method di `services/`, model di `models/` jika perlu
2. **State global** — extend `providers/` atau buat provider baru
3. **Layar** — folder `screens/student|teacher|shared`
4. **Jangan** taruh logic API di widget — lewat service

Contoh panggilan API terautentikasi (sudah ada interceptor token):

```dart
final response = await apiClient.dio.get('/mutabaah/');
```

---

## Roadmap mobile

- [ ] Mutabaah list dari API
- [ ] Chat realtime
- [ ] Jitsi Meet integration
- [ ] Quran API (ganti dummy)
- [ ] Edit profil & ganti password UI
- [ ] Dark mode & bahasa

---

## Dokumentasi terkait

- [README root](../README.md) — gambaran tim & API ringkas
- [Backend README](../setorun_backend/README.md) — detail endpoint & database
