import 'dart:ui';

import 'package:flutter/material.dart';

/// Tema Payungin: kartu bulat biru lembut dengan efek kaca (glassy),
/// mendukung mode terang dan gelap.
///
/// Cara pakai:
///   MaterialApp(
///     theme: AppTheme.light,
///     darkTheme: AppTheme.dark,
///     themeMode: ...,            // dari SettingsService (F8)
///   )
///
/// Di widget: `final c = context.pc;` lalu `c.text`, `c.accent`, dst.
/// Layar penuh dibungkus `GlassScaffold`, kartu memakai `GlassCard`.

// ---------------------------------------------------------------------------
// Token warna (ThemeExtension) agar bisa diakses lewat context.pc
// ---------------------------------------------------------------------------
@immutable
class PayunginColors extends ThemeExtension<PayunginColors> {
  final Color bgTop;
  final Color bgMid;
  final Color bgBottom;
  final Color blobA;
  final Color blobB;
  final double blobOpacity;
  final Color glass;
  final Color glassBorder;
  final Color glassShadow;
  final Color heroA;
  final Color heroB;
  final Color accent;
  final Color onAccent;
  final Color text;
  final Color textMuted;
  final Color chipBg;
  final Color chipText;
  final Color scoreGood; // Skor Payung < 30
  final Color scoreWarn; // 30 sampai 59
  final Color scoreBad; // 60 ke atas
  final Color danger;

  const PayunginColors({
    required this.bgTop,
    required this.bgMid,
    required this.bgBottom,
    required this.blobA,
    required this.blobB,
    required this.blobOpacity,
    required this.glass,
    required this.glassBorder,
    required this.glassShadow,
    required this.heroA,
    required this.heroB,
    required this.accent,
    required this.onAccent,
    required this.text,
    required this.textMuted,
    required this.chipBg,
    required this.chipText,
    required this.scoreGood,
    required this.scoreWarn,
    required this.scoreBad,
    required this.danger,
  });

  static const light = PayunginColors(
    bgTop: Color(0xFFD6E8FF),
    bgMid: Color(0xFFEAF3FF),
    bgBottom: Color(0xFFF6FAFF),
    blobA: Color(0xFF8DB8FF),
    blobB: Color(0xFFB9D6FF),
    blobOpacity: 0.7,
    glass: Color(0x94FFFFFF), // putih 58%
    glassBorder: Color(0xD9FFFFFF), // putih 85%
    glassShadow: Color(0x243462BE),
    heroA: Color(0xFF2A5BDB),
    heroB: Color(0xFF3A70EA),
    accent: Color(0xFF2A62F0),
    onAccent: Color(0xFFFFFFFF),
    text: Color(0xFF10244A),
    textMuted: Color(0xFF4A5F8A),
    chipBg: Color(0x1C2A62F0),
    chipText: Color(0xFF1F4FD0),
    scoreGood: Color(0xFF1E9E63),
    scoreWarn: Color(0xFFC98A00),
    scoreBad: Color(0xFFD83A3F),
    danger: Color(0xFFD83A3F),
  );

  static const dark = PayunginColors(
    bgTop: Color(0xFF0A1530),
    bgMid: Color(0xFF0E1E42),
    bgBottom: Color(0xFF13265A),
    blobA: Color(0xFF2F63E0),
    blobB: Color(0xFF1E49B8),
    blobOpacity: 0.5,
    glass: Color(0x851E3262), // biru gelap 52%
    glassBorder: Color(0x2E96BEFF),
    glassShadow: Color(0x59000000),
    heroA: Color(0xFF27479F),
    heroB: Color(0xFF3A63C9),
    accent: Color(0xFF6C97FF),
    onAccent: Color(0xFF08142E),
    text: Color(0xFFEAF1FF),
    textMuted: Color(0xFFA8BBE3),
    chipBg: Color(0x2E6C97FF),
    chipText: Color(0xFFBCD1FF),
    scoreGood: Color(0xFF3DD68C),
    scoreWarn: Color(0xFFF5C542),
    scoreBad: Color(0xFFFF6B6B),
    danger: Color(0xFFFF6B6B),
  );

  /// Warna kartu Skor Payung (F9): hijau, kuning, merah.
  Color scoreColor(int score) {
    if (score >= 60) return scoreBad;
    if (score >= 30) return scoreWarn;
    return scoreGood;
  }

  @override
  PayunginColors copyWith() => this;

  @override
  PayunginColors lerp(ThemeExtension<PayunginColors>? other, double t) {
    if (other is! PayunginColors) return this;
    return t < 0.5 ? this : other;
  }
}

/// Akses cepat: `context.pc.accent`
extension PayunginThemeX on BuildContext {
  PayunginColors get pc => Theme.of(this).extension<PayunginColors>()!;
}

// ---------------------------------------------------------------------------
// ThemeData
// ---------------------------------------------------------------------------
class AppTheme {
  AppTheme._();

  // Radius baku (sesuai panduan gaya)
  static const double radiusCard = 28;
  static const double radiusButton = 22;
  static const double radiusField = 20;
  static const double radiusChip = 14;

  // Jarak baku
  static const double gap = 14; // antar kartu
  static const double edge = 18; // dari tepi layar

  static ThemeData get light => _build(Brightness.light, PayunginColors.light);
  static ThemeData get dark => _build(Brightness.dark, PayunginColors.dark);

  static ThemeData _build(Brightness b, PayunginColors c) {
    final scheme = ColorScheme.fromSeed(
      seedColor: c.accent,
      brightness: b,
    ).copyWith(
      primary: c.accent,
      onPrimary: c.onAccent,
      surface: c.bgMid,
      onSurface: c.text,
      error: c.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: scheme,
      extensions: [c],
      // Latar transparan: gradien digambar oleh GlassScaffold.
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: Colors.transparent,
      textTheme: ThemeData(brightness: b).textTheme.apply(
            bodyColor: c.text,
            displayColor: c.text,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: c.text,
        titleTextStyle: TextStyle(
          color: c.text,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.onAccent,
          minimumSize: const Size.fromHeight(52),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.accent,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: c.glassBorder),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.accent,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.accent,
        foregroundColor: c.onAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusButton),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.glass,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: c.textMuted, fontWeight: FontWeight.w600),
        hintStyle: TextStyle(color: c.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusField),
          borderSide: BorderSide(color: c.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusField),
          borderSide: BorderSide(color: c.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusField),
          borderSide: BorderSide(color: c.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusField),
          borderSide: BorderSide(color: c.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusField),
          borderSide: BorderSide(color: c.danger, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: c.accent,
        unselectedItemColor: c.textMuted,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.heroA,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusField),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.onAccent : c.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? c.accent : c.chipBg,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      dividerColor: c.glassBorder,
    );
  }
}

// ---------------------------------------------------------------------------
// Widget bersama
// ---------------------------------------------------------------------------

/// Latar gradien biru dengan dua "blob" lembut. Dipakai oleh [GlassScaffold].
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [c.bgTop, c.bgMid, c.bgBottom],
              ),
            ),
          ),
        ),
        Positioned(top: -80, right: -90, child: _Blob(color: c.blobA, size: 300, opacity: c.blobOpacity)),
        Positioned(bottom: 120, left: -100, child: _Blob(color: c.blobB, size: 280, opacity: c.blobOpacity)),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;
  const _Blob({required this.color, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withAlpha((opacity * 255).round()),
              color.withAlpha(0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Scaffold dengan latar gradien. Pakai di setiap layar penuh
/// (Login, Root, Detail, Cari Kota, form). Layar tab di dalam Root
/// cukup memakai `Scaffold` biasa karena Root sudah memberi latar.
class GlassScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool extendBodyBehindAppBar;

  const GlassScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.extendBodyBehindAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
      ),
    );
  }
}

/// Kartu kaca (blur + border tipis + bayangan lembut).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = AppTheme.radiusCard,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final borderRadius = BorderRadius.circular(radius);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(color: c.glassShadow, blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Material(
            color: c.glass,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
              side: BorderSide(color: c.glassBorder),
            ),
            child: InkWell(
              onTap: onTap,
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kartu utama berlatar gradien biru (dipakai Beranda). Teks di dalamnya putih.
class HeroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const HeroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    final borderRadius = BorderRadius.circular(AppTheme.radiusCard + 2);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.heroA, c.heroB],
        ),
        border: Border.all(color: const Color(0x47FFFFFF)),
        boxShadow: [
          BoxShadow(
            color: c.heroA.withAlpha(90),
            blurRadius: 36,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Chip kecil untuk saran singkat (F9) atau label.
class InfoChip extends StatelessWidget {
  final String label;
  final IconData? icon;

  const InfoChip({super.key, required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    final c = context.pc;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: c.chipBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusChip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: c.chipText),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: c.chipText,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
