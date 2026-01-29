class AppConstants {
  // App Info
  static const String appName = 'NoteKeeper';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String notesBox = 'notes_box';
  static const String labelsBox = 'labels_box';
  static const String settingsBox = 'settings_box';
  
  // Note Types
  static const String textNoteType = 'text';
  static const String checklistNoteType = 'checklist';
  
  // Note Colors (Google Keep style)
  static const List<String> noteColors = [
    '#FFFFFF', // Default
    '#F28B82', // Red
    '#F7BC04', // Orange
    '#FBF476', // Yellow
    '#CCFF90', // Green
    '#A7FFEB', // Teal
    '#CBF0F8', // Blue
    '#AECBFA', // Indigo
    '#D7AEFB', // Purple
    '#FDCFE8', // Pink
    '#E6C9A8', // Brown
    '#E8EAED', // Gray
  ];
  
  // Animation Durations
  static const int defaultAnimationDuration = 300;
  static const int fastAnimationDuration = 150;
  static const int slowAnimationDuration = 500;
  
  // Grid Settings
  static const int defaultCrossAxisCount = 2;
  static const double defaultChildAspectRatio = 1.5;
  
  // Search Settings
  static const int searchDebounceMs = 300;
  
  // Auto-save Settings
  static const int autoSaveIntervalMs = 1000;
  
  // Trash Settings
  static const int trashRetentionDays = 30;
  
  // Firebase Feature Flag
  static const bool firebaseSyncEnabled = false;
}
