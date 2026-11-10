import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/reminder.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'add_reminder_screen.dart';

// Layar Daftar Pengingat Cuaca (F6 / PBI-032 & PBI-034)
// Menampilkan daftar pengingat reaktif dari box Hive 'reminders' berbasis key
class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  // Dialog konfirmasi hapus pengingat dengan aturan ID berbasis key Hive (PBI-034)
  void _confirmDelete(BuildContext context, Reminder reminder) {
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
            'Hapus Pengingat',
            style: TextStyle(color: c.text, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus pengingat "${reminder.title}"?',
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

                // Aturan PBI-034: batalkan notifikasi sebelum menghapus data Hive
                final reminderKey = reminder.key;
                if (reminderKey is int) {
                  NotificationService().cancel(reminderKey);
                }

                // Hapus objek dari Hive
                await reminder.delete();

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pengingat berhasil dihapus.'),
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

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final box = Hive.box<Reminder>('reminders');

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Pengingat Cuaca'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: c.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Buat Pengingat', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReminderScreen()),
          );
        },
      ),
      body: ValueListenableBuilder<Box<Reminder>>(
        valueListenable: box.listenable(),
        builder: (context, reminderBox, _) {
          // Tampilan kosong jika belum ada pengingat
          if (reminderBox.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: GlassCard(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_none_rounded,
                        size: 64,
                        color: c.accent.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum Ada Pengingat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: c.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Buat pengingat agar Anda siap sedia membawa payung sebelum beraktivitas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: c.textMuted, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddReminderScreen()),
                          );
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Tambah Pengingat Pertama'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Daftar Kartu Pengingat
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 88),
            itemCount: reminderBox.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final reminder = reminderBox.getAt(index);
              if (reminder == null) return const SizedBox.shrink();

              return GlassCard(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris Atas: Jam dan Status Notifikasi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 20, color: c.accent),
                            const SizedBox(width: 8),
                            Text(
                              '${reminder.time} WIB',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: c.text,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),

                        // Chip status notifikasi
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: reminder.notifOn ? c.chipBg : c.glass,
                            borderRadius: BorderRadius.circular(AppTheme.radiusChip),
                            border: Border.all(color: c.glassBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                reminder.notifOn
                                    ? Icons.notifications_active_rounded
                                    : Icons.notifications_off_outlined,
                                size: 14,
                                color: reminder.notifOn ? c.chipText : c.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                reminder.notifOn
                                    ? (reminder.repeatDaily ? 'Setiap Hari' : 'Sekali')
                                    : 'Mati',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: reminder.notifOn ? c.chipText : c.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Baris Judul & Kota
                    Text(
                      reminder.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: c.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: c.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          reminder.cityName,
                          style: TextStyle(fontSize: 13, color: c.textMuted),
                        ),
                      ],
                    ),

                    // Catatan Tambahan (jika ada)
                    if (reminder.note.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: c.glass,
                          borderRadius: BorderRadius.circular(AppTheme.radiusChip),
                          border: Border.all(color: c.glassBorder),
                        ),
                        child: Text(
                          reminder.note,
                          style: TextStyle(fontSize: 12, color: c.text, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Tombol Aksi: Ubah & Hapus
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddReminderScreen(reminder: reminder),
                              ),
                            );
                          },
                          icon: Icon(Icons.edit_outlined, size: 16, color: c.accent),
                          label: Text('Ubah', style: TextStyle(color: c.accent)),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () => _confirmDelete(context, reminder),
                          icon: Icon(Icons.delete_outline_rounded, size: 16, color: c.danger),
                          label: Text('Hapus', style: TextStyle(color: c.danger)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

