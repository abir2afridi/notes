import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import '../../presentation/providers/settings_providers.dart';
import 'app_theme.dart';

// Vibrant theme definitions
class VibrantThemes {
  static const Map<String, Map<String, Color>> themes = {
    'default': {
      'primary': Color(0xFF6750A4),
      'secondary': Color(0xFF625B71),
      'tertiary': Color(0xFF7D5260),
    },
    'ocean': {
      'primary': Color(0xFF0061A4),
      'secondary': Color(0xFF006496),
      'tertiary': Color(0xFF735D0C),
    },
    'forest': {
      'primary': Color(0xFF3E665D),
      'secondary': Color(0xFF4D7269),
      'tertiary': Color(0xFF645A4C),
    },
    'sunset': {
      'primary': Color(0xFFB5261E),
      'secondary': Color(0xFF8B5000),
      'tertiary': Color(0xFF6C5E00),
    },
    'purple': {
      'primary': Color(0xFF8257E5),
      'secondary': Color(0xFF6B4E8A),
      'tertiary': Color(0xFF8D4E00),
    },
    'teal': {
      'primary': Color(0xFF006A6C),
      'secondary': Color(0xFF00696D),
      'tertiary': Color(0xFF6B5D00),
    },
    'rose': {
      'primary': Color(0xFFBA1A1A),
      'secondary': Color(0xFF8C4D4D),
      'tertiary': Color(0xFF7D5700),
    },
    'amber': {
      'primary': Color(0xFF7D5700),
      'secondary': Color(0xFF6C5E00),
      'tertiary': Color(0xFF625B71),
    },
  };

  static ColorScheme getThemeColors(String themeName, bool isDark) {
    final colors = themes[themeName] ?? themes['default']!;
    final primary = colors['primary']!;

    // Generate Material 3 color scheme from primary color
    final corePalette = CorePalette.of(primary.value);

    if (isDark) {
      return ColorScheme.dark(
        primary: Color(corePalette.primary.get(40)),
        onPrimary: Color(corePalette.primary.get(100)),
        primaryContainer: Color(corePalette.primary.get(30)),
        onPrimaryContainer: Color(corePalette.primary.get(90)),
        secondary: Color(corePalette.secondary.get(40)),
        onSecondary: Color(corePalette.secondary.get(100)),
        secondaryContainer: Color(corePalette.secondary.get(30)),
        onSecondaryContainer: Color(corePalette.secondary.get(90)),
        tertiary: Color(corePalette.tertiary.get(40)),
        onTertiary: Color(corePalette.tertiary.get(100)),
        tertiaryContainer: Color(corePalette.tertiary.get(30)),
        onTertiaryContainer: Color(corePalette.tertiary.get(90)),
        error: Color(corePalette.error.get(40)),
        onError: Color(corePalette.error.get(100)),
        errorContainer: Color(corePalette.error.get(30)),
        onErrorContainer: Color(corePalette.error.get(90)),
        background: Color(corePalette.neutral.get(10)),
        onBackground: Color(corePalette.neutral.get(90)),
        surface: Color(corePalette.neutral.get(10)),
        onSurface: Color(corePalette.neutral.get(90)),
        surfaceVariant: Color(corePalette.neutralVariant.get(30)),
        onSurfaceVariant: Color(corePalette.neutralVariant.get(80)),
        outline: Color(corePalette.neutralVariant.get(60)),
        outlineVariant: Color(corePalette.neutralVariant.get(30)),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: Color(corePalette.neutral.get(90)),
        onInverseSurface: Color(corePalette.neutral.get(10)),
        inversePrimary: Color(corePalette.primary.get(80)),
        surfaceTint: Color(corePalette.primary.get(40)),
      );
    } else {
      return ColorScheme.light(
        primary: Color(corePalette.primary.get(40)),
        onPrimary: Color(corePalette.primary.get(100)),
        primaryContainer: Color(corePalette.primary.get(90)),
        onPrimaryContainer: Color(corePalette.primary.get(10)),
        secondary: Color(corePalette.secondary.get(40)),
        onSecondary: Color(corePalette.secondary.get(100)),
        secondaryContainer: Color(corePalette.secondary.get(90)),
        onSecondaryContainer: Color(corePalette.secondary.get(10)),
        tertiary: Color(corePalette.tertiary.get(40)),
        onTertiary: Color(corePalette.tertiary.get(100)),
        tertiaryContainer: Color(corePalette.tertiary.get(90)),
        onTertiaryContainer: Color(corePalette.tertiary.get(10)),
        error: Color(corePalette.error.get(40)),
        onError: Color(corePalette.error.get(100)),
        errorContainer: Color(corePalette.error.get(90)),
        onErrorContainer: Color(corePalette.error.get(10)),
        background: Color(corePalette.neutral.get(99)),
        onBackground: Color(corePalette.neutral.get(10)),
        surface: Color(corePalette.neutral.get(99)),
        onSurface: Color(corePalette.neutral.get(10)),
        surfaceVariant: Color(corePalette.neutralVariant.get(90)),
        onSurfaceVariant: Color(corePalette.neutralVariant.get(30)),
        outline: Color(corePalette.neutralVariant.get(50)),
        outlineVariant: Color(corePalette.neutralVariant.get(80)),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: Color(corePalette.neutral.get(20)),
        onInverseSurface: Color(corePalette.neutral.get(95)),
        inversePrimary: Color(corePalette.primary.get(80)),
        surfaceTint: Color(corePalette.primary.get(40)),
      );
    }
  }
}

// Enhanced theme provider with vibrant themes
final appThemeProvider = Provider((ref) {
  final themeMode = ref.watch(themeModeProvider);
  final vibrantTheme = ref.watch(vibrantThemeProvider);
  final isDark =
      themeMode == AppThemeMode.dark ||
      (themeMode == AppThemeMode.system &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark);

  return ThemeData(
    useMaterial3: true,
    colorScheme: VibrantThemes.getThemeColors(vibrantTheme, isDark),
    typography: Typography.material2021(
      colorScheme: VibrantThemes.getThemeColors(vibrantTheme, isDark),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: VibrantThemes.getThemeColors(
        vibrantTheme,
        isDark,
      ).primary,
      foregroundColor: VibrantThemes.getThemeColors(
        vibrantTheme,
        isDark,
      ).onPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: VibrantThemes.getThemeColors(
        vibrantTheme,
        isDark,
      ).primary,
      foregroundColor: VibrantThemes.getThemeColors(
        vibrantTheme,
        isDark,
      ).onPrimary,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: VibrantThemes.getThemeColors(
          vibrantTheme,
          isDark,
        ).primary,
        foregroundColor: VibrantThemes.getThemeColors(
          vibrantTheme,
          isDark,
        ).onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: VibrantThemes.getThemeColors(vibrantTheme, isDark).primary,
          width: 2,
        ),
      ),
    ),
  );
});
