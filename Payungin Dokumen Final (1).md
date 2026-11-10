# Payungin: Dokumen Final Perancangan dan Panduan Pengembangan

**Praktikum Pemrograman Aplikasi Mobile** · Tim: **Loddy** dan **Salsabila** · Tema: Aplikasi Pemantau dan Pengingat Cuaca

> Dokumen ini **menggantikan** dua dokumen sebelumnya (*Dokumen Konsep dan Perancangan* dan *Tambahan FR Notifikasi dan LBS*). Jika ada perbedaan, **dokumen ini yang berlaku**. Dokumen ini juga dipakai sebagai **acuan bagi AI pengembang** (Bagian 0).

---

## 0\. Panduan untuk AI Pengembang (Baca Dulu)

Bagian ini berlaku untuk AI mana pun (Claude Code, Copilot, dan sebagainya) yang diminta membantu menulis kode Payungin.

### 0.1 Konteks singkat

- Payungin adalah aplikasi Flutter (Android) untuk tugas praktikum dua orang. Penilaian mengikuti materi praktikum: **OOP, Widget, State dan Data, Navigation, HTTP Request, Local Storage, Notification dan LBS**.  
- Kode harus **sederhana dan bisa dijelaskan oleh mahasiswa saat presentasi**. Pemilik fitur harus paham setiap baris yang ia kumpulkan. Hindari trik yang terlalu canggih.

### 0.2 Aturan wajib

1. **Hanya pakai teknik yang ada di materi.** State memakai `setState` (StatefulWidget), bukan GetX, Provider, Riverpod, atau Bloc. Navigasi memakai `Navigator`, bukan `go_router`.  
2. **Hanya pakai paket pada Bagian 9\.** Jangan menambah paket baru tanpa persetujuan pemilik fitur. Khususnya, **jangan memakai `geocoding`**.  
3. **Kerjakan hanya fitur milik PIC yang meminta** (Bagian 5\) dan hanya menyentuh file miliknya (Bagian 11). Jika perlu mengubah file milik orang lain, berhenti dan sampaikan kebutuhan itu sebagai catatan integrasi.  
4. **Jangan mengubah kontrak integrasi** (Bagian 12\) secara diam-diam: nama fungsi, parameter, dan tipe kembalian harus sama persis.  
5. **Hanya Salsabila yang mengubah model Hive dan `main.dart`** (registrasi adapter, `openBox`). Selalu jalankan `dart run build_runner build --delete-conflicting-outputs` setelah mengubah model Hive.  
6. **Teks antarmuka berbahasa Indonesia.** Nama class, method, dan variabel memakai bahasa Inggris atau gabungan seperti di dokumen ini (`namaKota`, `satuan`). Komentar kode berbahasa Indonesia, singkat, dan menjelaskan alasan.  
7. **Setiap proses asynchronous punya tiga keadaan:** loading, sukses, dan gagal (`try/catch`). Jangan pernah memakai `data!` sebelum loading selesai.  
8. **Jangan mengarang nama field API.** Buka endpoint (Bagian 4\) dan cocokkan nama field sebelum menulis `fromJson`.  
9. **Jangan menyimpan koordinat pengguna.** Koordinat hanya dikirim ke Open-Meteo untuk mengambil cuaca.  
10. **Jangan memasukkan rahasia atau file build ke Git.** Tidak ada API key di proyek ini.  
11. Setelah menulis kode: jalankan `flutter analyze` dan pastikan bersih, lalu jalankan aplikasi. Kode dianggap selesai bila memenuhi **"Selesai bila"** pada fitur terkait.

### 0.3 Cara membaca dokumen ini saat mengerjakan sebuah fitur

1. Baca Bagian 5 untuk fitur tersebut (tujuan, tampilan, cara kerja, data, file, selesai bila).  
2. Baca kontrak yang menyentuh fitur itu (Bagian 12\) dan pakai **stub** jika bagian lawan belum ada.  
3. Cek penanganan error (Bagian 14\) dan tema (Bagian 10).  
4. Kode contoh di dokumen ini adalah **kerangka**. Sesuaikan dengan versi paket dan modul praktikum.

### 0.4 Larangan

- Tidak ada fitur di luar daftar FR (F1 sampai F9, F14, F15, F16). Fitur yang sudah dibuang tercantum di Bagian 15\.  
- Tidak ada background service atau pembaruan otomatis di latar belakang.  
- Tidak ada penyimpanan password yang dianggap aman. Shared Preferences **bukan** penyimpanan terenkripsi, dan login di aplikasi ini adalah akun demo.

---

## 1\. Ringkasan Proyek

Payungin menjawab satu pertanyaan sehari-hari: **"Hari ini perlu bawa payung atau tidak?"** Aplikasi mengambil cuaca dari internet, mengolahnya menjadi **Skor Payung** (0 sampai 100\) dan saran yang mudah dipahami, menampilkan cuaca di lokasi pengguna lewat GPS, lalu mengingatkan lewat notifikasi.

| Item | Keterangan |
| :---- | :---- |
| Nama aplikasi | Payungin |
| Platform | Flutter (Android) |
| Anggota tim | Loddy dan Salsabila |
| Data online | Open-Meteo Forecast dan Open-Meteo Geocoding, tanpa API key |
| Data lokal | Shared Preferences (sesi, pengaturan), Hive (data utama) |
| Sensor dan sistem | GPS (`geolocator`), notifikasi lokal (`flutter_local_notifications`) |
| Cakupan materi | OOP, Modul II (Widget), III (State dan Data), IV (Navigation), V (HTTP), VI (Local Storage), VII (Notification dan LBS) |
| Repository | [https\://github.com/Loddy04/payungin.git](https://github.com/Loddy04/payungin.git) |
| Jumlah fitur | **12 FR**, masing-masing orang memegang **6** |

---

## 2\. Gambaran Alur Aplikasi

### 2.1 Tiga lapisan

1. **Tampilan** (`screens/`, `widgets/`): halaman yang dilihat pengguna.  
2. **Model dan logika** (`models/`): class data dan aturan, misalnya Skor Payung.  
3. **Data dan layanan** (`api/`, `services/`): `ApiService` untuk internet, Hive dan Shared Preferences untuk perangkat, `LocationService` untuk GPS, `NotificationService` untuk notifikasi.

### 2.2 Alur navigasi

```
Login ──(pushReplacement)──▶ Root (BottomNavigationBar, 5 tab)
                              ├─ Beranda        ──(push + passing data)──▶ Detail Cuaca
                              ├─ Kota           ──(push)──▶ Cari Kota
                              ├─ Pengingat      ──(push)──▶ Tambah/Edit Pengingat
                              ├─ Perlengkapan   ──(push)──▶ Tambah/Edit Barang
                              └─ Profil         ──(pushAndRemoveUntil)──▶ Login (Logout)
Notifikasi diketuk ──(navigatorKey.push)──▶ Detail Cuaca
```

Lima tab: **Beranda, Kota, Pengingat, Perlengkapan, Profil**.

### 2.3 Contoh skenario satu hari

1. Pengguna membuka aplikasi. Sesi tersimpan, sehingga langsung masuk ke Beranda. (F1)  
2. Beranda mengambil cuaca dan menampilkan kartu **Skor Payung 78: Bawa payung**. Hasilnya disimpan sebagai cache. (F2, F9, F14)  
3. Pengguna membuka Detail untuk melihat cuaca per jam dan 7 hari. (F3)  
4. Di tab Kota ia mencari "Bantul" dan menyimpannya sebagai favorit. (F4, F5)  
5. Ia menekan **Lokasi Saya**. Muncul cuaca di posisinya, ditambah daftar favorit terdekat beserta jarak dan skor masing-masing. (F15)  
6. Ia membuat pengingat "Bawa payung" jam 14.00 dengan notifikasi aktif. Jam 14.00 notifikasi muncul. (F6, F16)

---

## 3\. Daftar Layar (11 layar)

| \# | Layar | File | Dibuka dari | Fitur | PIC |
| :---- | :---- | :---- | :---- | :---- | :---- |
| 1 | Login | `login_screen.dart` | Awal aplikasi, setelah logout | F1 | Salsabila |
| 2 | Root (kerangka 5 tab) | `root.dart` | Setelah login | F8 | Salsabila |
| 3 | Beranda (tab 1\) | `home_screen.dart` | Root | F2, F9, F14, F15 | Loddy |
| 4 | Detail Cuaca | `detail_screen.dart` | Kartu Beranda, hasil Cari Kota, notifikasi, kartu favorit | F3 | Loddy |
| 5 | Kota (tab 2, daftar favorit) | `favorites_screen.dart` | Root | F5 | Salsabila |
| 6 | Cari Kota | `search_city_screen.dart` | Tombol di tab Kota | F4 | Loddy |
| 7 | Pengingat (tab 3\) | `reminders_screen.dart` | Root | F6, F16 | Salsabila |
| 8 | Tambah/Edit Pengingat | `add_reminder_screen.dart` | Tab Pengingat | F6, F16 | Salsabila |
| 9 | Perlengkapan (tab 4\) | `gear_screen.dart` | Root | F7 | Salsabila |
| 10 | Tambah/Edit Barang | `add_gear_screen.dart` | Tab Perlengkapan | F7 | Salsabila |
| 11 | Profil (tab 5\) | `profile_screen.dart` | Root | F8, F16 (tombol tes) | Salsabila |

Fitur **Lokasi Saya (F15)** tidak punya layar sendiri. Ia berupa tombol dan kartu di dalam Beranda.

---

## 4\. Sumber Data Online

Sebelum menulis model, **buka tiap endpoint di browser atau Postman** dan cocokkan nama field.

| Kebutuhan | Endpoint | Dipakai oleh |
| :---- | :---- | :---- |
| Cuaca saat ini, per jam, harian | `https://api.open-meteo.com/v1/forecast?latitude=-7.79&longitude=110.36&current=temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,wind_speed_10m&hourly=temperature_2m,precipitation_probability,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,uv_index_max&timezone=auto` | F2, F3, F9, F14, F15, F16 |
| Cari kota (nama ke koordinat) | `https://geocoding-api.open-meteo.com/v1/search?name=Yogyakarta&count=5` | F4 |

**Struktur respons:**

- Cuaca: objek `current` (angka tunggal), serta `hourly` dan `daily` yang berisi list paralel (`time[]`, `temperature_2m[]`, dan seterusnya dengan indeks sama).  
- Geocoding: list `results`, tiap item berisi `name`, `latitude`, `longitude`, `country`, `admin1` (provinsi). Jika tidak ada hasil, kunci `results` bisa tidak ada, sehingga `fromJson` dan pemanggil harus menangani `null`.

**Pemetaan `weather_code`:** 0 cerah; 1 sampai 3 cerah berawan sampai berawan; 45 dan 48 berkabut; 51 sampai 57 gerimis; 61 sampai 67 hujan; 80 sampai 82 hujan lokal; 95 sampai 99 badai petir. Pemetaan ditulis **sekali** di `WeatherData` dan dipakai semua halaman.

**Tiga fase data (Modul V):** *Fetch* (`http.get`), *Parse* (`jsonDecode` lalu `fromJson`), *Render* (simpan ke state lalu tampilkan).

**Perbedaan F4 dan F15 (sering tertukar):**

|  | F4 Cari Kota | F15 Lokasi Saya |
| :---- | :---- | :---- |
| Sumber koordinat | Open-Meteo Geocoding (HTTP) dari nama yang diketik | GPS perangkat lewat `geolocator` |
| Perlu izin dan GPS | Tidak | Ya |
| Materi | HTTP (V) | LBS (VII) |

---

## 5\. Daftar Fitur dan PIC

| FR | Fitur | Jenis | PIC |
| :---- | :---- | :---- | :---- |
| F1 | Login dan sesi otomatis | Inti | Salsabila |
| F2 | Beranda cuaca (termasuk banner cuaca ekstrem) | Inti | Loddy |
| F3 | Detail cuaca (per jam dan 7 hari) | Inti | Loddy |
| F4 | Cari kota | Inti | Loddy |
| F5 | Kota favorit | Inti | Salsabila |
| F6 | Pengingat cuaca (CRUD) | Inti | Salsabila |
| F7 | Keranjang perlengkapan hujan | Inti | Salsabila |
| F8 | Profil dan pengaturan | Inti | Salsabila |
| F9 | Skor Payung dan saran | Inti | Loddy |
| F14 | Mode offline (cache cuaca terakhir) | Tambahan | Loddy |
| F15 | Lokasi Saya (LBS) dan favorit terdekat | Inti (Modul VII) | Loddy |
| F16 | Notifikasi pengingat | Inti (Modul VII) | Salsabila |

Nomor F10, F11, F12, dan F13 sengaja **tidak dipakai** (lihat Bagian 15\) supaya nomor di kode, commit, dan laporan tetap konsisten dengan dokumen sebelumnya.

**Pembagian:** Loddy memegang data dari internet, logika cuaca, GPS, dan cache. Salsabila memegang data di perangkat, akun, navigasi utama, dan notifikasi.

---

## 6\. Penjelasan Detail Fitur

Format tiap fitur: tujuan, tampilan, cara kerja, data, file, materi, dan kriteria selesai.

### F1. Login dan Sesi Otomatis (PIC: Salsabila)

- **Tujuan:** login sekali, pembukaan berikutnya langsung ke Beranda.  
- **Tampilan:** kartu di tengah layar berisi logo, kolom username, kolom password (tersembunyi), dan tombol Masuk. Jika salah, border kolom berubah merah dan muncul `SnackBar`.  
- **Cara kerja:**  
  1. `initState()` memanggil `_checkLogin()` yang membaca `getBool('loginData')` (default `false`).  
  2. Jika `true`, `pushReplacement` ke Root.  
  3. Jika belum, pengguna mengisi form. `_login()` membandingkan dengan model `User` (akun demo). Jika cocok, simpan `setBool('loginData', true)` dan `setString('username', ...)`, lalu `pushReplacement` ke Root.  
  4. Jika salah, `setState` mengubah `isLoginFailed = true`.  
- **Data:** Shared Preferences (`loginData`, `username`).  
- **File:** `login_screen.dart`, `user.dart`, `input_field.dart`.  
- **Materi:** TextField, `TextEditingController`, StatefulWidget, `setState`, conditional rendering, widget reusable (III); `pushReplacement` (IV); Shared Preferences (VI).  
- **Selesai bila:** tutup lalu buka ulang tanpa login ulang; tombol back dari Beranda tidak kembali ke Login.

### F2. Beranda Cuaca (PIC: Loddy)

- **Tujuan:** gambaran cuaca kota utama dalam sekali lihat.  
- **Tampilan:** kartu utama berlatar gradien (`Stack`) berisi nama kota, suhu besar, ikon, kondisi, dan "terasa seperti". Di bawahnya `Row` info (kelembapan, angin, peluang hujan), kartu Skor Payung (F9), tombol dan kartu Lokasi Saya (F15). Halaman dibungkus `SingleChildScrollView` dan mendukung tarik-untuk-refresh.  
- **Banner cuaca ekstrem (dilebur ke F2):** di atas Beranda muncul banner merah jika getter `WeatherData.isExtreme == true` (kode cuaca 95 sampai 99, atau angin 40 km/jam ke atas, atau UV 8 ke atas). Memakai `if (data.isExtreme) ...[`. Opsional: tombol "Buat pengingat" membuka `AddReminderScreen` dengan `judulAwal` dan `kotaAwal` terisi.  
- **Cara kerja:**  
  1. Kota utama dibaca dari `SettingsService` (default Yogyakarta).  
  2. `fetchWeather()` (`async`) dipanggil di `initState()`. Selama menunggu, `isLoading = true` dan tampil `CircularProgressIndicator`.  
  3. `ApiService.getWeather(lat, lon)` mengembalikan `Future<WeatherData>`; hasil disimpan lewat `setState`.  
  4. Jika gagal, blok `catch` menampilkan pesan dan tombol "Coba lagi". Jika cache F14 tersedia, cache dipakai (lihat F14).  
- **Data:** respons cuaca menjadi `WeatherData`.  
- **File:** `home_screen.dart`, `weather_card.dart`.  
- **Materi:** Scaffold, AppBar, Stack, Row, Column, Container, SizedBox, Text, Icon, `Image.network`/`Image.asset`, tombol (II); Future, async, await, http, `jsonDecode`, try-catch, `initState` (V); conditional rendering (III).  
- **Selesai bila:** loading, sukses, dan error tampil benar (uji dengan mode pesawat); banner hanya muncul saat syaratnya terpenuhi (uji dengan data tiruan).

### F3. Detail Cuaca: Per Jam dan 7 Hari (PIC: Loddy)

- **Tujuan:** prakiraan lengkap untuk satu kota.  
- **Tampilan:** AppBar berisi nama kota. `ListView` horizontal untuk 24 jam ke depan, `ListView.builder` \+ `ListTile` untuk 7 hari (hari, ikon, suhu maks/min, peluang hujan), dan `GridView.builder` untuk ringkasan UV, angin, kelembapan.  
- **Cara kerja:** dibuka dengan `Navigator.push`. Data dikirim lewat constructor: `latitude`, `longitude`, `namaKota` (wajib) dan `satuan` (opsional, default `'C'`). Halaman melakukan request sendiri berdasarkan koordinat. Variabel `WeatherData? data` bersifat nullable dan baru dipakai dengan `data!.` setelah loading selesai.  
- **Data:** `hourly` dan `daily`.  
- **File:** `detail_screen.dart`.  
- **Materi:** `push`/`pop`, passing data wajib dan opsional (IV); ListView, ListView.builder, ListTile, GridView.builder (II); nullable (V).  
- **Selesai bila:** membuka kota berbeda menampilkan data kota itu; tombol back kembali ke halaman asal.

### F4. Cari Kota (PIC: Loddy)

- **Tujuan:** memantau kota mana pun, tidak hanya kota bawaan.  
- **Tampilan:** satu `TextFormField` dengan ikon cari dan validator (tidak boleh kosong, minimal 3 huruf). Hasil muncul sebagai `ListView` (nama, provinsi, negara). Ketuk hasil membuka Detail Cuaca. Ikon hati di tiap hasil menyimpan kota ke favorit (F5).  
- **Cara kerja:** `ApiService.searchCity(query)` memanggil endpoint geocoding dan mengubah `results` menjadi `List<CityResult>` lewat `CityResult.fromJson`. Hasil kosong menampilkan "Kota tidak ditemukan". Ikon hati membuat `FavoriteCity` dari `CityResult` (nama, provinsi, lat, lon) dan menyimpannya lewat fungsi milik Salsabila (lihat kontrak).  
- **Data:** respons geocoding.  
- **File:** `search_city_screen.dart`, `city_result.dart`.  
- **Materi:** TextFormField, validator (II); static method, factory constructor, `map(...).toList()` (V); kerja sama dengan Hive (VI).  
- **Selesai bila:** "Bandung" dan "Sleman" menghasilkan daftar benar; query kosong atau kurang dari 3 huruf ditolak.

### F5. Kota Favorit (PIC: Salsabila)

- **Tujuan:** menyimpan kota yang sering dipantau, **beserta koordinatnya** (dipakai F15).  
- **Tampilan:** tab Kota berisi `GridView` kartu kota (nama dan suhu terakhir dari cache jika ada). Ketuk kartu membuka Detail. Ikon sampah menghapus (dengan dialog konfirmasi).  
- **Cara kerja:** model `FavoriteCity` (Hive, `typeId: 1`) di box `favorites`. Tambah dengan `add()`, hapus dengan `deleteAt(index)`. Daftar dibungkus `ValueListenableBuilder` pada `Hive.box<FavoriteCity>('favorites').listenable()`. Mencegah duplikat: cek nama (atau koordinat) sebelum `add()` dan tampilkan `SnackBar` jika sudah ada.  
- **Data:** box `favorites` (name, province, lat, lon).  
- **File:** `favorites_screen.dart`, `favorite_city.dart`.  
- **Materi:** Hive Box, TypeAdapter, HiveObject, CRUD, ValueListenableBuilder (VI); GridView (II); `push` dengan data (IV).  
- **Selesai bila:** favorit tetap ada setelah aplikasi ditutup, tanpa internet; duplikat ditolak.

### F6. Pengingat Cuaca / CRUD (PIC: Salsabila)

- **Tujuan:** pengingat pribadi terkait cuaca, misalnya "Bawa payung sebelum pulang kuliah".  
- **Tampilan:** daftar kartu pengingat (judul, kota, jam, catatan) dengan `FloatingActionButton` tambah. Tiap kartu menampilkan **status payung** kota itu (misalnya "Bawa payung") dari `ApiService` dan `WeatherData.advice`, serta ikon lonceng jika notifikasi aktif (F16).  
- **Cara kerja:** satu halaman `AddReminderScreen` dipakai untuk **tambah dan edit**. Parameter opsional `index` dan `reminder` menentukan `_isEditMode`, mengikuti pola `AddTodoScreen` di Modul VI. Controller dilepas di `dispose()`. Form dikosongkan ditolak validator.  
- **Aturan ID (penting):** baca dengan `getAt(index)` seperti materi, tetapi **identitas pengingat adalah `reminder.key` (Hive), bukan `index`**. Index bergeser saat ada yang dihapus, sedangkan key tetap. Karena itu:  
  - Tambah: `final key = await box.add(r)`.  
  - Ubah: `await box.put(r.key, r)` atau `r.save()`.  
  - Hapus: `NotificationService().cancel(r.key)` **dahulu**, baru `await r.delete()`.  
  - ID notifikasi \= `r.key` (lihat F16).  
- **Data:** box `reminders` (`typeId: 0`): `title`, `cityName`, `lat`, `lon`, `time`, `note`, `notifOn`, `repeatDaily` (lihat Bagian 8).  
- **File:** `reminders_screen.dart`, `add_reminder_screen.dart`, `reminder.dart`.  
- **Materi:** CRUD Hive, `@HiveType`/`@HiveField`, `build_runner`, ValueListenableBuilder (VI); StatefulWidget, `TextEditingController` (III); `push`/`pop` (IV).  
- **Selesai bila:** tambah, ubah, hapus berjalan; data bertahan setelah restart; setelah beberapa kali hapus, notifikasi yang dibatalkan tetap milik pengingat yang benar.

### F7. Keranjang Perlengkapan Hujan (PIC: Salsabila)

- **Tujuan:** daftar barang yang harus disiapkan sebelum hujan (menjawab tugas "keranjang" Modul VI dalam konteks cuaca).  
- **Tampilan:** daftar barang (payung, jas hujan, sepatu anti-air, dan lain-lain) dengan jumlah, tombol plus dan minus, dan checkbox "sudah siap". Bagian atas menampilkan progres, misalnya "5 dari 8 siap".  
- **Cara kerja:** `GearItem` (Hive, `typeId: 2`) memakai encapsulation: method `increase()` dan `decrease()` menjaga jumlah minimal 1\. Perubahan disimpan dengan `putAt()` atau `save()`. Hapus dengan `deleteAt()`.  
- **Data:** box `gear` (name, quantity, isReady).  
- **File:** `gear_screen.dart`, `add_gear_screen.dart`, `gear_item.dart`.  
- **Materi:** CRUD Hive (VI); encapsulation (OOP); ListView.builder, ListTile (II).  
- **Selesai bila:** jumlah tidak bisa kurang dari 1, progres akurat, data tersimpan permanen.

### F8. Profil dan Pengaturan (PIC: Salsabila)

- **Tujuan:** pusat pengaturan dan keluar akun; juga kerangka navigasi utama.  
- **Tampilan:** avatar, nama pengguna, pilihan satuan suhu (C/F), saklar **tema gelap**, pilihan kota utama, tombol **Tes notifikasi** (F16), dan tombol Logout.  
- **Cara kerja:** satuan, tema, dan kota utama disimpan di Shared Preferences lewat `SettingsService` (static method). Tema gelap mengubah `themeMode` pada `MaterialApp` (misalnya lewat `ValueNotifier<ThemeMode>` yang dibungkus `ValueListenableBuilder`, tanpa paket tambahan). Logout menghapus kunci sesi lalu `pushAndRemoveUntil(..., (route) => false)` ke Login. Root memakai `BottomNavigationBar` dengan `_selectedIndex`.  
- **Data:** Shared Preferences (`tempUnit`, `darkMode`, `mainCity`, `mainLat`, `mainLon`).  
- **File:** `root.dart`, `profile_screen.dart`, `settings_service.dart`.  
- **Materi:** BottomNavigationBar, `pushAndRemoveUntil` (IV); Shared Preferences (VI); `setState`, conditional rendering (III).  
- **Selesai bila:** pengaturan bertahan setelah restart; setelah logout, tombol back tidak membuka halaman terproteksi.

### F9. Skor Payung dan Saran (PIC: Loddy)

- **Tujuan:** mengubah angka cuaca menjadi keputusan.  
- **Tampilan:** kartu berwarna (hijau, kuning, merah) berisi angka 0 sampai 100, judul saran (misalnya "Bawa payung\!"), satu kalimat penjelasan, dan **chip saran singkat** dari getter `recommendations` (misalnya "Jas hujan", "Tabir surya").  
- **Cara kerja:** `skor = min(100, round(peluangHujanMaks * 0.7) + bonusKode + bonusAngin)`.  
  - `peluangHujanMaks`: peluang hujan terbesar pada jam aktif 06.00 sampai 22.00 hari ini.  
  - `bonusKode`: 10 gerimis, 20 hujan, 30 badai.  
  - `bonusAngin`: 10 jika angin 30 km/jam ke atas.  
  - Skor diteruskan ke `WeatherAdvice.fromScore(skor)`: 60 ke atas `RainAdvice`, 30 sampai 59 `CloudyAdvice`, di bawah 30 `SunnyAdvice`. Ambang boleh disetel setelah uji coba.  
- **Data:** dari `WeatherData` (tanpa request tambahan).  
- **File:** `weather_advice.dart`, `advice_card.dart`.  
- **Materi:** abstraction, inheritance (`extends`, `super`), polymorphism, overriding, factory constructor (OOP); conditional rendering (III).  
- **Selesai bila:** tiga kondisi cuaca menghasilkan tiga kartu berbeda dari satu pemanggilan `AdviceCard(advice)` yang sama.

### F14. Mode Offline dan Cache (PIC: Loddy)

- **Tujuan:** aplikasi tetap berguna saat sinyal hilang.  
- **Tampilan:** label kecil "Data terakhir diperbarui 14.05 (offline)" di Beranda dan Detail saat memakai cache.  
- **Cara kerja:** `CacheService` (static method) memakai box `weather_cache` bertipe `Box<String>`.  
  - `ApiService.getWeather` yang sukses memanggil `CacheService.save(key, json)`, dengan `key = '$lat,$lon'`. Waktu simpan ikut disimpan.  
  - Jika request gagal, `ApiService` memanggil `CacheService.read(key)`. Jika ada, kembalikan data cache dan tandai `isFromCache = true`. Jika tidak ada cache, lempar `Exception` agar UI menampilkan pesan error.  
  - Box dibuka oleh Salsabila di `main.dart`: `await Hive.openBox<String>('weather_cache')`. Loddy hanya memakainya.  
- **Data:** box `weather_cache` (tanpa adapter).  
- **File:** `cache_service.dart`, `api_service.dart`.  
- **Materi:** Hive (VI); try-catch dan static method (V); conditional rendering (III).  
- **Selesai bila:** setelah sekali online, mematikan internet tetap menampilkan cuaca terakhir beserta label waktunya.

### F15. Lokasi Saya (LBS) dan Favorit Terdekat (PIC: Loddy)

- **Tujuan:** menampilkan cuaca di posisi pengguna **tanpa mengetik nama kota**, lalu membandingkannya dengan kota favorit yang sudah disimpan.  
- **Tampilan (semua di Beranda):**  
  - Tombol **"Lokasi Saya"** dengan ikon `my_location`.  
  - Saat proses berjalan: `CircularProgressIndicator`.  
  - Kartu **"Lokasi Saya"**: cuaca dan Skor Payung di titik itu, dengan koordinat berhuruf kecil. Tidak ada nama daerah (tidak memakai paket `geocoding`).  
  - Bagian **"Favorit Terdekat"**: daftar kota favorit diurutkan dari yang terdekat. Tiap item menampilkan nama, jarak, dan Skor Payung. Jarak di bawah 150 m ditandai "Kamu di sini". Jika belum ada favorit: "Belum ada kota favorit".  
- **Cara kerja (empat langkah yang dijelaskan saat presentasi):**  
  1. **Izin dan GPS:** cek layanan lokasi aktif, minta izin; jika gagal, tampil pesan dan Beranda tetap memakai kota utama.  
  2. **Ambil posisi:** `Geolocator.getCurrentPosition()` menghasilkan latitude dan longitude.  
  3. **Hitung jarak:** untuk tiap favorit, `Geolocator.distanceBetween(...)` menghasilkan meter.  
  4. **Urutkan dan tampilkan:** urut dari jarak terkecil; cuaca tiap favorit diambil lewat `ApiService.getWeather` (batasi maksimal 5 favorit terdekat, dan gunakan `Future.wait`), lalu Skor Payung dari `WeatherData.advice`.  
- **Penanganan izin:**

| Keadaan | Perilaku |
| :---- | :---- |
| Layanan lokasi mati | `AlertDialog` dengan tombol menuju `Geolocator.openLocationSettings()` |
| Izin ditolak (`denied`) | `SnackBar` penjelasan; tombol bisa ditekan lagi |
| Izin ditolak permanen (`deniedForever`) | **Dialog khusus** berisi arahan ke pengaturan aplikasi dengan tombol `Geolocator.openAppSettings()` (bukan sekadar `SnackBar`, karena dialog izin sistem tidak akan muncul lagi) |
| Gagal ambil cuaca | pesan error, tidak crash |

- **Privasi (tulis di dialog izin dan di laporan):** "Lokasi hanya dipakai untuk mengambil cuaca dari Open-Meteo dan tidak disimpan."  
- **Data:** tidak ada tabel baru. Membaca box `favorites` milik Salsabila (sudah memiliki `lat` dan `lon`).  
- **File:** `location_service.dart`, `home_screen.dart`, `nearby_favorites_card.dart`.  
- **Paket dan izin:** `geolocator`; `ACCESS_FINE_LOCATION` dan `ACCESS_COARSE_LOCATION` di manifest (Bagian 9).  
- **Materi:** LBS (VII): izin, `isLocationServiceEnabled`, `checkPermission`/`requestPermission`, `getCurrentPosition`, `distanceBetween`; async, await, try-catch (V); conditional rendering (III); AlertDialog, SnackBar (II); static method (OOP).  
- **Selesai bila:**  
  - Izin diterima: cuaca lokasi saat ini tampil, favorit terurut dengan jarak yang benar (uji dengan lokasi palsu di emulator dan di HP asli).  
  - Izin ditolak, ditolak permanen, atau GPS mati: tidak crash, ada pesan jelas, Beranda tetap berfungsi.  
  - Tanpa favorit: tampil teks kosong, bukan layar kosong.

### F16. Notifikasi Pengingat Cuaca (PIC: Salsabila)

- **Tujuan:** pengingat F6 benar-benar berbunyi pada jam yang dipilih, dengan isi dari Skor Payung. Contoh: "Skor Payung 78: Bawa payung\!"  
- **Tampilan:**  
  - Form pengingat: `Switch` **"Aktifkan notifikasi"** dan pilihan **"Sekali" atau "Setiap hari"**.  
  - Kartu pengingat: ikon lonceng jika aktif.  
  - Profil: tombol **"Tes notifikasi"** (notifikasi langsung, untuk demo).  
  - Mengetuk notifikasi membuka Detail Cuaca kota pengingat.  
- **Cara kerja (mengikuti Modul VII):**  
  1. `NotificationService` berpola **Singleton** (hanya satu instance). `init()` dipanggil di `main.dart` sebelum `runApp`: inisialisasi plugin, `tz.initializeTimeZones()`, dan channel Android.  
  2. Saat pertama kali switch dinyalakan, minta izin lewat `requestNotificationsPermission()` (Android 13 ke atas). Jika ditolak, switch kembali mati dan tampil pesan. Jika ditolak permanen, arahkan ke pengaturan aplikasi.  
  3. Saat pengingat disimpan: ambil cuaca kota pengingat, hitung `advice`, lalu panggil `schedule(reminder, advice)` memakai `zonedSchedule(...)` dengan `androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle`. Jika jam sudah lewat hari ini, jadwalkan besok. "Setiap hari" memakai `matchDateTimeComponents: DateTimeComponents.time`.  
  4. **ID notifikasi \= `reminder.key`.** Edit berarti `cancel(id)` lalu jadwalkan ulang. Hapus berarti `cancel(id)` sebelum `delete()`.  
  5. Setiap aplikasi dibuka, pengingat dengan `notifOn == true` dijadwalkan ulang dengan cuaca terbaru agar pesan tidak basi.  
  6. Ketuk notifikasi: `payload` berisi `lat,lon,namaKota`; callback memanggil `navigatorKey.currentState!.push(DetailScreen(...))`. `navigatorKey` dipasang di `MaterialApp`.  
  7. Gagal mengambil cuaca saat menjadwalkan: tetap jadwalkan dengan isi umum ("Cek cuaca hari ini") atau pakai cache (F14).  
- **Batasan yang disadari (tulis di laporan):** isi notifikasi dihitung saat dijadwalkan dan diperbarui tiap aplikasi dibuka; tidak ada pembaruan di latar belakang.  
- **Data:** field `notifOn` dan `repeatDaily` pada `Reminder`.  
- **File:** `notification_service.dart`, `reminder.dart`, `add_reminder_screen.dart`, `reminders_screen.dart`, `profile_screen.dart`, `main.dart`.  
- **Konfigurasi Android:** Bagian 9\.  
- **Materi:** Notification (VII): paket, desugaring, permission, `zonedSchedule`, payload; CRUD Hive (VI); async (V); `navigatorKey` dan navigasi (IV); `Switch`, form (II, III); singleton dan static (OOP).  
- **Selesai bila:** notifikasi berbunyi saat aplikasi ditutup; isinya memuat skor dan saran yang sesuai; edit dan hapus membatalkan jadwal lama; ketuk membuka Detail kota yang benar; izin ditolak tidak membuat crash; diuji di HP asli.

---

## 7\. Rancangan OOP

| Konsep | Penerapan | Pemilik |
| :---- | :---- | :---- |
| Class dan object | `WeatherData`, `CityResult`, `User`, `Reminder`, `FavoriteCity`, `GearItem` | Keduanya |
| Generative constructor | semua model, parameter `required` | Keduanya |
| Named dan factory constructor | `WeatherData.fromJson`, `CityResult.fromJson`, `WeatherAdvice.fromScore` | Loddy |
| Redirecting constructor | `WeatherData.empty()` mengarah ke constructor utama dengan nilai awal | Loddy |
| Encapsulation | `WeatherData` menyimpan `_temperature` private dengan getter `tempFahrenheit`, setter yang menolak suhu tak masuk akal, dan getter `isExtreme` | Loddy |
| Encapsulation (lokal) | `GearItem.increase()` dan `decrease()` menjaga jumlah minimal 1 | Salsabila |
| Abstraction | `abstract class WeatherAdvice` (getter `title`, `message`, `needUmbrella`, `recommendations`) | Loddy |
| Inheritance | `RainAdvice`, `CloudyAdvice`, `SunnyAdvice` (`extends`, `super`) | Loddy |
| Polymorphism | `AdviceCard(WeatherAdvice advice)` menampilkan isi berbeda per subclass; `NotificationService.schedule` menerima `WeatherAdvice` | Loddy dan Salsabila |
| HiveObject | `Reminder`, `FavoriteCity`, `GearItem` mewarisi `HiveObject` | Salsabila |
| Static method | `ApiService`, `CacheService`, `SettingsService`, `LocationService` | Keduanya |
| Singleton (factory constructor) | `NotificationService` | Salsabila |

**Kerangka `WeatherAdvice`:**

```dart
abstract class WeatherAdvice {
  final int score;
  WeatherAdvice(this.score);

  String get title;
  String get message;
  bool get needUmbrella;
  List<String> get recommendations;

  factory WeatherAdvice.fromScore(int s) {
    if (s >= 60) return RainAdvice(s);
    if (s >= 30) return CloudyAdvice(s);
    return SunnyAdvice(s);
  }
}

class RainAdvice extends WeatherAdvice {
  RainAdvice(super.score);
  @override String get title => 'Bawa payung!';
  @override String get message => 'Peluang hujan tinggi hari ini.';
  @override bool get needUmbrella => true;
  @override List<String> get recommendations => ['Jas hujan', 'Sepatu anti-air'];
}
// CloudyAdvice dan SunnyAdvice mengikuti pola yang sama dengan isi berbeda.
```

&nbsp;

**Kerangka `LocationService`** (galat dibedakan agar UI bisa memberi respons berbeda):

```dart
import 'package:geolocator/geolocator.dart';

enum LocationError { serviceOff, denied, deniedForever }

class LocationException implements Exception {
  final LocationError type;
  final String message;
  LocationException(this.type, this.message);
  @override
  String toString() => message;
}

class LocationService {
  static Future<Position> getCurrent() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw LocationException(LocationError.serviceOff, 'Layanan lokasi mati');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw LocationException(
          LocationError.deniedForever, 'Izin lokasi ditolak permanen');
    }
    if (permission == LocationPermission.denied) {
      throw LocationException(LocationError.denied, 'Izin lokasi ditolak');
    }

    return await Geolocator.getCurrentPosition();
  }
}
```

&nbsp;

**Inti perhitungan F15:**

```dart
final pos = await LocationService.getCurrent();
final favorites = Hive.box<FavoriteCity>('favorites').values.toList();

final hasil = favorites.map((k) {
  final meter = Geolocator.distanceBetween(
      pos.latitude, pos.longitude, k.lat, k.lon);
  return (kota: k, jarak: meter);
}).toList()
  ..sort((a, b) => a.jarak.compareTo(b.jarak));

String formatJarak(double m) => m < 150
    ? 'Kamu di sini'
    : m < 1000
        ? '${m.round()} m'
        : '${(m / 1000).toStringAsFixed(1)} km';
```

&nbsp;

**Kerangka `NotificationService`** (Singleton; sesuaikan dengan versi paket dan Modul VII):

```dart
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. tz.initializeTimeZones() dan set lokasi zona waktu
    // 2. inisialisasi plugin + callback saat notifikasi diketuk (payload)
    // 3. buat channel Android "payungin_reminder"
  }

  Future<bool> requestPermission() async {
    // requestNotificationsPermission() pada implementasi Android; true/false
    return true;
  }

  Future<void> schedule(Reminder r, WeatherAdvice advice) async {
    // id      = r.key
    // judul   = r.title
    // isi     = 'Skor Payung ${advice.score}: ${advice.title}'
    // payload = '${r.lat},${r.lon},${r.cityName}'
    // zonedSchedule(..., androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle)
    // jam sudah lewat -> besok; repeatDaily -> matchDateTimeComponents: DateTimeComponents.time
  }

  Future<void> cancel(int id) async {}

  Future<void> showNow(String title, String body) async {}
}
```

&nbsp;

**Kerangka `CacheService` dan pemakaiannya di `ApiService`:**

```dart
class CacheService {
  static Box<String> get _box => Hive.box<String>('weather_cache');
  static Future<void> save(String key, String json) async {
    await _box.put(key, json);
    await _box.put('$key:time', DateTime.now().toIso8601String());
  }
  static String? read(String key) => _box.get(key);
  static String? readTime(String key) => _box.get('$key:time');
}

// Di ApiService.getWeather(lat, lon):
// try { request -> CacheService.save(key, body) -> return WeatherData.fromJson(...) }
// catch (_) { final c = CacheService.read(key);
//             if (c != null) return WeatherData.fromJson(jsonDecode(c), fromCache: true);
//             rethrow; }
```

&nbsp;

---

## 8\. Struktur Data Lokal

**Hive** (inisialisasi di `main.dart`: `WidgetsFlutterBinding.ensureInitialized`, `Hive.initFlutter`, `registerAdapter`, `openBox`; hanya Salsabila yang mengubahnya):

| Box | Isi | `typeId` | Field | Pemilik | Dipakai oleh |
| :---- | :---- | :---- | :---- | :---- | :---- |
| `reminders` | `Reminder` | 0 | title, cityName, lat, lon, time, note, `notifOn` (HiveField 6), `repeatDaily` (HiveField 7\) | Salsabila | F6, F16 |
| `favorites` | `FavoriteCity` | 1 | name, province, lat, lon | Salsabila | F4, F5, F15 |
| `gear` | `GearItem` | 2 | name, quantity, isReady | Salsabila | F7 |
| `weather_cache` | `String` (JSON mentah) | tanpa adapter | key `lat,lon` dan `lat,lon:time` | Loddy (pemakai), Salsabila (membuka box) | F14 |

- `typeId` 3 dicadangkan dan tidak dipakai. Jangan menambah `typeId` baru tanpa persetujuan Salsabila.  
- Field baru `Reminder` wajib punya `defaultValue`, misalnya `@HiveField(6, defaultValue: false)`, agar data lama tidak error. Lalu jalankan `dart run build_runner build --delete-conflicting-outputs` dan commit file `.g.dart`.  
- Tipe `time` pada `Reminder` ditetapkan Salsabila. Panduan ini mengasumsikan `String` berformat `"HH:mm"`; sesuaikan perhitungan jadwal jika memakai tipe lain.

**Shared Preferences** (data sederhana, **tidak terenkripsi**):

| Key | Tipe | Fungsi | Pemilik |
| :---- | :---- | :---- | :---- |
| `loginData` | bool | status sesi | Salsabila |
| `username` | String | nama pengguna | Salsabila |
| `tempUnit` | String | satuan suhu (C atau F) | Salsabila |
| `darkMode` | bool | tema gelap | Salsabila |
| `mainCity`, `mainLat`, `mainLon` | String, double | kota utama Beranda | Salsabila |

---

## 9\. Dependency dan Konfigurasi Android

### 9.1 Paket (`pubspec.yaml`)

`http`, `shared_preferences`, `hive`, `hive_flutter`, `geolocator`, `flutter_local_notifications`, `timezone`; dev: `hive_generator`, `build_runner`.

Versi mengikuti Modul VII: `flutter_local_notifications ^19.0.0`, `timezone ^0.10.0`, `geolocator ^13.0.0`. Tidak ada paket `geocoding`. Folder `assets/images/` (logo) didaftarkan di `pubspec.yaml` (hati-hati dengan indentasi).

### 9.2 Desugaring (`android/app/build.gradle.kts`), untuk notifikasi

- Dalam `compileOptions`: `isCoreLibraryDesugaringEnabled = true`.  
- Dalam `dependencies`: `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`.

### 9.3 Izin (`android/app/src/main/AndroidManifest.xml`)

Di dalam `<manifest>`, di luar `<application>`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

Di dalam `<application>`, di bawah `<activity>`: tiga `receiver` dari paket, yaitu `ScheduledNotificationReceiver`, `ScheduledNotificationBootReceiver` (dengan `intent-filter` untuk `BOOT_COMPLETED`, `MY_PACKAGE_REPLACED`, `QUICKBOOT_POWERON`), dan `FlutterLocalNotificationsReceiver`, semuanya `android:exported="false"` dengan nama `com.dexterous.flutterlocalnotifications.*`. Salin persis dari Modul VII (Contoh Program 7.3). Tanpa receiver ini notifikasi terjadwal tidak akan pernah muncul.

---

## 10\. Tema Visual

Gaya: **kartu bulat berwarna biru lembut dengan efek kaca (glassy)**, mendukung **mode terang dan gelap**. Referensi tampilan: artifact "Payungin UI" (11 layar, terang dan gelap). Terapkan lewat `ThemeData` di `lib/theme/app_theme.dart` (parameter `theme` dan `darkTheme` pada `MaterialApp`), satu kali, dipakai bersama.

[https\://swept-prime-09944913.figma.site/](https://swept-prime-09944913.figma.site/)&nbsp;

| Token | Terang | Gelap |
| :---- | :---- | :---- |
| Latar (gradien) | `#D6E8FF` ke `#F6FAFF` | `#0A1530` ke `#13265A` |
| Kartu kaca | putih 58% transparan, border putih | `rgba(30,50,98,0.52)`, border biru 18% |
| Kartu utama (hero) | `#2A5BDB` ke `#3A70EA` | `#27479F` ke `#3A63C9` |
| Aksen | `#2A62F0` | `#6C97FF` |
| Teks | `#10244A` | `#EAF1FF` |
| Teks redup | `#4A5F8A` | `#A8BBE3` |

Aturan bentuk: radius kartu 26 sampai 30, tombol 22, chip 12 sampai 16; jarak 14 antar kartu dan 18 dari tepi layar; efek kaca memakai BackdropFilter (blur sekitar 22\) di atas latar gradien; ikon bergaya garis. Font bawaan Flutter dipakai (font khusus bersifat opsional dan hanya boleh ditambahkan lewat assets, bukan paket baru). Skor Payung memakai warna semantik: hijau (di bawah 30), kuning (30 sampai 59), merah (60 ke atas), dan tetap harus terbaca di kedua mode.

---

## 11\. Struktur Folder dan Kepemilikan File

```
lib/
├─ main.dart                         Salsabila (Hive, NotificationService.init, navigatorKey, tema)
├─ theme/
│   └─ app_theme.dart                bersama
├─ api/
│   └─ api_service.dart              Loddy
├─ services/
│   ├─ cache_service.dart            Loddy
│   ├─ location_service.dart         Loddy
│   ├─ settings_service.dart         Salsabila
│   └─ notification_service.dart     Salsabila
├─ models/
│   ├─ weather_data.dart             Loddy
│   ├─ city_result.dart              Loddy
│   ├─ weather_advice.dart           Loddy
│   ├─ user.dart                     Salsabila
│   ├─ reminder.dart (+ .g.dart)     Salsabila
│   ├─ favorite_city.dart (+ .g.dart) Salsabila
│   └─ gear_item.dart (+ .g.dart)    Salsabila
├─ screens/
│   ├─ login_screen.dart             Salsabila
│   ├─ root.dart                     Salsabila
│   ├─ home_screen.dart              Loddy
│   ├─ detail_screen.dart            Loddy
│   ├─ search_city_screen.dart       Loddy
│   ├─ favorites_screen.dart         Salsabila
│   ├─ reminders_screen.dart         Salsabila
│   ├─ add_reminder_screen.dart      Salsabila
│   ├─ gear_screen.dart              Salsabila
│   ├─ add_gear_screen.dart          Salsabila
│   └─ profile_screen.dart           Salsabila
└─ widgets/
    ├─ input_field.dart              Salsabila
    ├─ weather_card.dart             Loddy
    ├─ advice_card.dart              Loddy
    └─ nearby_favorites_card.dart    Loddy
```

---

## 12\. Navigasi, Passing Data, dan Kontrak Integrasi

### 12.1 Navigasi

| Method | Dipakai untuk | Fitur |
| :---- | :---- | :---- |
| `Navigator.push` | Beranda ke Detail, Kota ke Cari Kota, ke form tambah/edit, kartu favorit ke Detail, Lokasi Saya ke Detail | F3, F4, F5, F6, F7, F15 |
| `Navigator.pop` | menutup form setelah simpan, tombol batal, kembali dari Detail | F3, F6, F7 |
| `Navigator.pushReplacement` | Login ke Root | F1 |
| `Navigator.pushAndRemoveUntil` | Logout ke Login | F8 |
| `BottomNavigationBar` | pindah antar lima tab | F8 |
| `navigatorKey.currentState!.push` | ketuk notifikasi membuka Detail | F16 |

**Passing data:** `DetailScreen(latitude, longitude, namaKota, satuan)`; `AddReminderScreen(index, reminder, judulAwal, kotaAwal)` dengan semua parameter opsional.

### 12.2 Kontrak (nama dan tipe tidak boleh diubah diam-diam)

| Dari | Untuk | Kontrak |
| :---- | :---- | :---- |
| Loddy | Salsabila | `ApiService.getWeather(double lat, double lon)` mengembalikan `Future<WeatherData>` |
| Loddy | Salsabila | `WeatherData.advice` mengembalikan `WeatherAdvice`; `WeatherData.condition` dan `tempC` untuk kartu pengingat dan favorit |
| Loddy | Salsabila | `CityResult` berisi `name`, `province`, `latitude`, `longitude` |
| Salsabila | Loddy | model `FavoriteCity(name, province, lat, lon)`, box `favorites`, dan fungsi penyimpanan favorit dari `CityResult` |
| Salsabila | Loddy | `SettingsService.unit`, `mainCity`, `mainLat`, `mainLon` |
| Salsabila | Loddy | `Hive.openBox<String>('weather_cache')` sudah dibuka di `main.dart` |
| Salsabila | Loddy | `AddReminderScreen` menerima `judulAwal` dan `kotaAwal` opsional (untuk banner ekstrem) |

### 12.3 Titik integrasi

1. Kartu pengingat (F6) menampilkan saran payung dari `getWeather` dan `advice` (F9).  
2. Tombol hati di Cari Kota (F4) menyimpan ke Hive (F5).  
3. `ApiService` (F2, F3) memakai `CacheService` (F14): keduanya milik Loddy.  
4. Beranda membaca kota utama dan satuan dari pengaturan (F8).  
5. F15 membaca box `favorites` (F5) dan memakai `getWeather`.  
6. Pengingat (F6) memanggil `getWeather`, lalu `NotificationService.schedule` (F16).  
7. (Opsional) banner ekstrem (F2) membuka form pengingat (F6) dengan data terisi.

**Stub** selama bagian lawan belum selesai: `ApiService.getWeather()` mengembalikan `WeatherData` tetap; `SettingsService` mengembalikan Yogyakarta (-7.79, 110.36) dan `'C'`; `LocationService.getCurrent()` mengembalikan koordinat Yogyakarta; `NotificationService.schedule()` cukup mencetak ke konsol.

---

## 13\. Pemetaan Materi ke Fitur

| Materi | Dipakai di |
| :---- | :---- |
| **Modul II**: MaterialApp, Scaffold, AppBar | semua layar |
| Container, SizedBox, Center, Column, Row, Stack | kartu dan tata letak; Beranda (Stack) |
| Text, Icon, Image.asset, Image.network | Beranda, Login (logo), ikon cuaca |
| TextButton, OutlinedButton, ElevatedButton | Coba lagi, Masuk, Simpan, Lokasi Saya |
| TextField, TextFormField | Login (TextField), Cari Kota dan form (TextFormField) |
| ListView, ListView.builder, ListTile | per jam, 7 hari, pengingat, perlengkapan, favorit terdekat |
| GridView, GridView.builder | Detail (ringkasan), Kota (favorit), chip saran |
| SingleChildScrollView, AlertDialog, SnackBar | Beranda, Detail; dialog konfirmasi dan izin; pesan |
| **Modul III**: Stateless vs Stateful, setState | halaman statis vs dinamis |
| TextEditingController, conditional rendering | Login, form, banner ekstrem, keadaan kosong |
| **Modul IV**: push, pop, pushReplacement, pushAndRemoveUntil | Bagian 12.1 |
| Passing data wajib dan opsional | Detail, form pengingat |
| BottomNavigationBar | Root |
| **Modul V**: HTTP, JSON, Future, async, await, try-catch | `ApiService`, F2, F3, F4, F15 |
| static method, factory `fromJson`, nullable | `ApiService`, `WeatherData`, `CityResult` |
| **Modul VI**: Shared Preferences | F1, F8 |
| Hive (Box, TypeAdapter, HiveObject, CRUD, ValueListenableBuilder) | F5, F6, F7, F14 |
| Tugas keranjang belanja | F7 |
| **Modul VII**: Notification (paket, desugaring, permission, `zonedSchedule`) | F16 |
| **Modul VII**: LBS (izin, GPS, `getCurrentPosition`, `distanceBetween`) | F15 |
| **OOP** | Bagian 7 |

---

## 14\. Penanganan Error dan Kasus Khusus

| Situasi | Perilaku yang diharapkan |
| :---- | :---- |
| Tidak ada internet di Beranda | Tampil cache terakhir dengan label offline; jika tidak ada cache, pesan dan tombol Coba lagi |
| Server error (status bukan 200\) | `ApiService` melempar `Exception`; UI menangkapnya lewat try-catch dan menghentikan loading |
| Pencarian kota tanpa hasil | Pesan "Kota tidak ditemukan" |
| Favorit sama ditambahkan dua kali | Ditolak dengan `SnackBar` |
| Form pengingat kosong | Validator menolak simpan |
| Hapus data | Dialog konfirmasi sebelum hapus |
| Jumlah barang dikurangi hingga 0 | Ditahan di 1 oleh `decrease()` |
| Data cuaca masih null | `CircularProgressIndicator`, tidak memakai `data!` sebelum selesai |
| GPS mati | Dialog menuju pengaturan lokasi; Beranda memakai kota utama |
| Izin lokasi ditolak | `SnackBar`; boleh dicoba lagi |
| Izin lokasi ditolak permanen | Dialog menuju pengaturan aplikasi (`openAppSettings`) |
| Belum ada kota favorit | Teks "Belum ada kota favorit" di bagian Favorit Terdekat |
| Izin notifikasi ditolak | Switch kembali mati; pesan penjelasan (permanen: arahkan ke pengaturan aplikasi) |
| Jam pengingat sudah lewat hari ini | Dijadwalkan besok |
| Gagal mengambil cuaca saat menjadwalkan | Jadwalkan dengan isi umum atau pakai cache |
| Pengingat diedit atau dihapus | Notifikasi lama dibatalkan dengan `cancel(key)` sebelum data berubah |
| Notifikasi diketuk saat aplikasi tertutup | Aplikasi terbuka dan menavigasi ke Detail dari `payload` |
| Aplikasi ditutup saat login | Sesi dan data Hive tetap utuh |

---

## 15\. Perubahan dari Rancangan Awal

Fitur berikut **dibuang** karena tidak menambah materi baru dan hanya menambah risiko:

| Kode lama | Fitur | Perlakuan |
| :---- | :---- | :---- |
| F10 | Rekomendasi pakaian dan aktivitas | Dilebur ke F9 sebagai getter `recommendations` (chip saran) |
| F11 | Cek perjalanan dua kota | Dibuang; kebutuhan serupa dipenuhi daftar Favorit Terdekat di F15 |
| F12 | Peringatan cuaca ekstrem | Dilebur ke F2 sebagai banner kondisional (`isExtreme`) |
| F13 | Jurnal hujan | Dibuang (CRUD Hive sudah terwakili F5, F6, F7) |

Perubahan lain: paket `geocoding` tidak dipakai (F15 menampilkan koordinat); `CacheService` (F14) pindah ke Loddy; CRUD Pengingat memakai `key` Hive sebagai identitas; penanganan izin ditolak permanen dibedakan dari ditolak biasa.

**Ide lanjutan (di luar cakupan):** widget layar utama Android, grafik tren cuaca, berbagi saran ke teman, pembaruan notifikasi di latar belakang, nama daerah lewat geocoding, tombol "Jadikan kota utama" dari lokasi GPS.

---

## 16\. Rencana Pengujian dan Skenario Demo

**Skenario demo berurutan:**

1. Login dengan akun salah (border merah, `SnackBar`), lalu akun benar.  
2. Beranda: loading, cuaca, Skor Payung, chip saran.  
3. Buka Detail; geser cuaca per jam dan 7 hari.  
4. Cari kota baru dan favoritkan (isi 2 sampai 3 favorit dengan jarak berbeda jauh, misalnya Yogyakarta, Semarang, Jakarta).  
5. Tekan **Lokasi Saya**: cuaca titik GPS dan favorit terdekat terurut.  
6. Tolak izin lokasi: tunjukkan pesan, aplikasi tetap berfungsi.  
7. Buat pengingat dengan notifikasi aktif 1 sampai 2 menit ke depan, tutup aplikasi, notifikasi muncul, ketuk untuk membuka Detail.  
8. Ubah dan hapus pengingat; notifikasi lama tidak muncul.  
9. Tambah perlengkapan, ubah jumlah, centang siap.  
10. Matikan internet dan tunjukkan mode offline.  
11. Ganti tema gelap, logout, buka ulang: data dan pengaturan tetap.

**Daftar uji:**

| Area | Yang diuji |
| :---- | :---- |
| Sesi | login, tutup, buka lagi; logout dan tombol back |
| API | sukses, lambat, gagal, data kosong |
| CRUD Hive | tambah, ubah, hapus, persistensi; pengingat lama tetap terbaca setelah model diubah |
| LBS | izin diterima, ditolak, ditolak permanen, GPS mati, tanpa favorit, lokasi palsu di emulator |
| Notifikasi | tampil saat aplikasi ditutup, ketuk membuka halaman benar, edit dan hapus membatalkan jadwal, ID cocok setelah beberapa kali hapus |
| Navigasi | tombol back di tiap halaman, `pushReplacement` dan `pushAndRemoveUntil` |
| Tampilan | beberapa ukuran layar, tanpa overflow, tema terang dan gelap |
| OOP | tiga subclass `WeatherAdvice` menghasilkan keluaran berbeda |
| Perangkat | **uji di HP asli**; periksa pengaturan hemat baterai yang menunda notifikasi |

---

## 17\. Jadwal Kerja

Jadwal ringkas (satu minggu, bisa dilonggarkan). **Wajib** \= memenuhi kriteria; **Opsional** \= bonus jika waktu ada.

| Hari | Loddy | Salsabila | Bersama |
| :---- | :---- | :---- | :---- |
| 1 | Uji API di Postman; `ApiService`, `WeatherData`, `CityResult` (stub) | `main.dart` dengan Hive, model Hive dan adapter, Login, Root | Project dan Git siap; tema dan kontrak disepakati |
| 2 | F2 Beranda (loading, error), `WeatherAdvice` dan F9 | F5 Kota Favorit, F8 Profil dan `SettingsService` | Dua alur utama berjalan |
| 3 | F3 Detail, F4 Cari Kota | F6 Pengingat (CRUD berbasis `key`) | Cari Kota ke Favorit terhubung |
| 4 | F14 Cache offline, F15 langkah 1 sampai 2 (izin, posisi, cuaca lokasi) | F7 Perlengkapan, F16 setup (paket, desugaring, manifest, `init`, tes notifikasi) | Konfigurasi Android beres |
| 5 | F15 langkah 3 sampai 4 (jarak dan urut favorit), penanganan izin | F16 jadwal, ID `key`, batal saat edit dan hapus | LBS dan notifikasi berjalan di HP asli |
| 6 | Banner ekstrem (opsional), perapian UI | Ketuk notifikasi, jadwal ulang saat dibuka, tema gelap | Integrasi final, tinjauan silang |
| 7 | Pengujian, bug | Pengujian, bug | README, laporan, video demo, latihan presentasi |

**Definisi selesai satu fitur:** berjalan tanpa error, kasus gagal ditangani, memenuhi "Selesai bila", sudah ditinjau pasangan, dan masuk ke `main`. F15 dan F16 harus **sudah diuji di perangkat asli**.

---

## 18\. Risiko dan Mitigasi

| Risiko | Dampak | Mitigasi |
| :---- | :---- | :---- |
| Format respons API berbeda dari dugaan | Parsing gagal | Uji di Postman hari pertama; nilai bawaan jika field kosong |
| API tidak tersedia saat demo | Demo macet | Cache offline (F14) dan video demo cadangan |
| Konflik `typeId` atau adapter Hive | Crash saat start | `typeId` hanya di Bagian 8; hanya Salsabila menambah model |
| Field private pada class Hive bermasalah dengan generator | Build gagal | Field public; aturan dijaga lewat method (`increase`, `decrease`) |
| Konfigurasi Android notifikasi tidak lengkap | Notifikasi tidak muncul atau build gagal | Salin Modul VII persis (desugaring, izin, receiver) |
| Notifikasi tertunda di HP hemat baterai | Demo gagal | Uji di HP asli; tombol Tes notifikasi; video cadangan |
| ID notifikasi tidak cocok dengan data | Notifikasi salah batal | ID \= `key` Hive, bukan `index`; batal sebelum hapus |
| Izin lokasi ditolak permanen | Fitur terlihat rusak | Dialog khusus menuju pengaturan aplikasi |
| Lokasi sulit diuji di emulator | LBS tampak tidak jalan | *Extended controls, Location* atau HP asli |
| Konflik Git | Kode saling menimpa | Branch terpisah, satu pemilik per file, tinjauan silang |
| Salah satu bagian terlambat | Integrasi tertunda | Stub sejak awal; cek progres singkat |

---

## 19\. Alur Kerja Git

- Branch: `main` (stabil), `feature-loddy`, `feature-salsabila`. Fitur besar boleh punya branch sendiri.  
- Commit kecil dan sering dengan pesan jelas, misalnya `feat: tambah ApiService.getWeather`.  
- Sebelum merge ke `main`: aplikasi berjalan tanpa error, `flutter analyze` bersih, dan pasangan sudah meninjau.  
- Jangan memasukkan file hasil build; file `.g.dart` **ikut di-commit**.

---

## 20\. Catatan Presentasi

Setiap anggota menjelaskan fitur yang ia pegang, termasuk kodenya.

- **Loddy:** F2, F3, F4, F9, F14, F15. Alur data dari API sampai tampil (fetch, parse, render), OOP `WeatherAdvice`, cache offline, dan GPS.  
  - F15 dalam satu kalimat: *"Posisi dari GPS, hitung jarak ke tiap favorit, urutkan dari yang terdekat, lalu cek cuaca di sana."*  
  - Pertanyaan yang mungkin muncul: kenapa `async/await` (membaca GPS butuh waktu); kenapa ada `try/catch` (GPS mati atau izin ditolak dilempar sebagai exception); rumus jarak (dihitung paket `geolocator`); apakah koordinat disimpan (tidak, hanya dikirim ke Open-Meteo).  
- **Salsabila:** F1, F5, F6, F7, F8, F16. Navigasi dan state, Shared Preferences vs Hive, CRUD, dan penjadwalan notifikasi.  
  - Pertanyaan yang mungkin muncul: kenapa ID notifikasi memakai `key` dan bukan `index`; kenapa notifikasi perlu izin dan receiver; kenapa isi notifikasi dihitung saat dijadwalkan (batasan tanpa latar belakang).  
- Shared Preferences menyimpan data sederhana tanpa enkripsi; Hive dipilih untuk data berstruktur.