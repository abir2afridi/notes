import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';

// Theme mode provider with persistence
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
      return ThemeModeNotifier();
    });

enum AppThemeMode { light, dark, system }

extension AppThemeModeExtension on AppThemeMode {
  ThemeMode toThemeMode() {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier() : super(AppThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('theme_mode');
      if (savedTheme != null) {
        state = AppThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedTheme,
          orElse: () => AppThemeMode.system,
        );
      }
    } catch (e) {
      // Keep default if loading fails
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', mode.toString());
    } catch (e) {
      // Continue even if saving fails
    }
  }
}

// Default wallpaper provider
final defaultWallpaperProvider =
    StateNotifierProvider<DefaultWallpaperNotifier, String?>((ref) {
      return DefaultWallpaperNotifier();
    });

class DefaultWallpaperNotifier extends StateNotifier<String?> {
  DefaultWallpaperNotifier() : super(null) {
    _loadDefaultWallpaper();
  }

  static const _wallpaperKey = 'default_wallpaper_path';

  Future<void> _loadDefaultWallpaper() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPath = prefs.getString(_wallpaperKey);
      state = savedPath;
    } catch (e) {
      // Ignore load errors
    }
  }

  Future<void> setDefaultWallpaper(String? path) async {
    state = path;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (path == null || path.isEmpty) {
        await prefs.remove(_wallpaperKey);
      } else {
        await prefs.setString(_wallpaperKey, path);
      }
    } catch (e) {
      // Ignore save errors
    }
  }
}

// Default note color provider
final defaultNoteColorProvider =
    StateNotifierProvider<DefaultNoteColorNotifier, String>((ref) {
      return DefaultNoteColorNotifier();
    });

class DefaultNoteColorNotifier extends StateNotifier<String> {
  DefaultNoteColorNotifier() : super(AppConstants.noteColors.first) {
    _loadDefaultColor();
  }

  Future<void> _loadDefaultColor() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedColor =
          prefs.getString('default_note_color') ??
          AppConstants.noteColors.first;
      if (AppConstants.noteColors.contains(savedColor)) {
        state = savedColor;
      }
    } catch (e) {
      // Keep default if loading fails
    }
  }

  Future<void> setDefaultColor(String color) async {
    state = color;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('default_note_color', color);
    } catch (e) {
      // Continue even if saving fails
    }
  }
}

// Vibrant theme provider
final vibrantThemeProvider =
    StateNotifierProvider<VibrantThemeNotifier, String>((ref) {
      return VibrantThemeNotifier();
    });

class VibrantThemeNotifier extends StateNotifier<String> {
  VibrantThemeNotifier() : super('default') {
    _loadVibrantTheme();
  }

  Future<void> _loadVibrantTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('vibrant_theme') ?? 'default';
      state = savedTheme;
    } catch (e) {
      // Keep default if loading fails
    }
  }

  Future<void> setVibrantTheme(String themeName) async {
    state = themeName;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('vibrant_theme', themeName);
    } catch (e) {
      // Continue even if saving fails
    }
  }
}

// Font size provider
final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  return FontSizeNotifier();
});

class FontSizeNotifier extends StateNotifier<double> {
  FontSizeNotifier() : super(16.0) {
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSize = prefs.getDouble('font_size') ?? 16.0;
      state = savedSize;
    } catch (e) {
      // Keep default if loading fails
    }
  }

  Future<void> setFontSize(double size) async {
    state = size;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('font_size', size);
    } catch (e) {
      // Continue even if saving fails
    }
  }
}

// Default view provider
final defaultViewProvider = StateNotifierProvider<DefaultViewNotifier, String>((
  ref,
) {
  return DefaultViewNotifier();
});

class DefaultViewNotifier extends StateNotifier<String> {
  DefaultViewNotifier() : super('grid') {
    _loadDefaultView();
  }

  Future<void> _loadDefaultView() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedView = prefs.getString('default_view') ?? 'grid';
      state = savedView;
    } catch (e) {
      // Keep default if loading fails
    }
  }

  Future<void> setDefaultView(String view) async {
    state = view;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('default_view', view);
    } catch (e) {
      // Continue even if saving fails
    }
  }
}
