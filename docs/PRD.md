# Product Requirements Document (PRD) — Scorpus

- **Nama Produk:** Scorpus
- **Package ID:** `com.dalvero.scorpus`
- **Versi Saat Ini:** `1.0.0+1`
- **Platform:** Android (Phone & Wear OS standalone), iOS (sekunder)
- **Tech Stack:** Flutter (Dart SDK `^3.11.5`), Kotlin (Android Native Widgets & Live Notifications)
- **Basis Codebase:** Modifikasi personal dari GymMane (Lisensi GPL-3.0; ilustrasi latihan CC BY-SA 4.0; font Nunito SIL OFL)
- **Status Arsitektur:** 100% Offline-First (tanpa izin `INTERNET` maupun `ACCESS_NETWORK_STATE`)

---

## 1. Visi & Ringkasan Produk

**Scorpus** adalah aplikasi pelacak kebugaran, gym, dan lari/kardio pribadi yang cepat, 100% offline, tanpa langganan, dan memberi kontrol penuh atas data latihan kepada pemiliknya.

Aplikasi ini menggabungkan:
1. **Workout Logger** (live & manual/backdate) dengan progressive overload otomatis, timer istirahat (rest alarm), dan timer tahan (isometric hold).
2. **Manajemen Rutinitas & Katalog Latihan** (552 gerakan bawaan + gerakan kustom + jadwal mingguan + import rencana dari AI eksternal).
3. **Analitik Progres & Pemulihan Otot** (heatmap aktivitas, estimasi 1RM, PR, peta panas otot, dan model pemulihan otot).
4. **Pelacakan Tubuh & Jurnal** (berat badan, 10 ukuran tubuh, timeline foto progres multi-pose + before/after compare, galeri momen, dan jurnal latihan).
5. **Utilitas Kebugaran & Ekosistem Android** (6 kalkulator, 5 Home Screen Widget, Android Live Workout Notification, dan aplikasi Wear OS standalone).

---

## 2. Target Pengguna & Persona

- **Pengguna Utama:** Pemilik aplikasi (Single User / Personal Use).
- **Profil:** Rutin latihan gym/beban dan kardio/lari, menggunakan perangkat Android dan wearable (Huawei SmartBand), menginginkan satu aplikasi terpadu yang bebas iklan, cepat dipakai saat di gym, dan menyimpan data secara lokal dengan aman.
- **Asumsi Skala Beban (Expected Load):** 1 pengguna aktif, 3–7 sesi latihan per minggu (~200–350 sesi/tahun), puluhan hingga ratusan foto progres/momen, dan backup berkala.

---

## 3. Prinsip Produk

1. **Offline-First & Zero Friction:** Semua fitur inti harus berjalan instan tanpa koneksi internet, tanpa login, dan tanpa loading server.
2. **Kepemilikan Data Penuh (Data Portability):** Pengguna dapat mengekspor seluruh data (CSV, JSON, ZIP lengkap dengan media) dan mengimpor riwayat dari aplikasi gym populer (Hevy, Strong, Lyfta, FitNotes, openGym).
3. **Ergonomis di Gym:** Mendukung pocket-lock saat latihan, kontrol cepat dari notifikasi Android, keep-screen-on, dan pengingat istirahat yang andal meski layar mati.
4. **Minim Bloat (YAGNI):** Hanya menambah fitur, abstraksi, atau integrasi yang benar-benar dipakai secara rutin.

---

## 4. Kebutuhan Fungsional (Functional Requirements)

### 4.1 Onboarding & Profil
- Wizard onboarding 6 langkah: Welcome, Nama, Unit (`kg`/`lb`), Data tubuh (tinggi, berat, usia, jenis kelamin), Target mingguan (1–7 hari), dan Lokasi latihan (Places + preset peralatan).
- Profil pengguna: nama, handle, avatar, banner, badge level atlet (`1 + totalSessions ~/ 10`), statistik seumur hidup, dan ringkasan tahunan (12 bulan).

### 4.2 Pencatatan Latihan (Workout Session — Live & Manual)
- Memulai sesi dari: Rutinitas hari ini, daftar rutinitas, pilih otot via `BodyMap`, atau pilih gerakan bebas (termasuk backdate untuk hari sebelumnya).
- Mode pencatatan per gerakan:
  - **Weight & Reps** (default)
  - **Reps Only** (bodyweight)
  - **Time** (isometrik/durasi dengan hold timer + beep countdown)
  - **Cardio** (durasi & jarak km/mi)
- Fitur selama sesi berlangsung:
  - Jenis set (`Normal`, `Warmup`, `Drop`, `Failure`, `Rest-Pause`).
  - Input `RPE` atau `RIR` (opsional, mempengaruhi estimasi 1RM).
  - Rekomendasi beban/reps otomatis (progressive overload & auto-warmup).
  - Superset chaining antar gerakan.
  - Rest timer otomatis dengan alarm audio/getar kustom dan notifikasi persisten (Android Live Notification dengan tombol `Done`, `Pause`, `+15s`, `Skip`, `Next`).
  - Pocket-lock (tahan untuk membuka kunci) dan 5-second start countdown.
  - Reorder, tambah, atau hapus gerakan di tengah sesi; park/resume sesi aktif.
- Ringkasan pasca-latihan: statistik sesi vs sesi terakhir, selebrasi konfeti, simpan sebagai rutinitas baru, dan bagikan sebagai kartu/stiker 9:16.

### 4.3 Katalog Latihan & Lokasi Gym (Places)
- 552 gerakan bawaan lengkap dengan ilustrasi vektor (`assets/art/`), otot primer/sekunder, peralatan, tingkat kesulitan, dan panduan langkah.
- Pencarian, filter multi-kriteria (lokasi, otot, alat, tanpa alat, level), favorit, dan pembuatan/pengeditan gerakan kustom + unggah media foto/video sendiri.
- Profil Lokasi (`Places`): simpan inventaris alat dan stok piringan barbel/beban per lokasi gym/rumah untuk menyaring latihan & menghitung kombinasi plate.

### 4.4 Rutinitas, Jadwal Mingguan & Rencana AI Offline
- CRUD rutinitas dengan folder warna, pengelompokan (program), superset chain, dan perencanaan detail per set (`PlannedSet`).
- Jadwal mingguan (Senin–Minggu) yang terhubung ke tombol Play utama dan pengingat latihan.
- 8 template program bawaan (Full Body, PPL, Upper/Lower, ABCD, ABCDE, StrongLifts, Starting Strength, Home).
- Berbagi & impor rutinitas dalam format JSON/CSV (termasuk menangkap intent `ACTION_VIEW` / `ACTION_SEND` di Android).
- Alur AI Routine offline: salin prompt + daftar latihan yang sesuai lokasi gym, tempel respons JSON dari AI eksternal, lalu pratinjau & impor otomatis menjadi rutinitas.

### 4.5 Analitik Progres & Pemulihan Otot
- Dashboard Progres: Volume 30 hari (+ delta % & sparkline), Berat badan terakhir, Heatmap konsistensi, Total seumur hidup, Peta Otot (7 hari / 30 hari / Recovery dengan model peluruhan eksponensial), Radar Otot, Grafik batang mingguan, Tren 1RM per gerakan, dan daftar Personal Records (PR).
- Check-in manual harian untuk menjaga streak di hari non-gym.
- Day Sheet: melihat, melanjutkan (resume), mengedit, atau menghapus sesi pada tanggal tertentu.

### 4.6 Pelacakan Tubuh, Foto Progres & Jurnal
- **Berat Badan:** Input berat badan via ruler picker, terhubung otomatis ke profil & kalkulator.
- **Ukuran Tubuh (Measures):** 10 metrik lingkar/komposisi tubuh dengan delta, sparkline, dan riwayat.
- **Timeline Foto Progres:** Foto multi-pose (`front`, `side`, `back`) per tanggal, pengingat foto berkala, dan halaman **Compare** (side-by-side dengan selisih hari & berat badan).
- **Moments:** Galeri foto kebugaran harian dengan tampilan grid/tanggal dan viewer layar penuh.
- **Jurnal / Notes:** Catatan harian atau terikat ke gerakan tertentu, dengan kategori (`NoteKind`), kalender, filter, dan lampiran multi-media.

### 4.7 Kalkulator, Gamifikasi & Berbagi
- **6 Kalkulator:** 1RM, BMI, Kalori/TDEE & Makro, Body Fat (US Navy), Plate Calculator (sesuai stok plate lokasi aktif), dan Warm-up Generator.
- **Gamifikasi:** 20 lencana pencapaian (`AwardId`) dengan progres, rak medali, dan animasi selebrasi (dapat dimatikan di pengaturan).
- **Share & Sticker:** Kartu share (Streak, Body, Compare) dan editor stiker 9:16 (foto/transparan, 6 layout, 6 warna, drag/scale/rotate, simpan ke galeri `Pictures/Scorpus`).

### 4.8 Ekosistem Android Native & Wear OS
- **5 Home Screen Widgets (Android):** Activity Heatmap, Stats, Body Map, Today, dan Week (dengan rollover otomatis tengah malam).
- **Notifikasi & Alarm:** Rest alarm (`loud`/`quiet`/`vibrate` + file audio kustom), pengingat latihan (fixed atau smart berbasis kebiasaan jam/hari latihan), dan pengingat foto progres.
- **Wear OS:** Aplikasi jam tangan mandiri (dark mode, crown rotary scroll, ambient dim, live workout logger, daftar rutinitas, pengaturan dasar).

### 4.9 Portabilitas Data (Backup & Import)
- Ekspor CSV (seluruh set latihan) dan Ekspor Backup ZIP (`scorpus.json` + seluruh media latihan, catatan, foto timeline, momen, dan file audio alarm).
- Impor Backup ZIP atau JSON.
- Impor riwayat latihan & berat badan dari aplikasi lain: Hevy, Strong, Lyfta, Fitbod, FitNotes (CSV & file database SQLite `.fitnotes` via pure-Dart reader), openGym JSON, dan CSV generik.

---

## 5. Kebutuhan Non-Fungsional (Non-Functional Requirements)

| Kategori | Requirement |
|---|---|
| **Performa** | Interaksi pencatatan set (< 16ms frame budget) harus tetap mulus meski riwayat mencapai 500+ sesi dan ratusan media. *(Catatan audit: saat ini seluruh state + base64 foto profil masih diserialisasi di 1 key `SharedPreferences` setiap edit — perlu migrasi storage).* |
| **Keamanan & Integritas Data** | Tidak boleh ada kehilangan data senyap (silent data loss) saat `save`, `load`, atau `restoreBackupZip`. Validasi path media saat ekstrak ZIP wajib mencegah path traversal. |
| **Privasi** | Seluruh data pribadi (foto tubuh, berat badan, riwayat latihan) tetap di perangkat pengguna secara default. Tidak ada telemetri atau analitik pihak ketiga. |
| **Keandalan Alarm** | Rest timer dan pengingat latihan harus tetap berbunyi meski aplikasi di background atau di-kill oleh OS (menggunakan exact alarm Android). |
| **Kompatibilitas** | Mendukung Android modern (termasuk API 36 `ProgressStyle` live notification dengan fallback `RemoteViews` untuk API < 36) serta Wear OS. |

---

## 6. Ringkasan Arsitektur Teknis

```text
lib/
├── main.dart               # Bootstrap: Store, MediaStore, AlarmStore, RestAlarm, Wear/Phone switch
├── app/                    # ScorpusApp (MaterialApp), AppShell (custom nav stack & liquid navbar)
├── catalog/                # Data statis: 552 exercises, aliases, 8 templates, 20 awards, body SVG
├── models/                 # Immutable/mutable domain models + JSON serialization
├── state/                  # FitState (single ChangeNotifier) dengan 12 mixin domain
├── services/               # LocalStore, MediaStore, AlarmStore, BackupZip, Importers, Alarms, Bridges
├── screens/                # 28 layar & bottom sheets UI
├── widgets/                # Komponen reusable, charts, BodyMap, GlassSurface, Shaders
├── wear/                   # WearApp & WearShell (standalone Wear OS)
└── l10n/                   # Lokalisasi (ARB)

android/app/src/main/kotlin/com/dalvero/scorpus/
├── MainActivity.kt         # MethodChannels: incoming, gallery, haptics, screen, device, rotary, live
├── LiveNotifier.kt         # Ongoing workout notification (API 36 ProgressStyle + legacy RemoteViews)
└── *WidgetProvider.kt      # 5 Android Home Widgets + midnight rollover receiver
```

---

## 7. Batasan & Risiko Saat Ini

1. **Penyimpanan Monolitik di `SharedPreferences`:** Seluruh data termasuk base64 foto profil & banner ditulis ulang sebagai satu string JSON di `scorpus_v1`. Berisiko lag saat data membesar dan rawan korup/kehilangan data jika proses terputus.
2. **Belum Ada Version Control (`.git`):** Folder proyek belum diinisialisasi sebagai repositori Git, sehingga perubahan kode sulit dilacak atau di-rollback.
3. **Kesenjangan Fitur Kardio/Lari & Wearable:** Deskripsi aplikasi mencakup *running*, namun saat ini hanya mendukung input jarak/waktu manual (belum ada sinkronisasi SmartBand/Health Connect, GPS, pace, atau detak jantung).
4. **Celah Validasi & Bug Minor:** Ditemukan beberapa bug fungsional (misalnya edit set lama menghapus RPE/jenis set, rest alarm tidak terjadwal ulang saat cold-start, path traversal pada restore ZIP) yang perlu ditangani sebelum pengembangan fitur besar.
