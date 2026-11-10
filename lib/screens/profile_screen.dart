import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

// Layar Profil dan Pengaturan (F8 / PBI-023 & PBI-024)
// Menampilkan avatar, nama lengkap (editable), username (read-only), pengaturan, dan logout
class ProfileScreen extends StatefulWidget {
  final VoidCallback? onNameChanged;

  const ProfileScreen({super.key, this.onNameChanged});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _fullName;
  late String _username;
  late String _unit;
  late bool _darkMode;
  late String _mainCity;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    _fullName = SettingsService.fullName;
    _username = SettingsService.username;
    _unit = SettingsService.unit;
    _darkMode = SettingsService.darkMode;
    _mainCity = SettingsService.mainCity;
  }

  // Dialog untuk mengedit Nama Lengkap pengguna
  void _showEditNameDialog() {
    final nameController = TextEditingController(text: _fullName);
    final c = context.pc;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          ),
          title: Text(
            'Ubah Nama Lengkap',
            style: TextStyle(color: c.text, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nama ini akan ditampilkan sebagai sapaan di Beranda dan profil Anda.',
                style: TextStyle(color: c.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Masukkan nama lengkap baru',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Batal', style: TextStyle(color: c.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                if (newName.isEmpty || newName.length < 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Nama lengkap minimal 3 karakter.'),
                      backgroundColor: c.danger,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                // Simpan perubahan ke SharedPreferences
                await SettingsService.setFullName(newName);
                widget.onNameChanged?.call();

                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);

                if (!mounted) return;
                setState(() {
                  _fullName = newName;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nama lengkap berhasil diperbarui.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Dialog konfirmasi Logout (PBI-024)
  void _confirmLogout() {
    final c = context.pc;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          ),
          title: Text(
            'Konfirmasi Keluar',
            style: TextStyle(color: c.text, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin keluar dari akun Payungin?',
            style: TextStyle(color: c.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Batal', style: TextStyle(color: c.textMuted)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                // Hapus status sesi login (PBI-024)
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('loginData', false);

                if (!mounted) return;

                // Navigasi pushAndRemoveUntil agar tidak bisa kembali dengan tombol back
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: Text(
                'Keluar',
                style: TextStyle(color: c.danger, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.pc;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Profil & Pengaturan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        child: Column(
          children: [
            // 1. Kartu Header Profil Pengguna
            GlassCard(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Avatar Pengguna
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [c.heroA, c.heroB],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: c.accent.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _fullName.isNotEmpty ? _fullName[0].toUpperCase() : 'P',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Nama Lengkap dengan Ikon Edit
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          _fullName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: c.text,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: _showEditNameDialog,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: c.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Username (Badge Terkunci / Read-Only)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: c.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusChip),
                      border: Border.all(color: c.glassBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_outline_rounded, size: 12, color: c.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '@$_username',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: c.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Kartu Pengaturan Preferensi
            GlassCard(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengaturan Tampilan & Cuaca',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: c.accent,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Satuan Suhu (C / F)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.thermostat_rounded, size: 22, color: c.text),
                          const SizedBox(width: 12),
                          Text(
                            'Satuan Suhu',
                            style: TextStyle(fontSize: 15, color: c.text),
                          ),
                        ],
                      ),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'C', label: Text('°C')),
                          ButtonSegment(value: 'F', label: Text('°F')),
                        ],
                        selected: {_unit},
                        onSelectionChanged: (newSelection) async {
                          final selected = newSelection.first;
                          await SettingsService.setUnit(selected);
                          setState(() {
                            _unit = selected;
                          });
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Mode Gelap
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _darkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                            size: 22,
                            color: c.text,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Mode Gelap',
                            style: TextStyle(fontSize: 15, color: c.text),
                          ),
                        ],
                      ),
                      Switch(
                        value: _darkMode,
                        onChanged: (val) async {
                          final messenger = ScaffoldMessenger.of(context);
                          await SettingsService.setDarkMode(val);
                          if (!mounted) return;
                          setState(() {
                            _darkMode = val;
                          });
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                val ? 'Mode gelap diaktifkan (Sprint 6).' : 'Mode terang diaktifkan.',
                              ),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Kota Utama
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_city_rounded, size: 22, color: c.text),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kota Utama',
                                style: TextStyle(fontSize: 15, color: c.text),
                              ),
                              Text(
                                _mainCity,
                                style: TextStyle(fontSize: 12, color: c.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        '${SettingsService.mainLat}, ${SettingsService.mainLon}',
                        style: TextStyle(fontSize: 12, color: c.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Kartu Notifikasi & Sistem
            GlassCard(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: c.accent.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.notifications_active_outlined, color: c.accent),
                    ),
                    title: Text(
                      'Tes Notifikasi',
                      style: TextStyle(fontWeight: FontWeight.w600, color: c.text),
                    ),
                    subtitle: Text(
                      'Coba kirimkan notifikasi pengingat payung',
                      style: TextStyle(fontSize: 12, color: c.textMuted),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      NotificationService().showNow(
                        'Payungin - Tes Notifikasi',
                        'Halo $_fullName, ini adalah contoh notifikasi cuaca Payungin.',
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifikasi telah dikirim ke konsol/layar.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Tombol Logout (PBI-024)
            OutlinedButton.icon(
              onPressed: _confirmLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: c.danger,
                side: BorderSide(color: c.danger.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                ),
              ),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text(
                'Keluar dari Akun',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

