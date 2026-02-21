class SettingsModel {
  final String themeMode;
  final String vibrantTheme;
  final double fontSize;
  final String defaultNoteColor;
  final String? defaultWallpaperPath;
  final String defaultView;
  final bool isGuest;

  SettingsModel({
    required this.themeMode,
    required this.vibrantTheme,
    required this.fontSize,
    required this.defaultNoteColor,
    this.defaultWallpaperPath,
    required this.defaultView,
    this.isGuest = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode,
      'vibrantTheme': vibrantTheme,
      'fontSize': fontSize,
      'defaultNoteColor': defaultNoteColor,
      'defaultWallpaperPath': defaultWallpaperPath,
      'defaultView': defaultView,
      'isGuest': isGuest,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      themeMode: json['themeMode'] ?? 'AppThemeMode.system',
      vibrantTheme: json['vibrantTheme'] ?? 'notekeeper',
      fontSize: (json['fontSize'] ?? 16.0).toDouble(),
      defaultNoteColor: json['defaultNoteColor'] ?? '#FFFFFF',
      defaultWallpaperPath: json['defaultWallpaperPath'],
      defaultView: json['defaultView'] ?? 'grid',
      isGuest: json['isGuest'] ?? false,
    );
  }

  SettingsModel copyWith({
    String? themeMode,
    String? vibrantTheme,
    double? fontSize,
    String? defaultNoteColor,
    String? defaultWallpaperPath,
    String? defaultView,
    bool? isGuest,
  }) {
    return SettingsModel(
      themeMode: themeMode ?? this.themeMode,
      vibrantTheme: vibrantTheme ?? this.vibrantTheme,
      fontSize: fontSize ?? this.fontSize,
      defaultNoteColor: defaultNoteColor ?? this.defaultNoteColor,
      defaultWallpaperPath: defaultWallpaperPath ?? this.defaultWallpaperPath,
      defaultView: defaultView ?? this.defaultView,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}
