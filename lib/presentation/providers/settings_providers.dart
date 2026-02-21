import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import 'settings_repository_provider.dart';

// Theme mode provider with persistence
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
      return ThemeModeNotifier(ref);
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
  final Ref _ref;
  ThemeModeNotifier(this._ref) : super(AppThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final settings = await _ref
          .read(settingsRepositoryProvider)
          .getSettings();
      state = AppThemeMode.values.firstWhere(
        (mode) => mode.toString() == settings.themeMode,
        orElse: () => AppThemeMode.system,
      );
    } catch (e) {
      // Keep default if loading fails
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    try {
      final repo = _ref.read(settingsRepositoryProvider);
      final current = await repo.getSettings();
      await repo.saveSettings(current.copyWith(themeMode: mode.toString()));
    } catch (e) {
      // Continue even if saving fails
    }
  }
}

// Default wallpaper provider
final defaultWallpaperProvider =
    StateNotifierProvider<DefaultWallpaperNotifier, String?>((ref) {
      return DefaultWallpaperNotifier(ref);
    });

class DefaultWallpaperNotifier extends StateNotifier<String?> {
  final Ref _ref;
  DefaultWallpaperNotifier(this._ref) : super(null) {
    _loadDefaultWallpaper();
  }

  Future<void> _loadDefaultWallpaper() async {
    try {
      final settings = await _ref
          .read(settingsRepositoryProvider)
          .getSettings();
      state = settings.defaultWallpaperPath;
    } catch (e) {
      // Ignore load errors
    }
  }

  Future<void> setDefaultWallpaper(String? path) async {
    state = path;
    try {
      final repo = _ref.read(settingsRepositoryProvider);
      final current = await repo.getSettings();
      await repo.saveSettings(current.copyWith(defaultWallpaperPath: path));
    } catch (e) {
      // Ignore save errors
    }
  }
}

// Default note color provider
final defaultNoteColorProvider =
    StateNotifierProvider<DefaultNoteColorNotifier, String>((ref) {
      return DefaultNoteColorNotifier(ref);
    });

class DefaultNoteColorNotifier extends StateNotifier<String> {
  final Ref _ref;
  DefaultNoteColorNotifier(this._ref) : super(AppConstants.noteColors.first) {
    _loadDefaultColor();
  }

  Future<void> _loadDefaultColor() async {
    try {
      final settings = await _ref
          .read(settingsRepositoryProvider)
          .getSettings();
      state = settings.defaultNoteColor;
    } catch (e) {
      // Keep default if loading fails
    }
  }

  Future<void> setDefaultColor(String color) async {
    state = color;
    try {
      final repo = _ref.read(settingsRepositoryProvider);
      final current = await repo.getSettings();
      await repo.saveSettings(current.copyWith(defaultNoteColor: color));
    } catch (e) {
      // Continue even if saving fails
    }
  }
}

// Vibrant theme provider
final vibrantThemeProvider =
    StateNotifierProvider<VibrantThemeNotifier, String>((ref) {
      return VibrantThemeNotifier(ref);
    });

class VibrantThemeNotifier extends StateNotifier<String> {
  final Ref _ref;
  VibrantThemeNotifier(this._ref) : super('notekeeper') {
    _loadVibrantTheme();
  }

  Future<void> _loadVibrantTheme() async {
    try {
      final settings = await _ref
          .read(settingsRepositoryProvider)
          .getSettings();
      state = settings.vibrantTheme;
    } catch (e) {
      // Keep default if loading fails
    }
  }

  Future<void> setVibrantTheme(String themeName) async {
    state = themeName;
    try {
      final repo = _ref.read(settingsRepositoryProvider);
      final current = await repo.getSettings();
      await repo.saveSettings(current.copyWith(vibrantTheme: themeName));
    } catch (e) {
      // Continue even if saving fails
    }
  }
}

// Font size provider
final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  return FontSizeNotifier(ref);
});

class FontSizeNotifier extends StateNotifier<double> {
  final Ref _ref;
  FontSizeNotifier(this._ref) : super(16.0) {
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    try {
      final settings = await _ref
          .read(settingsRepositoryProvider)
          .getSettings();
      state = settings.fontSize;
    } catch (e) {
      // Keep default if loading fails
    }
  }

  Future<void> setFontSize(double size) async {
    state = size;
    try {
      final repo = _ref.read(settingsRepositoryProvider);
      final current = await repo.getSettings();
      await repo.saveSettings(current.copyWith(fontSize: size));
    } catch (e) {
      // Continue even if saving fails
    }
  }
}

// Default view provider
final defaultViewProvider = StateNotifierProvider<DefaultViewNotifier, String>((
  ref,
) {
  return DefaultViewNotifier(ref);
});

class DefaultViewNotifier extends StateNotifier<String> {
  final Ref _ref;
  DefaultViewNotifier(this._ref) : super('grid') {
    _loadDefaultView();
  }

  Future<void> _loadDefaultView() async {
    try {
      final settings = await _ref
          .read(settingsRepositoryProvider)
          .getSettings();
      state = settings.defaultView;
    } catch (e) {
      // Keep default if loading fails
    }
  }

  Future<void> setDefaultView(String view) async {
    state = view;
    try {
      final repo = _ref.read(settingsRepositoryProvider);
      final current = await repo.getSettings();
      await repo.saveSettings(current.copyWith(defaultView: view));
    } catch (e) {
      // Continue even if saving fails
    }
  }
}

// Guest mode provider
final isGuestProvider = StateNotifierProvider<IsGuestNotifier, bool>((ref) {
  return IsGuestNotifier(ref);
});

class IsGuestNotifier extends StateNotifier<bool> {
  final Ref _ref;
  IsGuestNotifier(this._ref) : super(false) {
    _loadIsGuest();
  }

  Future<void> _loadIsGuest() async {
    try {
      final settings = await _ref
          .read(settingsRepositoryProvider)
          .getSettings();
      state = settings.isGuest;
    } catch (e) {
      // Keep default if loading fails
    }
  }

  Future<void> setGuestMode(bool isGuest) async {
    state = isGuest;
    try {
      final repo = _ref.read(settingsRepositoryProvider);
      final current = await repo.getSettings();
      await repo.saveSettings(current.copyWith(isGuest: isGuest));
    } catch (e) {
      // Continue even if saving fails
    }
  }
}
