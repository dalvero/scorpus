# Rencana Pengembangan Scorpus (`DEVELOPMENT.md`)

> **Catatan:** Dokumen ini adalah draf awal rencana pengembangan berdasarkan hasil audit penuh codebase dan riset integrasi Huawei Health Kit. Seluruh keputusan arsitektur di sini disusun dari sudut pandang **aplikasi pemakaian pribadi (personal use)** yang pragmatis (minim over-engineering, maksimal manfaat) dan siap didiskusikan lebih lanjut.

---

## 1. Keputusan Arsitektur: Perlukah Online, Database Online, dan Login/Register?

### Jawaban Singkat: **TIDAK PERLU (Tetap Offline-First).**

Untuk aplikasi yang kamu kembangkan dan pakai sendiri, menambahkan backend online, database cloud, dan sistem login/register **justru akan memperlambat pengembangan dan merusak keunggulan utama Scorpus**.

| Aspek | Offline-First (Rekomendasi) | Full Online (Backend + DB + Auth) |
|---|---|---|
| **Kecepatan di Gym** | Instan (0ms latency), tetap jalan di gym basement tanpa sinyal | Bergantung sinyal, butuh sync queue & conflict resolution |
| **Biaya & Maintenance** | Rp 0 selamanya, tidak ada server/API yang perlu dijaga | Biaya hosting/DB (atau rawan kena limit free-tier/sleep), token expired, migrasi API |
| **Login / Register** | Tidak perlu — buka aplikasi langsung pakai | Boilerplate auth, lupa password, refresh token, keamanan endpoint |
| **Privasi Data** | 100% di HP sendiri (termasuk foto progres tubuh) | Foto & data kesehatan tersimpan di server pihak ketiga |
| **Risiko Hilang Data** | Teratasi dengan **Auto-Backup ZIP ke Cloud Storage / SAF** | Teratasi oleh server, tapi tetap butuh backup |

### Rekomendasi Konkret Pengganti "Online DB + Login"
1. **Perbaiki Penyimpanan Lokal (Local DB):**
   - Saat ini Scorpus menaruh seluruh state + base64 foto profil ke **satu key `SharedPreferences` (`scorpus_v1`)**. Untuk jangka panjang (1–3 tahun data + data SmartBand), ini rawan lambat dan korup.
   - **Solusi:** Pindahkan foto profil/banner ke `MediaStore` (file biasa), lalu migrasikan penyimpanan utama ke **SQLite lokal (`sqflite` / `drift`)** atau minimal **atomic JSON file write** (`scorpus.json.tmp` -> rename) agar aman dari korup.
2. **Backup Otomatis Tanpa Server:**
   - Tambahkan fitur **Auto-Backup ZIP terjadwal** ke folder lokal (Android SAF) atau langsung ke **Google Drive AppData** (cukup Google Sign-In opsional khusus tombol backup, bukan login wajib).
   - Alternatif paling malas & gratis: ekspor otomatis ke folder lokal yang sudah disinkronkan oleh aplikasi seperti **Syncthing** atau **DriveSync**.
3. **Kapan baru perlu Backend + Login/Register?**
   - Hanya jika suatu hari kamu memutuskan membuka Scorpus untuk **banyak pengguna publik**, butuh **web dashboard**, atau butuh fitur **sosial/leaderboard**.

---

## 2. Riset & Analisis: Integrasi Huawei Health Kit (SmartBand Huawei)

Kamu memiliki **Huawei SmartBand** dan ingin menarik datanya ke Scorpus. Berikut hasil riset kebijakan **Huawei Health Kit (HMS Core)** terbaru:

### Apakah Huawei Health Kit Gratis?
- **Ya, secara biaya lisensi gratis** dalam kuota ekosistem Huawei Developer.

### Apakah Memungkinkan untuk Developer Pribadi (Personal App)?
- **Secara langsung: SANGAT SULIT / PRAKTIS TERBLOKIR** karena 3 batasan resmi Huawei:
  1. **Wajib Rilis di Huawei AppGallery:** Untuk akun *Individual Developer*, Huawei mensyaratkan aplikasi **sudah resmi dipublikasikan di Huawei AppGallery**. Aplikasi pribadi (sideload APK / belum rilis) umumnya ditolak saat pengajuan akses Health Kit.
  2. **Pembatasan Data (Basic vs Advanced Openness):**
     - Akun **Individual** hanya bisa mengakses **Basic Openness Level** (langkah, kalori, jarak, tinggi/berat).
     - Data kunci SmartBand seperti **Heart Rate, Sleep, SpO2, Stress, dan detail Workout** masuk **Advanced Openness Level** yang **khusus akun Enterprise** (wajib verifikasi badan usaha/perusahaan).
  3. **REST API (Cloud):** Akses cloud server-to-server juga membutuhkan verifikasi bisnis & dokumen privasi ketat — tidak realistis untuk proyek personal tanpa badan hukum.

### Solusi Alternatif yang REALISTIS & Bisa Berjalan Penuh

Alih-alih bertarung melawan birokrasi akun Enterprise Huawei, jalur terbaik adalah menjadikan **Android Health Connect** sebagai lapisan integrasi di Scorpus:

```text
[Huawei SmartBand]
        │
        ▼ (Bluetooth)
[Huawei Health App] ──► [Health Sync App] ──► [Android Health Connect (OS)] ◄── [Scorpus]
        (ATAU jika band support)
[Huawei SmartBand] ──► [Gadgetbridge (OSS)] ─► [Android Health Connect (OS)] ◄── [Scorpus]
```

#### Perbandingan Opsi Integrasi

| Opsi | Biaya | Data yang Didapat | Kelebihan | Kekurangan |
|---|---|---|---|---|
| **1. Scorpus ↔ Android Health Connect + Health Sync** *(Rekomendasi Utama)* | Health Connect **Gratis**. Health Sync ~Rp30rb–50rb (sekali bayar setelah trial) | Steps, Heart Rate, Sleep, Calories, Weight, Workouts (termasuk Lari) | Tidak butuh akun Enterprise, tidak perlu rilis di Play Store/AppGallery untuk dipakai sendiri, **future-proof** (ganti jam ke Garmin/Samsung/Xiaomi tetap jalan!) | Butuh aplikasi jembatan `Health Sync` di HP Android |
| **2. Scorpus ↔ Android Health Connect + Gadgetbridge** | **100% Gratis & Open Source** | Steps, Heart Rate, Sleep, Workouts (tergantung model band) | 100% offline & privasi maksimal, tanpa aplikasi Huawei Health | Hanya mendukung model Huawei Band tertentu; fitur watchface/GPS resmi Huawei mungkin berkurang |
| **3. Huawei Health Kit SDK Langsung** | Gratis, tapi butuh Enterprise | Hanya Steps/Calories untuk akun Individual | Koneksi langsung tanpa jembatan | Wajib rilis AppGallery, HR/Sleep/SpO2 terkunci untuk Enterprise |

#### Kenapa Android Health Connect di Scorpus Sangat Cocok?
- Di Android 14+, **Health Connect sudah bawaan OS** (dan tersedia di Play Store untuk Android 9–13).
- Untuk pemakaian pribadi (debug/release APK yang di-install langsung di HP sendiri), kamu **tidak perlu lolos review Google Play Console** untuk meminta izin baca/tulis Health Connect di perangkatmu sendiri.
- Di Flutter tersedia package matang `health` (atau MethodChannel tipis langsung ke Android `androidx.health.connect:connect-client` agar lebih ringan & minim dependency).
- **Tetap 100% Offline:** Health Connect menyimpan data secara lokal di perangkat Android, sehingga Scorpus **tetap tidak membutuhkan izin `INTERNET`**!

---

## 3. Roadmap Pengembangan Bertahap

### Fase 0 — Fondasi & Stabilisasi (Estimasi: 2–3 hari)
Tujuan: Memastikan codebase aman, bersih, dan bebas bug kehilangan data sebelum menambah fitur baru.
1. **Inisialisasi Git** (`git init`, commit awal sebagai baseline bersih).
2. **Perbaiki Bug Kritis dari `/ponytail-review`:**
   - Perbaiki `setLoggedReps`/`setLoggedWeight` agar tidak menghapus `rpe`, `kind`, `sec`, `km`.
   - Urutkan `RestAlarm.instance.init()` sebelum `fit.loadFromStore()` di `main.dart` agar alarm sesi aktif tetap jalan setelah cold-start.
   - Perbaiki `backup_zip.dart` & `applyBackup`: validasi sebelum `MediaStore.clearAll()`, bungkus `_loading` dengan `try/finally`, dan sanitasi path ZIP (anti path traversal).
   - Perbaiki `local_store.dart`: jangan telan error `save()` diam-diam; simpan backup raw JSON jika `load()` gagal parse.
   - Perbaiki `exercise_detail_screen.dart` (stale `_exId`), `progress_screen.dart` (label chart minggu di locale Sunday-first), dan `MainActivity.kt` (batas baca stream sebelum alokasi RAM).
3. **Optimasi Storage Tahap 1:** Pindahkan base64 `profile.photo` & `profile.banner` ke `MediaStore` agar `SharedPreferences` tidak membengkak.

### Fase 1 — Lengkapi Celah Fitur yang Sudah Ada (Estimasi: 2–3 hari)
Tujuan: Menutup kekurangan UX pada fitur yang sebenarnya sudah setengah jadi.
1. Aktifkan UI riwayat & hapus berat badan (hubungkan `bwRow()` di `progress_screen.dart`).
2. Perbaiki tampilan & edit sesi `cardio`/`time` di Day Sheet (hilangkan tampilan `0×0`).
3. Tambahkan toggle jenis kelamin di kalkulator Body Fat (`tool_detail_screen.dart`) dan sembunyikan input `Hip` untuk pria.
4. Perbaiki `prsThisWeek` agar tidak menghitung set warmup, perbaiki error toast di Settings (ikon merah/kuning bukan centang hijau), dan tambahkan konfirmasi hapus pada custom exercise.

### Fase 2 — Integrasi SmartBand via Android Health Connect (Estimasi: 4–6 hari)
Tujuan: Membawa data Huawei SmartBand masuk otomatis ke Scorpus tanpa internet/server.
1. Verifikasi di HP kamu: uji sinkronisasi **Huawei SmartBand -> Huawei Health -> Health Sync -> Android Health Connect** (atau cek dukungan model band kamu di **Gadgetbridge**).
2. Buat service `HealthConnectService` (Android Kotlin MethodChannel atau plugin `health`) untuk **membaca**:
   - Daily Steps & Active Calories
   - Resting Heart Rate & Heart Rate samples
   - Sleep Duration
   - Running / Cardio Exercise Sessions (jarak, durasi, kalori, rata-rata HR)
   - Bodyweight (jika juga dicatat di ekosistem lain)
3. Tambahkan pengaturan koneksi Health Connect di `SettingsScreen` (izin, tombol Sync Now, auto-sync saat app dibuka).
4. Tampilkan kartu ringkasan **Daily Health (Steps, Sleep, RHR)** di `HomeScreen` dan hubungkan sesi lari yang diimpor ke riwayat Scorpus (dengan deduplikasi berdasarkan timestamp agar tidak dobel).

### Fase 3 — Upgrade Fitur Running & Kardio (Estimasi: 3–5 hari)
Tujuan: Membuat Scorpus benar-benar seimbang untuk **Gym + Running**.
1. Kalkulasi otomatis **Pace (min/km)** & **Speed** untuk semua sesi kardio (baik input manual maupun hasil sync SmartBand).
2. Grafik tren kardio di `ProgressScreen`: jarak mingguan (Weekly Mileage), tren pace, dan PR lari (1K / 5K / 10K / Longest Run).
3. Opsional: tampilan **Readiness / Recovery** gabungan (pemulihan otot + kualitas tidur & RHR dari SmartBand).

### Fase 4 — Keandalan Jangka Panjang & Migrasi DB (Opsional, Estimasi: 3–5 hari)
Tujuan: Menjaga performa untuk pemakaian bertahun-tahun.
1. Migrasi penyimpanan dari `SharedPreferences` ke **file JSON atomik** atau **SQLite lokal** jika ukuran data sudah besar.
2. Tambah **Auto-Backup ZIP** ke folder lokal pilihan pengguna (Android SAF) setiap minggu atau setelah X sesi.
3. Evaluasi pemangkasan kode yang tidak dipakai (misal `lib/wear/` jika tidak memakai jam Wear OS, atau tetap simpan jika sewaktu-waktu dipakai).

---

## 4. Keputusan yang Sudah Disepakati

1. **Wearable:** **Huawei SmartBand 11** -> karena seri baru, jalur integrasi Fase 2 dikunci ke **Huawei Health -> Health Sync -> Android Health Connect -> Scorpus**.
2. **Arsitektur & Platform:** **100% Offline-First + Auto-Backup** (tanpa backend online / login-register), fokus penuh di **Android Phone**.
3. **Alur Rilis:** Fase 0 (bug kritis & keamanan data) selesai -> integrasi **Shorebird** -> build APK untuk instalasi di ponsel pribadi.
