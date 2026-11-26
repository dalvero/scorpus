# Daftar Fitur Scorpus (`FEATURES.md`)

Dokumen ini memetakan seluruh fitur di codebase **Scorpus** menjadi tiga kategori:
1. **Fitur yang Sudah Ada & Berfungsi Penuh**
2. **Fitur Parsial / Semi-Statis / Celah UI & Implementasi**
3. **Potensi Fitur Baru untuk Pengembangan ke Depan**

---

## 1. Fitur yang Sudah Ada & Berfungsi Penuh

Hasil audit seluruh `lib/screens/`, `lib/state/`, `lib/services/`, `lib/wear/`, dan `android/` menunjukkan aplikasi ini **bukan template kosong atau mockup**. Hampir seluruh layar sudah terhubung penuh ke `FitState` dan penyimpanan lokal.

### A. Onboarding, Profil & Pengaturan
- **Onboarding 6 Langkah (`onboarding_screen.dart`):** Pengaturan nama, unit (`kg`/`lb`), tinggi/berat/usia/sex (via ruler picker), target latihan mingguan (1–7 hari), dan lokasi latihan beserta preset peralatan.
- **Halaman Profil (`profile_screen.dart`):** Banner foto yang bisa diganti, avatar, nama & handle, level atlet otomatis, statistik kumulatif seumur hidup, rak medali (`MedalShelf`), pratinjau cepat Moments, dan grafik aktivitas 12 bulan terakhir.
- **Pengaturan Lengkap (`settings_screen.dart`):**
  - Tema (`Auto`/`Dark`/`Light`), bahasa, unit (`kg`/`lb`), pola latar belakang + foto kustom + tingkat dim.
  - Rest timer default, file audio alarm kustom (dengan pratinjau & reset), gaya alarm (`Loud`/`Quiet`/`Vibrate`), peringatan izin notifikasi.
  - Pengingat latihan harian: mode **Fixed** (jam tetap) atau **Smart** (otomatis mendeteksi hari & jam latihan kebiasaan pengguna).
  - Toggle pengalaman latihan: Focus Card, Effort Mode (`Off`/`RPE`/`RIR`), Auto-Advance, Start Countdown (5 detik), Keep Screen On, Gamification, ukuran demo latihan (`Large`/`Small`/`Off`).

### B. Pencatatan Latihan (Workout Engine)
- **Home Dashboard (`home_screen.dart`):** Tanggal & streak counter, kartu Hero (rutinitas hari ini atau fokus otot yang disarankan otomatis), strip 7 hari (session & manual check-in), ringkasan target mingguan (`GoalRing`), heatmap aktivitas interaktif, rekomendasi latihan, pengingat foto progres jika jatuh tempo, dan pintasan folder (Routines, Tools, Journal).
- **Workout Builder 2 Langkah (`train_screen.dart`, `start_sheet.dart`):**
  - Pilih otot langsung pada ilustrasi tubuh (`BodyMap`), lalu review daftar gerakan yang otomatis dipilihkan (memprioritaskan favorit & riwayat).
  - Pencarian, filter peralatan, sembunyikan gerakan dari saran (long-press), buat gerakan baru langsung, atau log latihan untuk tanggal lampau (backdate).
- **Live & Manual Session (`session_screen.dart`):**
  - Timer durasi berjalan, pause/resume, pocket-lock (tahan untuk buka), overview sesi (lompat & ubah urutan gerakan).
  - Mendukung 4 mode latihan: `Weight × Reps`, `Reps Only`, `Time` (dengan hold timer & beep), dan `Cardio` (jarak & waktu).
  - Jenis set (`Normal`, `Warmup`, `Drop`, `Failure`, `Rest-Pause`), input `RPE`/`RIR`, auto-warmup, dan target progressive overload otomatis berdasarkan sesi terakhir.
  - Superset chaining antar gerakan, swipe-to-delete set (dengan undo), kalkulator plate langsung dari baris set, tambah catatan/gerakan di tengah sesi.
  - **Ringkasan Pasca-Latihan:** Statistik total, perbandingan % dengan sesi sebelumnya, konfeti, simpan sesi sebagai rutinitas baru, dan tombol langsung ke Share/Sticker.

### C. Katalog Latihan, Rutinitas & AI Prompt Workflow
- **Katalog 552 Latihan (`exercises_screen.dart`, `exercise_detail_screen.dart`):**
  - 552 gerakan tervalidasi (0 duplikat) dengan ilustrasi vektor dinamis (`assets/art/`), otot primer/sekunder, alat, tingkat kesulitan, dan panduan langkah.
  - Pencarian cepat, filter (lokasi, otot, alat, tanpa alat, level), favorit, serta CRUD gerakan kustom lengkap dengan unggah foto/video demo sendiri.
  - Detail gerakan: override mode (`weight`/`time`/`cardio`), reps-only, custom rest timer, auto-progress step, auto-warmup, stopwatch bawaan, grafik tren 1RM, PR, riwayat 8 sesi terakhir, tautan catatan, serta alternatif gerakan jika alat tidak tersedia di lokasi gym aktif.
- **Rutinitas & Jadwal Mingguan (`routines_screen.dart`, `routine_edit_screen.dart`):**
  - Jadwal mingguan (Senin–Minggu), folder rutinitas berwarna & terkelompok, 8 template program bawaan (`Full Body`, `PPL`, `Upper/Lower`, `ABCD`, `ABCDE`, `StrongLifts`, `Starting Strength`, `Home`).
  - Editor rutinitas lengkap: ubah urutan gerakan, superset chain, jumlah set, dan perencana detail per set (`PlannedSet`).
- **AI Routine Offline (`ai_plan_screen.dart`, `plan_import_sheet.dart`):**
  - Menyalin atau mengekspor prompt terstruktur berisi daftar gerakan yang sesuai lokasi gym aktif untuk diberikan ke AI eksternal (ChatGPT/Gemini/Claude).
  - Menempel/mengimpor balasan JSON (termasuk format multi-minggu), memvalidasi & mencocokkan gerakan otomatis, lalu membuat rutinitas & jadwal mingguan.
  - Mendukung Android Share Intent (`ACTION_VIEW` / `ACTION_SEND`) untuk mengimpor file/teks rencana dari aplikasi lain.

### D. Analitik Progres, Pelacakan Tubuh & Jurnal
- **Progress Dashboard (`progress_screen.dart`):** Volume 30 hari (+ % perubahan & sparkline), berat badan terakhir, heatmap konsistensi (dengan pilihan warna tema panas), total seumur hidup, Peta Otot (`7d`, `30d`, dan `Recovery` berbasis peluruhan eksponensial), `MuscleRadarCard`, grafik batang mingguan, grafik tren 1RM per gerakan, daftar PR, dan Day Sheet untuk melihat/melanjutkan/menghapus sesi per tanggal.
- **Ukuran Tubuh (`measures_screen.dart`):** 10 metrik tubuh dengan nilai terbaru, delta, sparkline, input ruler/keyboard, serta riwayat & hapus data.
- **Timeline Foto & Compare (`timeline_screen.dart`, `compare_screen.dart`):** Foto progres per tanggal (pose `front`/`side`/`back`), pengingat berkala, mode timeline peta otot, dan layar perbandingan side-by-side lengkap dengan selisih hari & berat badan.
- **Moments (`moments_screen.dart`):** Galeri foto kebugaran (tampilan grid 3 kolom atau dikelompokkan per tanggal) dengan viewer layar penuh.
- **Training Journal (`notes_screen.dart`, `note_edit_screen.dart`):** Catatan umum atau per gerakan, kalender dengan indikator tipe catatan, filter tipe, lampiran multi-foto/video, dan pembersihan file media otomatis saat dibatalkan/dihapus.

### E. Alat Bantu, Gamifikasi, Lokasi & Data Portability
- **6 Kalkulator (`tools_screen.dart`, `tool_detail_screen.dart`):** 1RM, BMI, Kalori/TDEE & Makro, Body Fat (US Navy), Plate Calculator, dan Warm-up Generator.
- **Lokasi Gym / Places (`places_screen.dart`):** Manajemen beberapa lokasi (Gym, Rumah, Outdoor) dengan daftar alat tersedia dan stok plate/barbel masing-masing.
- **Gamifikasi (`awards_screen.dart`):** 20 medali pencapaian dengan pelacakan progres dan animasi selebrasi saat terbuka.
- **Share Cards & Sticker Editor (`share_sheet.dart`, `sticker_screen.dart`):** Render PNG resolusi tinggi (3×) untuk Streak/Body/Compare, plus editor stiker 9:16 (foto/transparan, 6 layout, 6 warna, drag/scale/rotate, simpan ke `Pictures/Scorpus`).
- **Backup & Multi-App Import (`backup_zip.dart`, `workout_import.dart`, `fitnotes_backup.dart`, `sqlite_reader.dart`):**
  - Export/Import ZIP lengkap (JSON + semua media + alarm audio) dan Export CSV.
  - Impor riwayat dari **Hevy, Strong, Lyfta, Fitbod, FitNotes (CSV & `.fitnotes` SQLite via parser Dart murni), openGym JSON, dan CSV generik**.

### F. Fitur Android Native & Wear OS
- **5 Android Home Widgets:** Heatmap, Stats, Body Map, Today, dan Week (otomatis rollover tengah malam tanpa membuka aplikasi).
- **Live Workout Notification (`LiveNotifier.kt`):** Notifikasi sesi aktif dengan tombol aksi (`Done`, `Pause`, `+15s`, `Skip`, `Next`), mendukung Android 16 (`ProgressStyle`) dan fallback `RemoteViews` untuk Android lama.
- **Wear OS Standalone (`wear_app.dart`, `wear_shell.dart`):** Aplikasi jam tangan mandiri dengan dukungan crown scroll, ambient dim, ringkasan mingguan, daftar rutinitas, dan pencatat sesi lengkap.

---

## 2. Fitur Parsial, Semi-Statis, atau Memiliki Celah UI

Tidak ditemukan layar "dummy / coming soon" murni di codebase ini. Namun, audit menemukan **8 area yang masih parsial, tidak lengkap secara UI, atau bersifat statis/manual** dan sangat layak diperbaiki:

| # | Area / Fitur | Lokasi Code | Kondisi Saat Ini (Celah / Keterbatasan) | Potensi Perbaikan |
|---|---|---|---|---|
| 1 | **Riwayat & Hapus Berat Badan** | `lib/screens/progress_screen.dart:686-706` | Fungsi UI `bwRow()` untuk menampilkan & menghapus entri berat badan lama sudah ditulis tetapi **tidak pernah dipanggil (dead code)**. User hanya bisa menambah berat badan baru, tidak bisa melihat/menghapus riwayat salah ketik. | Hubungkan `bwRow()` ke sheet/layar riwayat berat badan. |
| 2 | **Edit Sesi Kardio & Time di Day Sheet** | `lib/screens/progress_screen.dart:1417, 1638-1703` | Sesi `cardio` (lari) dan `time` (plank) tampil sebagai `0×0` di Day Sheet, dan form edit (`showEditLoggedSheet`) hanya menyediakan stepper Reps & Weight. | Tampilkan `fit.setsSummary(e.sets)` dan tambahkan input durasi/jarak saat mengedit sesi kardio/time. |
| 3 | **Kalkulator Body Fat (US Navy)** | `lib/screens/tool_detail_screen.dart:137-146` | Tidak ada tombol pilih jenis kelamin (`bfSex`) di UI kalkulator meski state-nya mendukung; input `Hip` selalu tampil untuk pria padahal tidak berpengaruh ke perhitungan pria. | Tambah `SegToggle` Male/Female dan sembunyikan `Hip` untuk Male. |
| 4 | **Pelacakan Lari & Kardio** | `README.md`, `lib/state/workout_state.dart` | Deskripsi menyebut *"running tracker"*, tetapi fitur lari saat ini baru sebatas input manual jarak & durasi. Belum ada GPS, pace/split per km, detak jantung, atau sinkronisasi wearable. | Integrasikan **Android Health Connect** (tarik data lari & HR dari Huawei SmartBand) atau tambah ringkasan pace/split otomatis. |
| 5 | **AI Routine Workflow** | `lib/screens/ai_plan_screen.dart` | Berfungsi nyata, tetapi masih **semi-manual** (copy prompt -> buka app AI lain -> paste balik JSON). | Pertahankan mode offline ini, dan opsional tambah integrasi API Gemini/BYOK (Bring Your Own Key) jika diinginkan. |
| 6 | **Wear OS Sync & Routine CRUD** | `lib/wear/wear_shell.dart` | Aplikasi Wear OS bekerja **100% standalone** (data terpisah di jam tangan, tidak sinkron ke HP). Setelah ada ≥1 rutinitas, jam tangan juga tidak bisa membuat/mengedit rutinitas baru. | Jika tidak memakai jam Wear OS (karena memakai Huawei SmartBand), modul ini bisa dibiarkan atau dipangkas untuk meringankan APK. |
| 7 | **Home Widgets di iOS** | `lib/screens/settings_screen.dart:264` | Menu pin 5 Home Widgets tampil di iOS, tetapi implementasinya hanya memanggil Android `qualifiedAndroidName` sehingga selalu gagal di iOS. | Batasi tampilan menu hanya untuk `Platform.isAndroid`. |
| 8 | **About Screen & Versi App** | `lib/screens/about_screen.dart:12` | `_kVersion = '1.0.0'` di-hardcode statis dan tidak otomatis mengikuti `pubspec.yaml`. | Biarkan sederhana atau sinkronkan saat rilis versi baru. |

---

## 3. Potensi Fitur Baru untuk Dikembangkan

Diurutkan berdasarkan nilai guna tertinggi untuk pemakaian pribadi (gym + lari + Huawei SmartBand):

### Prioritas Tinggi (Berdampak Langsung ke Pemakaian Harian)
1. **Integrasi Wearable & Kesehatan (Android Health Connect -> Huawei SmartBand):**
   - Tarik data harian dari Huawei SmartBand (melalui jembatan **Health Sync** atau **Gadgetbridge** -> **Android Health Connect**): langkah harian (steps), detak jantung istirahat (RHR), tidur (sleep duration), kalori aktif, berat badan, dan sesi lari/olahraga otomatis.
   - Tampilkan kartu ringkasan *Daily Health / Recovery* di Home & Progress (menghubungkan data tidur/RHR dengan kesiapan latihan gym).
2. **Peningkatan Modul Running & Cardio:**
   - Kalkulasi otomatis **Pace (min/km)** dan **Speed (km/h)** di layar sesi, riwayat, dan grafik progres kardio.
   - Rekor pribadi khusus lari (Best 1K, 5K, 10K, Longest Run, Weekly Mileage).
   - Impor file latihan `.gpx` / `.tcx` jika diperlukan.
3. **Auto-Backup Aman (Tanpa Bikin Server Sendiri):**
   - Jadwal backup ZIP otomatis ke folder lokal pilihan pengguna (Android SAF — misalnya folder yang tersinkronisasi dengan Google Drive / Syncthing / OneDrive) agar data aman jika HP rusak/hilang.

### Prioritas Menengah (Kualitas Hidup & Analitik)
4. **Analitik Progres Lebih Dalam:**
   - Grafik perbandingan volume per kelompok otot per minggu (deteksi *junk volume* atau *under-trained muscles*).
   - Estimasi *Readiness Score* sederhana berbasis kombinasi recovery otot (sudah ada) + durasi tidur & RHR dari Health Connect.
5. **Peningkatan UX Gym:**
   - Catatan singkat per gerakan yang langsung terlihat saat sesi aktif (*pinned cue*, misalnya "kursi nomor 4, grip selebar bahu").
   - Timer istirahat otomatis berbeda untuk compound vs isolation atau saat RPE tinggi.

### Prioritas Rendah / Opsional (Hanya Jika Dibutuhkan)
6. **Direct AI Coach (BYOK — Bring Your Own API Key):**
   - Opsional memasukkan API key Gemini sendiri di Settings untuk langsung generate/evaluasi program latihan di dalam `AiPlanScreen` tanpa copy-paste manual.
7. **Pembersihan Modul Tidak Terpakai:**
   - Jika 100% hanya dipakai di Android Phone + Huawei SmartBand (bukan Wear OS dan bukan iOS), kode Wear OS (`lib/wear/`) dapat dievaluasi untuk dipertahankan atau diarsipkan agar maintenance lebih ringan.
