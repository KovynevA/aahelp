import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemePreset {
  breeze,
  terracotta,
  midnight,
}

extension AppThemePresetPresentation on AppThemePreset {
  String get label {
    switch (this) {
      case AppThemePreset.breeze:
        return 'Воздух';
      case AppThemePreset.terracotta:
        return 'Тепло';
      case AppThemePreset.midnight:
        return 'Ночь';
    }
  }

  String get subtitle {
    switch (this) {
      case AppThemePreset.breeze:
        return 'Светлая и спокойная';
      case AppThemePreset.terracotta:
        return 'Тёплая и мягкая';
      case AppThemePreset.midnight:
        return 'Контрастная вечерняя';
    }
  }
}

class AppThemeController extends ValueNotifier<AppThemePreset> {
  AppThemeController._() : super(AppThemePreset.breeze);

  static final AppThemeController instance = AppThemeController._();
  static const String _storageKey = 'aahelp.theme_preset';
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  Future<void> load() async {
    final savedPresetName = await _preferences.getString(_storageKey);
    if (savedPresetName == null) {
      return;
    }

    for (final preset in AppThemePreset.values) {
      if (preset.name == savedPresetName) {
        if (value != preset) {
          value = preset;
        }
        return;
      }
    }
  }

  void setPreset(AppThemePreset preset) {
    if (value != preset) {
      value = preset;
    }
    unawaited(_preferences.setString(_storageKey, preset.name));
  }
}

@immutable
class AaThemePalette extends ThemeExtension<AaThemePalette> {
  const AaThemePalette({
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceStrong,
    required this.border,
    required this.accent,
    required this.accentSecondary,
    required this.accentSoft,
    required this.heroStart,
    required this.heroEnd,
    required this.success,
    required this.warning,
    required this.shadow,
    required this.isDark,
  });

  final Color backgroundTop;
  final Color backgroundBottom;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceStrong;
  final Color border;
  final Color accent;
  final Color accentSecondary;
  final Color accentSoft;
  final Color heroStart;
  final Color heroEnd;
  final Color success;
  final Color warning;
  final Color shadow;
  final bool isDark;

  @override
  AaThemePalette copyWith({
    Color? backgroundTop,
    Color? backgroundBottom,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceStrong,
    Color? border,
    Color? accent,
    Color? accentSecondary,
    Color? accentSoft,
    Color? heroStart,
    Color? heroEnd,
    Color? success,
    Color? warning,
    Color? shadow,
    bool? isDark,
  }) {
    return AaThemePalette(
      backgroundTop: backgroundTop ?? this.backgroundTop,
      backgroundBottom: backgroundBottom ?? this.backgroundBottom,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      surfaceStrong: surfaceStrong ?? this.surfaceStrong,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      accentSecondary: accentSecondary ?? this.accentSecondary,
      accentSoft: accentSoft ?? this.accentSoft,
      heroStart: heroStart ?? this.heroStart,
      heroEnd: heroEnd ?? this.heroEnd,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      shadow: shadow ?? this.shadow,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AaThemePalette lerp(ThemeExtension<AaThemePalette>? other, double t) {
    if (other is! AaThemePalette) {
      return this;
    }

    return AaThemePalette(
      backgroundTop: Color.lerp(backgroundTop, other.backgroundTop, t)!,
      backgroundBottom:
          Color.lerp(backgroundBottom, other.backgroundBottom, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      surfaceStrong: Color.lerp(surfaceStrong, other.surfaceStrong, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSecondary:
          Color.lerp(accentSecondary, other.accentSecondary, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      heroStart: Color.lerp(heroStart, other.heroStart, t)!,
      heroEnd: Color.lerp(heroEnd, other.heroEnd, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

ThemeData buildAppTheme(AppThemePreset preset) {
  final palette = themePaletteForPreset(preset);
  final colorScheme = ColorScheme.fromSeed(
    seedColor: palette.accent,
    brightness: palette.isDark ? Brightness.dark : Brightness.light,
  ).copyWith(
    primary: palette.accent,
    secondary: palette.accentSecondary,
    tertiary: palette.heroEnd,
    surface: palette.surface,
    surfaceContainerHighest: palette.surfaceStrong,
    outlineVariant: palette.border,
    error: const Color(0xFFB42318),
  );

  final base = palette.isDark ? ThemeData.dark() : ThemeData.light();
  final textTheme = GoogleFonts.manropeTextTheme(base.textTheme).copyWith(
    displaySmall: GoogleFonts.sora(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      height: 1.05,
      color: colorScheme.onSurface,
    ),
    headlineMedium: GoogleFonts.sora(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.15,
      color: colorScheme.onSurface,
    ),
    titleLarge: GoogleFonts.sora(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: colorScheme.onSurface,
    ),
    titleMedium: GoogleFonts.manrope(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: colorScheme.onSurface,
    ),
    bodyLarge: GoogleFonts.manrope(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.45,
      color: colorScheme.onSurface,
    ),
    bodyMedium: GoogleFonts.manrope(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.45,
      color: colorScheme.onSurface.withValues(alpha: 0.86),
    ),
    labelLarge: GoogleFonts.manrope(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.15,
      color: colorScheme.onSurface,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: palette.isDark ? Brightness.dark : Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: textTheme,
    dividerColor: palette.border,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: textTheme.titleLarge,
      foregroundColor: colorScheme.onSurface,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: palette.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(
          color: palette.border.withValues(alpha: 0.7),
        ),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.surfaceMuted.withValues(alpha: 0.9),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.52),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: palette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(
          color: palette.accent,
          width: 1.4,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        textStyle: textTheme.labelLarge,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        backgroundColor: palette.accent,
        foregroundColor: colorScheme.onPrimary,
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        side: BorderSide(color: palette.border),
        textStyle: textTheme.labelLarge,
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      side: BorderSide(color: palette.border),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: palette.surfaceMuted,
      selectedColor: palette.accentSoft,
      labelStyle: textTheme.labelLarge,
      secondaryLabelStyle: textTheme.labelLarge?.copyWith(
        color: colorScheme.onSecondaryContainer,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: palette.surfaceStrong,
      contentTextStyle: textTheme.bodyMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      titleTextStyle: textTheme.headlineMedium,
      contentTextStyle: textTheme.bodyMedium,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: palette.surface.withValues(alpha: 0.92),
      indicatorColor: palette.accentSoft,
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return textTheme.bodySmall?.copyWith(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSecondaryContainer,
          );
        }
        return textTheme.bodySmall?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface.withValues(alpha: 0.66),
        );
      }),
    ),
    extensions: <ThemeExtension<dynamic>>[
      palette,
    ],
  );
}

AaThemePalette themePaletteForPreset(AppThemePreset preset) {
  switch (preset) {
    case AppThemePreset.breeze:
      return const AaThemePalette(
        backgroundTop: Color(0xFFF4F8FF),
        backgroundBottom: Color(0xFFE6F0EC),
        surface: Color(0xFFFDFEFF),
        surfaceMuted: Color(0xFFF3F7FA),
        surfaceStrong: Color(0xFFEAF1F5),
        border: Color(0xFFD3DFE6),
        accent: Color(0xFF2F6B7A),
        accentSecondary: Color(0xFF3E8B8A),
        accentSoft: Color(0xFFD4EDEA),
        heroStart: Color(0xFF8EC5FC),
        heroEnd: Color(0xFFCFE7D2),
        success: Color(0xFF1F8A62),
        warning: Color(0xFFB7791F),
        shadow: Color(0x1F11334E),
        isDark: false,
      );
    case AppThemePreset.terracotta:
      return const AaThemePalette(
        backgroundTop: Color(0xFFFFF7F0),
        backgroundBottom: Color(0xFFF6ECE6),
        surface: Color(0xFFFFFCFA),
        surfaceMuted: Color(0xFFF9F0EA),
        surfaceStrong: Color(0xFFF2E5DD),
        border: Color(0xFFE5D1C5),
        accent: Color(0xFF9C5C41),
        accentSecondary: Color(0xFFD4835B),
        accentSoft: Color(0xFFF7D9C8),
        heroStart: Color(0xFFF6B98A),
        heroEnd: Color(0xFFECC7A1),
        success: Color(0xFF547A2E),
        warning: Color(0xFFBA6B1E),
        shadow: Color(0x1F4C2C1A),
        isDark: false,
      );
    case AppThemePreset.midnight:
      return const AaThemePalette(
        backgroundTop: Color(0xFF0E1525),
        backgroundBottom: Color(0xFF141C2F),
        surface: Color(0xFF152033),
        surfaceMuted: Color(0xFF1A2840),
        surfaceStrong: Color(0xFF21314A),
        border: Color(0xFF30465F),
        accent: Color(0xFF6BD3C0),
        accentSecondary: Color(0xFF8DB7FF),
        accentSoft: Color(0xFF1F3C46),
        heroStart: Color(0xFF274690),
        heroEnd: Color(0xFF1B998B),
        success: Color(0xFF3DD598),
        warning: Color(0xFFF2A65A),
        shadow: Color(0x40000000),
        isDark: true,
      );
  }
}

extension AppThemeContext on BuildContext {
  AaThemePalette get appPalette =>
      Theme.of(this).extension<AaThemePalette>()!;
}
