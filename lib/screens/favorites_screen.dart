import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/favorite_city.dart';
import '../theme/app_theme.dart';

// Layar Kota Favorit (F5 / PBI-022)
// Menampilkan grid kota favorit dari box Hive 'favorites'
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  // Fungsi kontrak publik untuk menyimpan kota favorit (dipanggil juga dari F4 Cari Kota oleh Loddy)
  // Memeriksa duplikat nama dan provinsi, lalu menampilkan SnackBar feedback
  static bool saveFavoriteCity(
    BuildContext context, {
    required String name,
    required String province,
    required double lat,
    required double lon,
  }) {
    final box = Hive.box<FavoriteCity>('favorites');

    // Pencegahan duplikat berdasarkan nama dan provinsi
    final isDuplicate = box.values.any((c) =>
        c.name.trim().toLowerCase() == name.trim().toLowerCase() &&
        c.province.trim().toLowerCase() == province.trim().toLowerCase());

    if (isDuplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kota "$name" sudah ada di daftar favorit.'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return false;
    }

    // Simpan ke box Hive
    box.add(FavoriteCity(
      name: name.trim(),
      province: province.trim(),
      lat: lat,
      lon: lon,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kota "$name" berhasil ditambahkan ke favorit.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return true;
  }

  // Dialog konfirmasi sebelum menghapus kota favorit sesuai aturan Dokumen Final
  void _confirmDelete(
    BuildContext context,
    Box<FavoriteCity> box,
    int index,
    String cityName,
  ) {
    final c = context.pc;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            'Hapus Favorit',
            style: TextStyle(color: c.text, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus "$cityName" dari kota favorit?',
            style: TextStyle(color: c.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Batal', style: TextStyle(color: c.textMuted)),
            ),
            TextButton(
              onPressed: () {
                box.deleteAt(index);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Kota "$cityName" telah dihapus.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                'Hapus',
                style: TextStyle(color: c.danger, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Dialog bantu tambah kota uji (mempermudah pengujian sebelum Cari Kota Loddy selesai)
  void _showAddCityDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final provinceCtrl = TextEditingController();
    final latCtrl = TextEditingController(text: '-7.79');
    final lonCtrl = TextEditingController(text: '110.36');
    final c = context.pc;

    showDialog(
      context: context,
      builder: (dContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text(
            'Tambah Kota Favorit',
            style: TextStyle(color: c.text, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kota',
                    hintText: 'Misal: Sleman',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: provinceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Provinsi',
                    hintText: 'Misal: D.I. Yogyakarta',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: latCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: const InputDecoration(labelText: 'Latitude'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lonCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: const InputDecoration(labelText: 'Longitude'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dContext),
              child: Text('Batal', style: TextStyle(color: c.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final prov = provinceCtrl.text.trim();
                final lat = double.tryParse(latCtrl.text.trim()) ?? 0.0;
                final lon = double.tryParse(lonCtrl.text.trim()) ?? 0.0;

                if (name.isEmpty) return;

                Navigator.pop(dContext);
                saveFavoriteCity(
                  context,
                  name: name,
                  province: prov.isEmpty ? 'Indonesia' : prov,
                  lat: lat,
                  lon: lon,
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final box = Hive.box<FavoriteCity>('favorites');

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Kota Favorit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Tambah Kota Uji',
            onPressed: () => _showAddCityDialog(context),
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<FavoriteCity>>(
        valueListenable: box.listenable(),
        builder: (context, favBox, _) {
          // Tampilan kosong jika belum ada kota favorit
          if (favBox.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: GlassCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 64,
                        color: c.accent.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum Ada Kota Favorit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: c.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kota favorit yang Anda simpan akan muncul di sini. Anda juga bisa menekan tombol + di atas untuk menambah kota uji.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: c.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Grid kota favorit
          return GridView.builder(
            padding: const EdgeInsets.all(18.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.95,
            ),
            itemCount: favBox.length,
            itemBuilder: (context, index) {
              final city = favBox.getAt(index);
              if (city == null) return const SizedBox.shrink();

              return GestureDetector(
                onTap: () {
                  // TODO (Sprint 3 / Loddy PBI-026): Navigasi ke DetailScreen saat file Loddy sudah siap
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Membuka detail cuaca ${city.name} (Sprint 3).',
                      ),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: GlassCard(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 26,
                            color: c.accent,
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _confirmDelete(context, favBox, index, city.name),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: c.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            city.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: c.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            city.province,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: c.textMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${city.lat.toStringAsFixed(2)}, ${city.lon.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: c.textMuted.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

