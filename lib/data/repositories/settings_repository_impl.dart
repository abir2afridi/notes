import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/remote/remote_data_source.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final RemoteDataSource _remoteDataSource;

  SettingsRepositoryImpl(this._remoteDataSource);

  static const String _themeModeKey = 'theme_mode';
  static const String _vibrantThemeKey = 'vibrant_theme';
  static const String _fontSizeKey = 'font_size';
  static const String _defaultNoteColorKey = 'default_note_color';
  static const String _defaultWallpaperPathKey = 'default_wallpaper_path';
  static const String _defaultViewKey = 'default_view';

  @override
  Future<SettingsModel> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsModel(
      themeMode: prefs.getString(_themeModeKey) ?? 'AppThemeMode.system',
      vibrantTheme: prefs.getString(_vibrantThemeKey) ?? 'notekeeper',
      fontSize: prefs.getDouble(_fontSizeKey) ?? 16.0,
      defaultNoteColor: prefs.getString(_defaultNoteColorKey) ?? '#FFFFFF',
      defaultWallpaperPath: prefs.getString(_defaultWallpaperPathKey),
      defaultView: prefs.getString(_defaultViewKey) ?? 'grid',
    );
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, settings.themeMode);
    await prefs.setString(_vibrantThemeKey, settings.vibrantTheme);
    await prefs.setDouble(_fontSizeKey, settings.fontSize);
    await prefs.setString(_defaultNoteColorKey, settings.defaultNoteColor);
    if (settings.defaultWallpaperPath != null) {
      await prefs.setString(
        _defaultWallpaperPathKey,
        settings.defaultWallpaperPath!,
      );
    } else {
      await prefs.remove(_defaultWallpaperPathKey);
    }
    await prefs.setString(_defaultViewKey, settings.defaultView);

    // Sync to remote if logged in
    try {
      await _remoteDataSource.saveSettings(settings);
    } catch (e) {
      // Ignore remote sync errors (user might not be authenticated)
    }
  }

  @override
  Future<void> syncWithRemote() async {
    try {
      final remoteSettings = await _remoteDataSource.getSettings();
      if (remoteSettings != null) {
        await saveSettings(remoteSettings);
      }
    } catch (e) {
      // Ignore remote sync errors (user might not be authenticated)
    }
  }
}
