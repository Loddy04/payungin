# Payungin: Product Backlog dan Product Backlog Item

**Studi Kasus:** Aplikasi Mobile Pemantau dan Pengingat Cuaca (Praktikum Pemrograman Aplikasi Mobile)

**Metodologi:** Scrum Framework

**Disusun oleh:** Loddy dan Salsabila

> Dokumen ini hanya memuat Product Backlog, PBI, dan rencana sprint. Kebutuhan fitur (FR), perancangan, kontrak integrasi, dan rencana pengujian ada di dokumen terpisah: *Payungin: Dokumen Final Perancangan dan Panduan Pengembangan* (selanjutnya disebut Dokumen Final). Semua status PBI berstatus To Do dan diperbarui seiring sprint berjalan.

## Daftar Isi

1. Pendahuluan
2. Product Backlog
3. Product Backlog Item (PBI) per Sprint
4. Ringkasan Sprint Plan
5. Matriks Kepatuhan terhadap Materi Praktikum
6. Risiko dan Hal yang Perlu Disepakati
7. Pembagian Tugas, Jadwal Presentasi, dan Ceklis Laporan

## 1. Pendahuluan

### 1.1 Tujuan Dokumen

Dokumen ini menyusun Product Backlog Payungin dari Dokumen Final, merinci setiap backlog menjadi Product Backlog Item (PBI), lalu memetakannya ke 7 sprint yang sama dengan jadwal kerja Hari 1 sampai Hari 7 pada Bagian 17 Dokumen Final. **Urutan pengerjaan dan pembagian tugas Loddy dan Salsabila mengikuti Dokumen Final tanpa perubahan.** Presentasi dijadwalkan pada **Kamis, 26 November 2026**, sehingga seluruh sprint harus selesai sebelum tanggal itu. Setiap backlog merujuk ke kode fitur (F1 sampai F9, F14, F15, F16) dan bagian pada Dokumen Final.

### 1.2 Ringkasan Produk

Payungin adalah aplikasi mobile Flutter (Android) yang menjawab satu pertanyaan sehari-hari: **Hari ini perlu bawa payung atau tidak?** Aplikasi mengambil cuaca dari internet (Open-Meteo, tanpa API key), mengolahnya menjadi **Skor Payung** (0 sampai 100) dan saran singkat, menampilkan cuaca di posisi pengguna lewat GPS, lalu mengingatkan lewat notifikasi lokal. Data pribadi (sesi, pengaturan, kota favorit, pengingat, perlengkapan) disimpan di perangkat lewat Shared Preferences dan Hive.

| Item | Keterangan |
| --- | --- |
| Platform | Flutter (Android) |
| Data online | Open-Meteo Forecast dan Open-Meteo Geocoding |
| Data lokal | Shared Preferences (sesi, pengaturan), Hive (data utama) |
| Sensor dan sistem | GPS (`geolocator`), notifikasi lokal (`flutter_local_notifications`) |
| State dan navigasi | `setState` (StatefulWidget) dan `Navigator`, sesuai materi |
| Cakupan materi | OOP, Modul II (Widget), III (State dan Data), IV (Navigation), V (HTTP Request), VI (Local Storage), VII (Notification dan LBS) |
| Jumlah fitur | 12 FR (F1 sampai F9, F14, F15, F16), masing-masing anggota memegang 6 |
| Repository | https://github.com/Loddy04/payungin.git |

### 1.3 Peran Tim

| PIC | Anggota | Peran |
| --- | --- | --- |
| A1 | Loddy | Data cuaca dan LBS: API, model dan logika cuaca, GPS, cache |
| A2 | Salsabila | Akun, data lokal, dan notifikasi: login, navigasi utama, Hive, Shared Preferences, notifikasi |

## 2. Product Backlog

### 2.1 Prinsip Penyusunan

Product Backlog ditulis sebagai User Story: *Sebagai \[peran\], saya ingin \[fitur\] agar \[manfaat\]*. Estimasi memakai Story Point skala Fibonacci (1, 2, 3, 5, 8, 13). Satu sprint sama dengan satu hari kerja pada jadwal Bagian 17 Dokumen Final (Hari 1 sampai Hari 7) dan memuat 1 sampai 2 Product Backlog. Total ada **12 Product Backlog dalam 7 sprint**.

Isi tiap sprint, urutan fitur, dan pembagian tugas Loddy dan Salsabila **disalin dari Bagian 17 Dokumen Final tanpa perubahan**. Dokumen ini hanya merinci jadwal itu menjadi PBI. Aturan yang dipakai:

- Pada hari ketika Loddy dan Salsabila bekerja paralel, tiap jalur menjadi satu Product Backlog.
- Kolom Referensi menunjuk ke kode fitur (F1 sampai F16) dan bagian pada Dokumen Final.
- Jenis fitur mengikuti Bagian 5: Inti, Tambahan (F14), dan bagian yang ditandai Opsional di Bagian 17 (banner ekstrem).
- Nomor F10 sampai F13 tidak dipakai (Bagian 5 dan 15 Dokumen Final).

### 2.2 Daftar Product Backlog

| ID | Sprint | Modul | User Story | Prioritas | SP | Referensi (Dokumen Final) |
| --- | --- | --- | --- | --- | --- | --- |
| PB-01 | 1 | Fondasi Proyek, Login, dan Kerangka Navigasi | Sebagai tim pengembang, kami ingin project, data lokal dasar, login dengan sesi otomatis, dan kerangka lima tab siap agar kedua anggota dapat bekerja paralel tanpa saling menunggu atau bentrok. | Tinggi | 13 | F1, F8 (Root), Bagian 8 sampai 12 |
| PB-02 | 1 | Data Cuaca Dasar | Sebagai tim, kami ingin respons API cuaca dan geocoding sudah terbukti dan terbaca ke model agar fitur cuaca dibangun di atas data nyata. | Tinggi | 5 | Bagian 4 dan 7 |
| PB-03 | 2 | Beranda Cuaca, Skor Payung, dan Saran | Sebagai pengguna, saya ingin melihat cuaca kota utama beserta Skor Payung dan saran singkat agar tahu perlu membawa payung atau tidak tanpa membaca angka. | Tinggi | 8 | F2, F9 |
| PB-04 | 2 | Kota Favorit, Profil, dan Pengaturan | Sebagai pengguna, saya ingin menyimpan kota favorit, mengatur satuan suhu dan kota utama, serta keluar akun agar aplikasi sesuai kebiasaan saya. | Tinggi | 8 | F5, F8 |
| PB-05 | 3 | Detail Cuaca dan Cari Kota | Sebagai pengguna, saya ingin melihat prakiraan per jam dan 7 hari serta mencari kota mana pun agar bisa memantau cuaca di luar kota utama. | Tinggi | 8 | F3, F4 |
| PB-06 | 3 | Pengingat Cuaca | Sebagai pengguna, saya ingin membuat, mengubah, dan menghapus pengingat cuaca beserta status payungnya agar saya selalu siap. | Tinggi | 8 | F6 |
| PB-07 | 4 | Cache Offline dan Lokasi Saya (Tahap 1) | Sebagai pengguna, saya ingin tetap melihat cuaca terakhir saat offline dan melihat cuaca di posisi saya agar tidak perlu mengetik nama kota. | Tinggi | 8 | F14, F15 langkah 1 sampai 2 |
| PB-08 | 4 | Perlengkapan Hujan dan Setup Notifikasi | Sebagai pengguna, saya ingin daftar perlengkapan hujan, dan sebagai tim kami ingin notifikasi siap dipakai agar pengingat dapat berbunyi. | Tinggi | 8 | F7, F16 setup, Bagian 9 |
| PB-09 | 5 | Lokasi Saya (Tahap 2): Jarak dan Favorit Terdekat | Sebagai pengguna, saya ingin melihat favorit terdekat dari posisi saya beserta Skor Payungnya, dengan penanganan izin yang jelas, agar tahu kondisi di sekitar. | Tinggi | 8 | F15 langkah 3 sampai 4 |
| PB-10 | 5 | Notifikasi Terjadwal | Sebagai pengguna, saya ingin pengingat berbunyi pada jam yang saya pilih dengan isi Skor Payung agar diingatkan sebelum kehujanan. | Tinggi | 8 | F16 |
| PB-11 | 6 | Penyempurnaan dan Integrasi Final | Sebagai tim, kami ingin ketuk notifikasi, jadwal ulang, tema gelap, dan seluruh integrasi selesai agar aplikasi utuh dan rapi. | Tinggi | 8 | F2 (banner, opsional), F8, F16, Bagian 12.3 |
| PB-12 | 7 | Pengujian, Perbaikan, dan Dokumentasi | Sebagai tim, kami ingin menguji, memperbaiki, dan menyusun laporan agar proyek siap dipresentasikan. | Tinggi | 8 | Bagian 16 sampai 20 |

Total Story Point: 13 + 5 + 8 + 8 + 8 + 8 + 8 + 8 + 8 + 8 + 8 + 8 = **98 SP**, dikerjakan dalam 7 sprint.

### 2.3 Definition of Done (berlaku untuk semua sprint)

Sesuai Bagian 17 Dokumen Final, satu fitur dianggap selesai jika:

- Berjalan tanpa error dan kasus gagal ditangani.
- Memenuhi kriteria **Selesai bila** pada fitur tersebut (Bagian 6).
- Sudah ditinjau pasangan dan masuk ke `main`.
- `flutter analyze` bersih dan tidak ada file hasil build di repository; file `.g.dart` ikut di-commit (Bagian 19).
- **F15 dan F16 sudah diuji di perangkat asli.**

## 3. Product Backlog Item (PBI) per Sprint

### 3.1 Prinsip Penyusunan

PBI adalah rincian Product Backlog menjadi task teknis yang selesai dalam satu sprint, disusun dengan prinsip INVEST. Tipe task: **Task** (implementasi), **Design** (rancangan UI dan struktur data), dan **Testing** (pengujian). Kolom PIC memakai kode **A1 (Loddy)**, **A2 (Salsabila)**, atau **Semua** (dikerjakan berdua). Pengujian diberikan ke anggota yang bukan pembuat fitur agar ada tinjauan silang. Tanda (Tambahan) dan (Opsional) mengikuti Bagian 5 dan 17 Dokumen Final. Seluruh status awal adalah To Do.

### 3.2 Sprint 1 (Hari 1): Fondasi dan Data Dasar (PB-01 + PB-02, Target: 18 SP)

**Sprint Goal:** Project dan Git siap, tema dan kontrak disepakati, data lokal dan login berjalan, dan data cuaca dari API sudah terbaca ke model.

**Bagian 17 Hari 1:** Loddy: uji API di Postman; `ApiService`, `WeatherData`, `CityResult` (stub). Salsabila: `main.dart` dengan Hive, model Hive dan adapter, Login, Root. Bersama: project dan Git siap; tema dan kontrak disepakati.

**PB-01: Fondasi Proyek, Login, dan Kerangka Navigasi (13 SP)**

| ID | Task / Sub-task | Tipe | SP | PIC | Status |
| --- | --- | --- | --- | --- | --- |
| PBI-001 | Analisis kebutuhan: baca Dokumen Final, sepakati kontrak integrasi (Bagian 12.2), kepemilikan file (Bagian 11), dan aturan Git (Bagian 19) | Task | 1 | Semua | To Do |
| PBI-002 | Siapkan project Flutter dan repository GitHub (branch `main`, `feature-loddy`, `feature-salsabila`), struktur folder `lib/`, serta dependency (Bagian 9.1) | Task | 1 | Semua | To Do |
| PBI-003 | Sepakati tema visual `app_theme.dart` (terang dan gelap, sesuai Bagian 10) | Design | 1 | Semua | To Do |
| PBI-004 | Implementasi model Hive `Reminder` (termasuk `notifOn` dan `repeatDaily` dengan `defaultValue`, Bagian 8), `FavoriteCity`, dan `GearItem`; jalankan `build_runner` dan commit `.g.dart` | Task | 2 | A2 | To Do |
| PBI-005 | Implementasi `main.dart`: `ensureInitialized`, `Hive.initFlutter`, `registerAdapter`, `openBox` (`reminders`, `favorites`, `gear`, dan `Box<String>` `weather_cache`), serta pasang tema | Task | 1 | A2 | To Do |
| PBI-006 | Implementasi model `User` (akun demo), `input_field.dart`, dan layar Login (`TextField`, `TextEditingController`, border merah, `SnackBar`) | Task | 2 | A2 | To Do |
| PBI-007 | Implementasi sesi (`_checkLogin` di `initState`, `loginData` dan `username`, `pushReplacement`) dan Root dengan `BottomNavigationBar` 5 tab berisi halaman placeholder | Task | 2 | A2 | To Do |
| PBI-008 | Buat stub kontrak (Bagian 12.3): `getWeather` bernilai tetap dan `LocationService.getCurrent` Yogyakarta (A1); `SettingsService` Yogyakarta dan `'C'`, `NotificationService.schedule` mencetak ke konsol (A2) | Task | 1 | Semua | To Do |
| PBI-009 | Pengujian: aplikasi berjalan di HP, `flutter analyze` bersih, semua box terbuka, login benar dan salah, sesi bertahan setelah restart, tombol back dari Beranda tidak kembali ke Login | Testing | 2 | A1 | To Do |

**PB-02: Data Cuaca Dasar (5 SP)**

| ID | Task / Sub-task | Tipe | SP | PIC | Status |
| --- | --- | --- | --- | --- | --- |
| PBI-010 | Uji API di Postman: endpoint cuaca dan geocoding (Bagian 4), catat nama field dan pemetaan `weather_code` | Task | 1 | A1 | To Do |
| PBI-011 | Implementasi `WeatherData` versi awal: `fromJson`, `empty()` (redirecting constructor), `_temperature` dengan getter dan setter, `isExtreme`, `condition`, dan `tempC` | Task | 2 | A1 | To Do |
| PBI-012 | Implementasi `CityResult.fromJson` (`name`, `province`, `latitude`, `longitude`) | Task | 1 | A1 | To Do |
| PBI-013 | Implementasi `ApiService.getWeather` versi awal (`http.get`, cek status code, `try/catch`; boleh memakai data tetap bila respons belum cocok) | Task | 1 | A1 | To Do |

### 3.3 Sprint 2 (Hari 2): Beranda, Skor Payung, Favorit, dan Profil (PB-03 + PB-04, Target: 16 SP)

**Sprint Goal:** Dua alur utama berjalan: cuaca kota utama tampil di Beranda lengkap dengan Skor Payung (Loddy), dan kota favorit, profil, serta pengaturan tersimpan (Salsabila).

**Bagian 17 Hari 2:** Loddy: F2 Beranda (loading, error), `WeatherAdvice` dan F9. Salsabila: F5 Kota Favorit, F8 Profil dan `SettingsService`. Bersama: dua alur utama berjalan.

**PB-03: Beranda Cuaca, Skor Payung, dan Saran (8 SP)**

| ID | Task / Sub-task | Tipe | SP | PIC | Status |
| --- | --- | --- | --- | --- | --- |
| PBI-014 | Rancang layout Beranda: kartu utama (`Stack`), `Row` info, tempat kartu Skor Payung, serta tombol dan kartu Lokasi Saya | Design | 1 | A1 | To Do |
| PBI-015 | Implementasi `WeatherAdvice` (abstract), `RainAdvice`, `CloudyAdvice`, `SunnyAdvice`, rumus Skor Payung, dan getter `WeatherData.advice` | Task | 2 | A1 | To Do |
| PBI-016 | Implementasi `AdviceCard`: warna hijau, kuning, merah dan chip saran dari `recommendations` | Task | 1 | A1 | To Do |
| PBI-017 | Implementasi `weather_card.dart` dan Beranda: `fetchWeather()` di `initState`, `isLoading`, pesan error dengan tombol Coba lagi, tarik-untuk-refresh, `SingleChildScrollView` | Task | 2 | A1 | To Do |
| PBI-018 | Beranda membaca kota utama dari `SettingsService` (default Yogyakarta) | Task | 1 | A1 | To Do |
| PBI-019 | Pengujian: tiga kondisi menghasilkan tiga kartu berbeda dari satu `AdviceCard`; loading, sukses, dan error (mode pesawat) | Testing | 1 | A2 | To Do |

**PB-04: Kota Favorit, Profil, dan Pengaturan (8 SP)**

| ID | Task / Sub-task | Tipe | SP | PIC | Status |
| --- | --- | --- | --- | --- | --- |
| PBI-020 | Rancang layar Kota Favorit (`GridView`) dan Profil (avatar, satuan C/F, saklar tema, kota utama, tombol Tes notifikasi, Logout) | Design | 1 | A2 | To Do |
| PBI-021 | Implementasi `SettingsService` (static method): `tempUnit`, `darkMode`, `mainCity`, `mainLat`, `mainLon` di Shared Preferences | Task | 1 | A2 | To Do |
| PBI-022 | Implementasi layar Kota Favorit: `GridView` dengan `ValueListenableBuilder`, fungsi simpan `FavoriteCity` dari `CityResult`, cegah duplikat dengan `SnackBar`, hapus dengan dialog konfirmasi (`deleteAt(index)`), ketuk kartu membuka Detail | Task | 2 | A2 | To Do |
| PBI-023 | Implementasi layar Profil: nama pengguna, pilihan satuan suhu, dan kota utama | Task | 2 | A2 | To Do |
| PBI-024 | Implementasi Logout: hapus kunci sesi lalu `pushAndRemoveUntil` ke Login | Task | 1 | A2 | To Do |
| PBI-025 | Pengujian: favorit bertahan tanpa internet, duplikat ditolak, pengaturan bertahan setelah restart, tombol back setelah logout tidak membuka halaman terproteksi | Testing | 1 | A1 | To Do |

### 3.4 Sprint 3 (Hari 3): Detail, Cari Kota, dan Pengingat (PB-05 + PB-06, Target: 16 SP)

**Sprint Goal:** Pengguna dapat membuka Detail cuaca, mencari kota lalu memfavoritkannya (Cari Kota ke Favorit terhubung), dan mengelola pengingat berbasis `key`.

**Bagian 17 Hari 3:** Loddy: F3 Detail, F4 Cari Kota. Salsabila: F6 Pengingat (CRUD berbasis `key`). Bersama: Cari Kota ke Favorit terhubung.

**PB-05: Detail Cuaca dan Cari Kota (8 SP)**

| ID | Task / Sub-task | Tipe | SP | PIC | Status |
| --- | --- | --- | --- | --- | --- |
| PBI-026 | Implementasi `DetailScreen`: constructor `latitude`, `longitude`, `namaKota` (wajib) dan `satuan` (opsional, default `'C'`); request sendiri di `initState`; `WeatherData? data` nullable | Task | 2 | A1 | To Do |
| PBI-027 | Detail: 24 jam (`ListView` horizontal), 7 hari (`ListView.builder` dan `ListTile`), ringkasan UV, angin, kelembapan (`GridView.builder`) | Task | 2 | A1 | To Do |
| PBI-028 | Implementasi `ApiService.searchCity` dan layar Cari Kota: `TextFormField` dengan validator (tidak kosong, minimal 3 huruf), `ListView` hasil, pesan Kota tidak ditemukan | Task | 2 | A1 | To Do |
| PBI-029 | Ikon hati di hasil Cari Kota memanggil fungsi simpan favorit milik Salsabila; ketuk hasil membuka Detail | Task | 1 | A1 | To Do |
| PBI-030 | Pengujian: Bandung dan Sleman menghasilkan daftar benar, query kosong atau kurang dari 3 huruf ditolak, kota berbeda menampilkan data berbeda, tombol back kembali | Testing | 1 | A2 | To Do |

**PB-06: Pengingat Cuaca (8 SP)**

| ID | Task / Sub-task | Tipe | SP | PIC | Status |
| --- | --- | --- | --- | --- | --- |
| PBI-031 | Rancang daftar Pengingat dan form tambah/edit (judul, kota, jam, catatan) | Design | 1 | A2 | To Do |
| PBI-032 | Implementasi daftar Pengingat dengan `ValueListenableBuilder`; tiap kartu menampilkan status payung dari `getWeather` dan `WeatherData.advice` | Task | 2 | A2 | To Do |
| PBI-033 | Implementasi `AddReminderScreen` untuk tambah dan edit (`_isEditMode`, parameter opsional `index`, `reminder`, `judulAwal`, `kotaAwal`), validator, dan `dispose` controller | Task | 2 | A2 | To Do |
| PBI-034 | Aturan ID berbasis `key`: tambah dengan `box.add`, ubah dengan `put(key)` atau `save()`, hapus dengan `cancel(key)` dahulu lalu `delete()` | Task | 2 | A2 | To Do |
| PBI-035 | Pengujian CRUD pengingat, data bertahan setelah restart, dan setelah beberapa kali hapus data yang tersisa tetap benar | Testing | 1 | A1 | To Do |

### 3.5 Sprint 4 (Hari 4): Cache, Lokasi, Perlengkapan, dan Setup Notifikasi (PB-07 + PB-08, Target: 16 SP)

**Sprint Goal:** Cuaca terakhir tetap tampil saat offline dan cuaca titik GPS muncul di Beranda (Loddy); perlengkapan hujan dan dasar notifikasi siap (Salsabila); konfigurasi Android beres.

**Bagian 17 Hari 4:** Loddy: F14 Cache offline, F15 langkah 1 sampai 2 (izin, posisi, cuaca lokasi). Salsabila: F7 Perlengkapan, F16 setup (paket, desugaring, manifest, `init`, tes notifikasi). Bersama: konfigurasi Android beres.

**PB-07: Cache Offline dan Lokasi Saya, Tahap 1 (8 SP)**

| ID | Task / Sub-task | Tipe | SP | PIC | Status |
| --- | --- | --- | --- | --- | --- |
| PBI-036 | (Tambahan) Implementasi `CacheService` (static method): `save` dan `read` dengan waktu simpan; `getWeather` menyimpan saat sukses, membaca cache saat gagal dan menandai `isFromCache`, melempar `Exception` bila cache kosong | Task | 2 | A1 | To Do |
| PBI-037 | (Tambahan) Label Data terakhir diperbarui (offline) di Beranda dan Detail saat memakai cache | Task | 1 | A1 | To Do |
| PBI-038 | F15 langkah 1 sampai 2: `LocationService` (static method) mengecek layanan lokasi, meminta izin, dan memanggil `Geolocator.getCurrentPosition()`; kegagalan dilempar sebagai exception | Task | 2 | A1 | To Do |
| PBI-039 | F15: tombol Lokasi Saya (ikon `my_location`) dan kartu cuaca serta Skor Payung di titik GPS dengan koordinat berhuruf kecil, lengkap dengan `CircularProgressIndicator` | Task | 2 | A1 | To Do |
| PBI-040 | Pengujian: mode pesawat menampilkan cache beserta waktunya; lokasi palsu di emulator menghasilkan cuaca titik itu | Testing | 1 | A2 | To Do |

**PB-08: Perlengkapan Hujan dan Setup Notifikasi (8 SP)**

| ID | Task / Sub-task | Tipe | SP | PIC | Status |
| --- | --- | --- | --- | --- | --- |
| PBI-041 | Implementasi `GearItem` dengan method `increase()` dan `decrease()` yang menjaga jumlah minimal 1 (field public) | Task | 1 | A2 | To Do |
| PBI-042 | Implementasi layar Perlengkapan dan `add_gear_screen.dart`: tambah, ubah jumlah (plus dan minus), checkbox sudah siap, hapus, progres n dari m siap | Task | 2 | A2 | To Do |
| PBI-043 | F16 setup: paket, `NotificationService` berpola Singleton (`init`: plugin, `tz.initializeTimeZones()`, channel Android) dipanggil di `main.dart`, dan `navigatorKey` di `MaterialApp` | Task | 2 | A2 | To Do |
| PBI-044 | F16 setup: `requestNotificationsPermission()` dan tombol Tes notifikasi di Profil (notifikasi langsung) | Task | 1 | A2 | To Do |
| PBI-045 | Konfigurasi Android berdua: desugaring di `build.gradle.kts`, izin lokasi dan notifikasi di manifest, serta receiver (Bagian 9.2 dan 9.3), lalu commit | Task | 1 | Semua | To Do |
| PBI-046 | Pengujian: jumlah barang tidak di bawah 1, progres akurat, data tersimpan permanen; Tes notifikasi muncul di HP asli | Testing | 1 | A1 | To Do |

### 3.6 Sprint 5 (Hari 5): Favorit Terdekat dan Notifikasi Terjadwal (PB-09 + PB-10, Target: 16 SP)

**Sprint Goal:** Favorit terdekat terurut dengan penanganan izin lengkap (Loddy), dan pengingat benar-benar berbunyi pada jamnya dengan ID berbasis `key` (Salsabila). LBS dan notifikasi berjalan di HP asli.

**Bagian 17 Hari 5:** Loddy: F15 langkah 3 sampai 4 (jarak dan urut favorit), penanganan izin. Salsabila: F16 jadwal, ID `key`, batal saat edit dan hapus. Bersama: LBS dan notifikasi berjalan di HP asli.

**PB-09: Lokasi Saya (Tahap 2): Jarak dan Favorit Terdekat (8 SP)**

| ID | Task / Sub-task | Tipe | SP | PIC | Status |
| --- | --- | --- | --- | --- | --- |
| PBI-047 | F15 langkah 3 sampai 4: `Geolocator.distanceBetween` ke tiap favorit, urut dari jarak terkecil, maksimal 5 terdekat, cuaca tiap favorit lewat `getWeather` dengan `Future.wait`, Skor Payung dari `advice` | Task | 3 | A1 | To Do |
| PBI-048 | Implementasi `nearby_favorites_card.dart`: nama, jarak, Skor Payung, penanda Kamu di sini (di bawah 150 m), teks Belum ada kota favorit | Task | 1 | A1 | To Do |
| PBI-049 | Penanganan izin: `AlertDialog` GPS mati (`openLocationSettings`), `SnackBar` saat ditolak, dialog khusus saat ditolak permanen (`openAppSettings`), dan teks privasi di dialog izin | Task | 2 | A1 | To Do |
| PBI-050 | Penanganan gagal ambil cuaca: pesan error, tidak crash, Beranda tetap memakai kota utama | Task | 1 | A1 | To Do |
| PBI-051 | Pengujian dengan lokasi palsu di emulator dan HP asli: izin diterima, ditolak, ditolak permanen, GPS mati, tanpa favorit, favorit terurut dengan jarak benar | Testing | 1 | A2 | To Do |

**PB-10: Notifikasi Terjadwal (8 SP)**

| ID | Task / Sub-task | Tipe | SP | PIC | Status |
| --- | --- | --- | --- | --- | --- |
| PBI-052 | Form pengingat: `Switch` Aktifkan notifikasi dan pilihan Sekali atau Setiap hari; izin diminta saat switch pertama dinyalakan (ditolak: switch kembali mati dan tampil pesan; ditolak permanen: arahkan ke pengaturan aplikasi) | Task | 2 | A2 | To Do |
| PBI-053 | Implementasi `schedule(reminder, advice)` dengan `zonedSchedule` (`exactAllowWhileIdle`); jam yang sudah lewat dijadwalkan besok; Setiap hari memakai `matchDateTimeComponents: DateTimeComponents.time`; isi memuat skor dan saran | Task | 2 | A2 | To Do |
| PBI-054 | ID notifikasi = `reminder.key`: edit berarti `cancel(id)` lalu jadwalkan ulang; hapus berarti `cancel(id)` sebelum `delete()` | Task | 1 | A2 | To Do |
| PBI-055 | Gagal mengambil cuaca saat menjadwalkan: tetap dijadwalkan dengan isi umum (Cek cuaca hari ini) atau memakai cache (F14) | Task | 1 | A2 | To Do |
| PBI-056 | Pengujian di HP asli: berbunyi saat aplikasi ditutup, isi memuat skor dan saran, edit dan hapus membatalkan jadwal lama, ID cocok setelah beberapa kali hapus, izin ditolak tidak crash, pengaruh hemat baterai | Testing | 2 | A1 | To Do |

### 3.7 Sprint 6 (Hari 6): Penyempurnaan dan Integrasi Final (PB-11, Target: 8 SP)

**Sprint Goal:** Ketuk notifikasi membuka Detail yang benar, pengingat dijadwalkan ulang saat aplikasi dibuka, tema gelap berjalan, UI rapi, dan seluruh titik integrasi tersambung.

**Bagian 17 Hari 6:** Loddy: banner ekstrem (opsional), perapian UI. Salsabila: ketuk notifikasi, jadwal ulang saat dibuka, tema gelap. Bersama: integrasi final, tinjauan silang.

**PB-11: Penyempurnaan dan Integrasi Final (8 SP)**

| ID | Task / Sub-task | Tipe | SP | PIC | Status |
| --- | --- | --- | --- | --- | --- |
| PBI-057 | (Opsional) Banner cuaca ekstrem di Beranda (`if (data.isExtreme) ...[`) dengan tombol Buat pengingat yang membuka `AddReminderScreen` dengan `judulAwal` dan `kotaAwal` terisi | Task | 1 | A1 | To Do |
| PBI-058 | Perapian UI: beberapa ukuran layar, tanpa overflow, tema terang dan gelap | Task | 1 | A1 | To Do |
| PBI-059 | Ketuk notifikasi: `payload` berisi `lat,lon,namaKota`, callback memanggil `navigatorKey.currentState!.push(DetailScreen(...))`; ikon lonceng di kartu pengingat | Task | 2 | A2 | To Do |
| PBI-060 | Setiap aplikasi dibuka, pengingat dengan `notifOn == true` dijadwalkan ulang dengan cuaca terbaru | Task | 1 | A2 | To Do |
| PBI-061 | Tema gelap: `ValueNotifier<ThemeMode>` dengan `ValueListenableBuilder` pada `MaterialApp`, saklar di Profil, tersimpan di `darkMode` | Task | 1 | A2 | To Do |
| PBI-062 | Integrasi final dan tinjauan silang: tujuh titik integrasi (Bagian 12.3) dan `flutter analyze` bersih | Task | 2 | Semua | To Do |

### 3.8 Sprint 7 (Hari 7): Pengujian, Perbaikan, dan Dokumentasi (PB-12, Target: 8 SP)

**Sprint Goal:** Seluruh fitur stabil di HP asli, bug diperbaiki, README dan video demo cadangan siap, laporan lengkap, dan presentasi sudah dilatih.

**Bagian 17 Hari 7:** Loddy: pengujian, bug. Salsabila: pengujian, bug. Bersama: README, laporan, video demo, latihan presentasi.

**PB-12: Pengujian, Perbaikan, dan Dokumentasi (8 SP)**

| ID | Task / Sub-task | Tipe | SP | PIC | Status |
| --- | --- | --- | --- | --- | --- |
| PBI-063 | Pengujian end-to-end memakai skenario demo 11 langkah (Bagian 16) di HP asli | Testing | 2 | Semua | To Do |
| PBI-064 | Perbaikan bug hasil pengujian | Task | 2 | Semua | To Do |
| PBI-065 | README dan video demo cadangan | Task | 1 | Semua | To Do |
| PBI-066 | Laporan: cover, daftar isi, landasan teori, perancangan (dari Dokumen Final), implementasi dan penjelasan kode disertai screenshot | Task | 2 | Semua | To Do |
| PBI-067 | Latihan presentasi: tiap anggota menjelaskan fitur yang ia pegang beserta kodenya (Bagian 20) | Task | 1 | Semua | To Do |

## 4. Ringkasan Sprint Plan

### 4.1 Ringkasan Sprint Plan

| Sprint | Hari (Bagian 17) | Product Backlog | Target SP | Jumlah PBI | Target Demo |
| --- | --- | --- | --- | --- | --- |
| Sprint 1 | Hari 1 | PB-01 Fondasi, Login, Navigasi; PB-02 Data Cuaca Dasar | 18 | 13 | Project dan Git siap, login dan sesi, lima tab, API terbaca ke model |
| Sprint 2 | Hari 2 | PB-03 Beranda, Skor Payung; PB-04 Favorit, Profil, Pengaturan | 16 | 12 | Beranda dengan Skor Payung, favorit, profil, logout |
| Sprint 3 | Hari 3 | PB-05 Detail dan Cari Kota; PB-06 Pengingat | 16 | 10 | Detail 24 jam dan 7 hari, Cari Kota ke Favorit, CRUD pengingat |
| Sprint 4 | Hari 4 | PB-07 Cache dan Lokasi Saya (Tahap 1); PB-08 Perlengkapan dan Setup Notifikasi | 16 | 11 | Mode offline, cuaca titik GPS, perlengkapan, Tes notifikasi |
| Sprint 5 | Hari 5 | PB-09 Favorit Terdekat; PB-10 Notifikasi Terjadwal | 16 | 10 | Favorit terurut jarak, notifikasi berbunyi di HP asli |
| Sprint 6 | Hari 6 | PB-11 Penyempurnaan dan Integrasi Final | 8 | 6 | Ketuk notifikasi, tema gelap, integrasi final |
| Sprint 7 | Hari 7 | PB-12 Pengujian, Perbaikan, Dokumentasi | 8 | 5 | Demo penuh, README, laporan, video, latihan |

Total: **12 Product Backlog, 98 SP, 7 sprint, 67 PBI.** Panjang tiap sprint mengikuti catatan Bagian 17: jadwal ringkas satu minggu dan bisa dilonggarkan. Tanggal sprint ada di Bagian 7.2.

### 4.2 Jadwal Kerja dari Dokumen Final (Bagian 17)

Tabel ini disalin dari Bagian 17 Dokumen Final dan dipetakan ke Product Backlog. Isinya tidak diubah.

| Hari | Loddy | Salsabila | Bersama | PB |
| --- | --- | --- | --- | --- |
| 1 | Uji API di Postman; `ApiService`, `WeatherData`, `CityResult` (stub) | `main.dart` dengan Hive, model Hive dan adapter, Login, Root | Project dan Git siap; tema dan kontrak disepakati | PB-01, PB-02 |
| 2 | F2 Beranda (loading, error), `WeatherAdvice` dan F9 | F5 Kota Favorit, F8 Profil dan `SettingsService` | Dua alur utama berjalan | PB-03, PB-04 |
| 3 | F3 Detail, F4 Cari Kota | F6 Pengingat (CRUD berbasis `key`) | Cari Kota ke Favorit terhubung | PB-05, PB-06 |
| 4 | F14 Cache offline, F15 langkah 1 sampai 2 (izin, posisi, cuaca lokasi) | F7 Perlengkapan, F16 setup (paket, desugaring, manifest, `init`, tes notifikasi) | Konfigurasi Android beres | PB-07, PB-08 |
| 5 | F15 langkah 3 sampai 4 (jarak dan urut favorit), penanganan izin | F16 jadwal, ID `key`, batal saat edit dan hapus | LBS dan notifikasi berjalan di HP asli | PB-09, PB-10 |
| 6 | Banner ekstrem (opsional), perapian UI | Ketuk notifikasi, jadwal ulang saat dibuka, tema gelap | Integrasi final, tinjauan silang | PB-11 |
| 7 | Pengujian, bug | Pengujian, bug | README, laporan, video demo, latihan presentasi | PB-12 |

### 4.3 Keseimbangan Beban (Story Point)

| Sprint | A1 (Loddy) | A2 (Salsabila) | Semua |
| --- | --- | --- | --- |
| 1 | 7 | 7 | 4 |
| 2 | 8 | 8 | 0 |
| 3 | 8 | 8 | 0 |
| 4 | 8 | 7 | 1 |
| 5 | 9 | 7 | 0 |
| 6 | 2 | 4 | 2 |
| 7 | 0 | 0 | 8 |
| **Total** | **42** | **41** | **15** |

### 4.4 Wajib, Tambahan, dan Opsional

**Wajib** berarti memenuhi kriteria Selesai bila; **Opsional** berarti bonus jika waktu ada (Bagian 17). Fitur Inti: F1 sampai F9, F15, dan F16. Fitur Tambahan: F14 (PBI-036 dan PBI-037). Bagian Opsional pada jadwal: banner ekstrem Hari 6 (PBI-057). Untuk notifikasi, jalur cadangan sesuai Bagian 18: tombol Tes notifikasi (PBI-044) dan video demo cadangan (PBI-065), supaya kendala di perangkat tidak memblokir demo.

## 5. Matriks Kepatuhan terhadap Materi Praktikum

| No | Materi | Implementasi | PB | Bukti Demo |
| --- | --- | --- | --- | --- |
| 1 | OOP: class, object, constructor | `WeatherData`, `CityResult`, `User`, `Reminder`, `FavoriteCity`, `GearItem` | PB-01, PB-02, PB-08 | Model dipakai di layar |
| 2 | OOP: named, factory, redirecting constructor | `fromJson`, `WeatherAdvice.fromScore`, `WeatherData.empty()` | PB-02, PB-03 | Data API menjadi objek |
| 3 | OOP: encapsulation | `_temperature` dengan getter dan setter; `GearItem.increase` dan `decrease` | PB-02, PB-08 | Jumlah barang tidak di bawah 1 |
| 4 | OOP: abstraction, inheritance, polymorphism | `WeatherAdvice` dan tiga turunannya; `AdviceCard`; `schedule` menerima `WeatherAdvice` | PB-03, PB-10 | Tiga kondisi, tiga kartu berbeda |
| 5 | OOP: static method dan Singleton | `ApiService`, `SettingsService`, `CacheService`, `LocationService`; `NotificationService` | PB-02, PB-04, PB-07, PB-08 | Satu instance notifikasi |
| 6 | Modul II: foundation dan layout | MaterialApp, Scaffold, AppBar, Container, SizedBox, Center, Column, Row, Stack | PB-03 | Beranda |
| 7 | Modul II: basic widget | Text, Icon, `Image.asset`, `Image.network`, tombol | PB-01, PB-03 | Login dan Beranda |
| 8 | Modul II: input | `TextField` (Login), `TextFormField` (Cari Kota, form) | PB-01, PB-05, PB-06 | Validator menolak input |
| 9 | Modul II: scrollable | ListView, ListView.builder, ListTile, GridView, GridView.builder, SingleChildScrollView | PB-03, PB-04, PB-05, PB-06, PB-08 | Detail, Favorit, Pengingat |
| 10 | Modul III: StatefulWidget dan `setState` | Login, Beranda, form | PB-01, PB-03, PB-06 | UI berubah saat state berubah |
| 11 | Modul III: `TextEditingController` dan conditional rendering | Login, banner ekstrem, keadaan kosong | PB-01, PB-09, PB-11 | Border merah saat salah |
| 12 | Modul III: model dan widget reusable | `input_field.dart` | PB-01 | Dipakai ulang di form |
| 13 | Modul IV: `push` dan `pop` | Beranda ke Detail, ke form, kartu favorit ke Detail | PB-04, PB-05, PB-06 | Tombol back kembali |
| 14 | Modul IV: `pushReplacement`, `pushAndRemoveUntil` | Login ke Root; Logout | PB-01, PB-04 | Back tidak kembali ke Login |
| 15 | Modul IV: passing data wajib dan opsional | `DetailScreen`, `AddReminderScreen` | PB-05, PB-06, PB-11 | Detail kota yang benar |
| 16 | Modul IV: BottomNavigationBar | Root 5 tab | PB-01 | Semua tab berfungsi |
| 17 | Modul IV: `navigatorKey` | Ketuk notifikasi membuka Detail | PB-08, PB-11 | Detail terbuka dari notifikasi |
| 18 | Modul V: HTTP, JSON, Future, async, await | `getWeather`, `searchCity` | PB-02, PB-05 | Data dari API tampil |
| 19 | Modul V: try-catch, `initState`, nullable | Loading, sukses, gagal di Beranda dan Detail | PB-03, PB-05 | Mode pesawat tidak crash |
| 20 | Modul VI: Shared Preferences | `loginData`, `username`, `tempUnit`, `darkMode`, kota utama | PB-01, PB-04, PB-11 | Sesi dan pengaturan bertahan |
| 21 | Modul VI: Hive (CRUD, TypeAdapter, ValueListenableBuilder) | `favorites`, `reminders`, `gear`, `weather_cache` | PB-01, PB-04, PB-06, PB-08 | Data bertahan setelah restart |
| 22 | Modul VI: tugas keranjang belanja | Perlengkapan Hujan | PB-08 | Tambah, ubah jumlah, hapus |
| 23 | Modul VII: LBS | Lokasi Saya, jarak ke favorit | PB-07, PB-09 | Favorit terurut jarak |
| 24 | Modul VII: Notification | `zonedSchedule`, payload, izin | PB-08, PB-10, PB-11 | Notifikasi berbunyi di HP asli |
| 25 | Kerja tim dua orang | Git, tinjauan silang, kepemilikan file | PB-01, PB-12 | Riwayat commit |
| 26 | Presentasi dan laporan | Tiap anggota menjelaskan fitur miliknya | PB-12 | Presentasi dan dokumen laporan |

## 6. Risiko dan Hal yang Perlu Disepakati

### 6.1 Risiko

Disalin dari Bagian 18 Dokumen Final.

| Risiko | Dampak | Mitigasi |
| --- | --- | --- |
| Format respons API berbeda dari dugaan | Parsing gagal | Uji di Postman hari pertama (PBI-010); nilai bawaan jika field kosong |
| API tidak tersedia saat demo | Demo macet | Cache offline (F14) dan video demo cadangan |
| Konflik `typeId` atau adapter Hive | Crash saat start | `typeId` hanya di Bagian 8; hanya Salsabila menambah model |
| Field private pada class Hive bermasalah dengan generator | Build gagal | Field public; aturan dijaga lewat method (`increase`, `decrease`) |
| Konfigurasi Android notifikasi tidak lengkap | Notifikasi tidak muncul atau build gagal | Salin Modul VII persis (desugaring, izin, receiver) |
| Notifikasi tertunda di HP hemat baterai | Demo gagal | Uji di HP asli; tombol Tes notifikasi; video cadangan |
| ID notifikasi tidak cocok dengan data | Notifikasi salah batal | ID = `key` Hive, bukan `index`; batal sebelum hapus |
| Izin lokasi ditolak permanen | Fitur terlihat rusak | Dialog khusus menuju pengaturan aplikasi |
| Lokasi sulit diuji di emulator | LBS tampak tidak jalan | Extended controls, Location, atau HP asli |
| Konflik Git | Kode saling menimpa | Branch terpisah, satu pemilik per file, tinjauan silang |
| Salah satu bagian terlambat | Integrasi tertunda | Stub sejak awal; cek progres singkat |

### 6.2 Hal yang Perlu Disepakati Tim

- Tanggal target selesai tiap sprint pada Bagian 7.2 adalah usulan; geser sesuai kesepakatan, asalkan Sprint 7 selesai sebelum Kamis, 26 November 2026.
- Tipe `time` pada `Reminder` ditetapkan Salsabila; asumsinya `String` berformat HH:mm (Bagian 8).
- Paket dan versi mengikuti Modul VII (Bagian 9.1); tidak memakai paket `geocoding`.
- Kontrak integrasi (Bagian 12.2) tidak boleh berubah diam-diam; constructor `DetailScreen(latitude, longitude, namaKota, satuan)` tetap.
- Hanya Salsabila yang menambah model Hive dan mengubah `main.dart`.
- HP asli untuk menguji F15 dan F16: HP siapa, versi Android berapa, dan pengaturan hemat baterainya.
- Batasan yang ditulis di laporan: isi notifikasi dihitung saat dijadwalkan dan tidak diperbarui di latar belakang; Shared Preferences tidak terenkripsi.
- Privasi lokasi ditulis di dialog izin dan laporan: lokasi hanya dipakai untuk mengambil cuaca dan tidak disimpan.
- Banner ekstrem (PBI-057) dikerjakan hanya jika Hari 6 masih longgar.

## 7. Pembagian Tugas, Jadwal Presentasi, dan Ceklis Laporan

### 7.1 Pembagian Tugas Tim

Sesuai Bagian 5 dan 20 Dokumen Final.

| PIC | Anggota | Peran | Tanggung Jawab |
| --- | --- | --- | --- |
| A1 | Loddy | Data cuaca dan LBS | F2 Beranda, F3 Detail, F4 Cari Kota, F9 Skor Payung, F14 Cache offline, F15 Lokasi Saya; `ApiService`, `WeatherData`, `CityResult`, `WeatherAdvice`, `CacheService`, `LocationService` |
| A2 | Salsabila | Akun, data lokal, dan notifikasi | F1 Login, F5 Kota Favorit, F6 Pengingat, F7 Perlengkapan, F8 Profil dan Root, F16 Notifikasi; `main.dart`, model Hive, `SettingsService`, `NotificationService` |
| Bersama | Loddy dan Salsabila | Fondasi dan laporan | Project dan Git, tema, kontrak integrasi, konfigurasi Android, tinjauan silang, pengujian akhir, README, laporan, video demo, latihan presentasi |

### 7.2 Jadwal Presentasi

Presentasi akhir dijadwalkan **Kamis, 26 November 2026**. Tanggal target selesai tiap sprint di bawah ini adalah usulan: tujuh sprint tersebar sejak 11 November dengan jeda sekitar dua hari, dan dua hari cadangan sebelum presentasi.

| Sprint | Hari | Target yang Didemokan | Target Selesai (usulan) |
| --- | --- | --- | --- |
| Sprint 1 | 1 | Project, login dan sesi, lima tab, API terbaca ke model | Rabu, 11 November 2026 |
| Sprint 2 | 2 | Beranda dengan Skor Payung, favorit, profil, logout | Jumat, 13 November 2026 |
| Sprint 3 | 3 | Detail, Cari Kota ke Favorit, CRUD pengingat | Minggu, 15 November 2026 |
| Sprint 4 | 4 | Mode offline, cuaca titik GPS, perlengkapan, Tes notifikasi | Selasa, 17 November 2026 |
| Sprint 5 | 5 | Favorit terdekat, notifikasi berbunyi di HP asli | Kamis, 19 November 2026 |
| Sprint 6 | 6 | Ketuk notifikasi, tema gelap, integrasi final | Sabtu, 21 November 2026 |
| Sprint 7 | 7 | Demo penuh, README, laporan, video, latihan presentasi | Senin, 23 November 2026 |
| Cadangan | - | Perbaikan akhir dan latihan | Selasa sampai Rabu, 24 sampai 25 November 2026 |
| **Presentasi** | - | Demo dan penjelasan fitur masing-masing | **Kamis, 26 November 2026** |

### 7.3 Ceklis Laporan Akhir

Isi laporan diambil dari Dokumen Final dan dokumen ini.

- Cover
- Daftar isi
- Landasan teori dan tema aplikasi
- Perancangan: fitur, alur navigasi, daftar layar, struktur data lokal, rancangan OOP, tema visual (Dokumen Final)
- Implementasi dan penjelasan kode disertai screenshot
- Hasil pengujian (skenario demo dan daftar uji, Bagian 16 Dokumen Final)
- Batasan yang disadari (notifikasi tanpa pembaruan di latar belakang, Shared Preferences tidak terenkripsi, login demo)
- Product Backlog dan PBI (dokumen ini)
- Laporan diunggah dan dicetak sesuai ketentuan dosen
