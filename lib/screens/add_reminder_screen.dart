import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/favorite_city.dart';
import '../models/reminder.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/input_field.dart';

// Layar Form Tambah dan Ubah Pengingat Cuaca (F6 / PBI-033)
// Mendukung mode tambah baru dan edit data berbasis Hive key
class AddReminderScreen extends StatefulWidget {
  final int? index;
  final Reminder? reminder;
  final String? judulAwal;
  final String? kotaAwal;

  const AddReminderScreen({
    super.key,
    this.index,
    this.reminder,
    this.judulAwal,
    this.kotaAwal,
  });

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _cityNameController;
  late final TextEditingController _noteController;

  late bool _isEditMode;
  late String _selectedTime;
  late double _lat;
  late double _lon;
  late bool _notifOn;
  late bool _repeatDaily;

  bool _isTitleError = false;
  bool _isCityError = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.reminder != null;

    final r = widget.reminder;
    _titleController = TextEditingController(
      text: r?.title ?? widget.judulAwal ?? '',
    );
    _cityNameController = TextEditingController(
      text: r?.cityName ?? widget.kotaAwal ?? SettingsService.mainCity,
    );
    _noteController = TextEditingController(text: r?.note ?? '');

    _selectedTime = r?.time ?? '07:00';
    _lat = r?.lat ?? SettingsService.mainLat;
    _lon = r?.lon ?? SettingsService.mainLon;
    _notifOn = r?.notifOn ?? true;
    _repeatDaily = r?.repeatDaily ?? false;
  }

  @override
  void dispose() {
    // Penyelamatan memori: wajib dispose controller sesuai aturan PBI-033
    _titleController.dispose();
    _cityNameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Pemilih jam menggunakan showTimePicker format 24 jam Indonesia (tanpa AM/PM)
  Future<void> _pickTime() async {
    final parts = _selectedTime.split(':');
    final initialHour = int.tryParse(parts[0]) ?? 7;
    final initialMinute = int.tryParse(parts[1]) ?? 0;

    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
      builder: (context, child) {
        // Memaksa format 24 jam waktu Indonesia (00:00 s.d 23:59 tanpa AM/PM)
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      final hourStr = picked.hour.toString().padLeft(2, '0');
      final minuteStr = picked.minute.toString().padLeft(2, '0');
      setState(() {
        _selectedTime = '$hourStr:$minuteStr';
      });
    }
  }

  // Pilih koordinat otomatis dari daftar Kota Favorit yang ada di Hive
  void _selectFromFavorites(FavoriteCity city) {
    setState(() {
      _cityNameController.text = city.name;
      _lat = city.lat;
      _lon = city.lon;
      _isCityError = false;
    });
  }

  // Proses simpan pengingat (tambah baru atau simpan perubahan)
  Future<void> _saveReminder() async {
    final title = _titleController.text.trim();
    final cityName = _cityNameController.text.trim();
    final note = _noteController.text.trim();

    setState(() {
      _isTitleError = false;
      _isCityError = false;
    });

    // Validator form tidak boleh kosong
    if (title.isEmpty) {
      setState(() => _isTitleError = true);
      _showSnackBar('Judul pengingat tidak boleh kosong.');
      return;
    }

    if (cityName.isEmpty) {
      setState(() => _isCityError = true);
      _showSnackBar('Nama kota tidak boleh kosong.');
      return;
    }

    final box = Hive.box<Reminder>('reminders');

    if (_isEditMode) {
      // 1. Mode Edit: perbarui object pengingat dan simpan
      final r = widget.reminder!;
      r.title = title;
      r.cityName = cityName;
      r.lat = _lat;
      r.lon = _lon;
      r.time = _selectedTime;
      r.note = note;
      r.notifOn = _notifOn;
      r.repeatDaily = _repeatDaily;

      await r.save();

      // Aturan ID berbasis key (PBI-034): batalkan jadwal lama sebelum menjadwalkan ulang
      final reminderKey = r.key;
      if (reminderKey is int) {
        NotificationService().cancel(reminderKey);
      }

      if (_notifOn) {
        NotificationService().schedule(r, Object());
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengingat berhasil diperbarui.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // 2. Mode Tambah Baru: buat objek dan simpan dengan box.add (PBI-034)
      final newReminder = Reminder(
        title: title,
        cityName: cityName,
        lat: _lat,
        lon: _lon,
        time: _selectedTime,
        note: note,
        notifOn: _notifOn,
        repeatDaily: _repeatDaily,
      );

      await box.add(newReminder);

      // Jadwalkan notifikasi jika opsi notifikasi aktif
      if (_notifOn) {
        NotificationService().schedule(newReminder, Object());
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengingat berhasil disimpan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    Navigator.pop(context);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.pc.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final favoriteBox = Hive.box<FavoriteCity>('favorites');

    return GlassScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // AppBar kustom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: c.text),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isEditMode ? 'Ubah Pengingat' : 'Tambah Pengingat',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: c.text,
                    ),
                  ),
                ],
              ),
            ),

            // Konten Formulir
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Kartu Input Data Utama
                    GlassCard(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Judul Pengingat
                          InputField(
                            controller: _titleController,
                            label: 'Judul Pengingat',
                            hint: 'Misal: Bawa payung sebelum kuliah',
                            prefixIcon: Icons.alarm_outlined,
                            isError: _isTitleError,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) {
                              if (_isTitleError) setState(() => _isTitleError = false);
                            },
                          ),
                          const SizedBox(height: 18),

                          // Nama Kota
                          InputField(
                            controller: _cityNameController,
                            label: 'Kota Pemantauan',
                            hint: 'Masukkan nama kota',
                            prefixIcon: Icons.location_city_rounded,
                            isError: _isCityError,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) {
                              if (_isCityError) setState(() => _isCityError = false);
                            },
                          ),
                          const SizedBox(height: 10),

                          // Tombol Cepat: Pilih dari Kota Favorit
                          if (favoriteBox.isNotEmpty) ...[
                            Text(
                              'Pilih cepat dari Kota Favorit:',
                              style: TextStyle(fontSize: 12, color: c.textMuted),
                            ),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: favoriteBox.values.map((city) {
                                  final isSelected = _cityNameController.text == city.name;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ActionChip(
                                      avatar: Icon(
                                        Icons.star_rounded,
                                        size: 16,
                                        color: isSelected ? Colors.white : c.accent,
                                      ),
                                      label: Text(city.name),
                                      backgroundColor: isSelected ? c.accent : c.chipBg,
                                      labelStyle: TextStyle(
                                        color: isSelected ? Colors.white : c.chipText,
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                      onPressed: () => _selectFromFavorites(city),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],

                          // Pemilih Jam Pengingat
                          Text(
                            'Waktu Pengingat',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: c.text,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _pickTime,
                            borderRadius: BorderRadius.circular(AppTheme.radiusField),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: c.glass,
                                borderRadius: BorderRadius.circular(AppTheme.radiusField),
                                border: Border.all(color: c.glassBorder),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.access_time_rounded, color: c.accent, size: 22),
                                      const SizedBox(width: 12),
                                      Text(
                                        '$_selectedTime WIB',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: c.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Pilih Jam',
                                    style: TextStyle(fontSize: 13, color: c.accent, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Catatan Tambahan
                          InputField(
                            controller: _noteController,
                            label: 'Catatan Tambahan (Opsional)',
                            hint: 'Misal: Simpan jas hujan di jok motor',
                            prefixIcon: Icons.notes_rounded,
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Kartu Pengaturan Notifikasi
                    GlassCard(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Aktifkan Notifikasi',
                              style: TextStyle(fontWeight: FontWeight.w600, color: c.text),
                            ),
                            subtitle: Text(
                              'Munculkan pemberitahuan cuaca pada jam yang ditentukan',
                              style: TextStyle(fontSize: 12, color: c.textMuted),
                            ),
                            value: _notifOn,
                            onChanged: (val) {
                              setState(() => _notifOn = val);
                            },
                          ),
                          const Divider(),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              'Ulangi Setiap Hari',
                              style: TextStyle(fontWeight: FontWeight.w600, color: c.text),
                            ),
                            subtitle: Text(
                              'Bunyikan notifikasi setiap hari pada jam yang sama',
                              style: TextStyle(fontSize: 12, color: c.textMuted),
                            ),
                            value: _repeatDaily,
                            onChanged: _notifOn
                                ? (val) {
                                    setState(() => _repeatDaily = val);
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Simpan
                    ElevatedButton(
                      onPressed: _saveReminder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                        ),
                      ),
                      child: Text(
                        _isEditMode ? 'Simpan Perubahan' : 'Buat Pengingat',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
