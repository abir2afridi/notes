# NoteKeeper - Google Keep Clone

A full-featured Google Keep–like note-taking Android application built with Flutter, featuring clean architecture, Material 3 design, and offline-first storage.

## 🚀 Features

### Core Features
- ✅ **Note Types**: Text notes and checklist notes
- ✅ **Organization**: Labels/tags system for categorization
- ✅ **Views**: Grid and list view toggle
- ✅ **Search**: Real-time note filtering
- ✅ **Archive & Trash**: Safe deletion workflow
- ✅ **Themes**: Light, dark, and system theme support
- ✅ **Material 3**: Modern Material You design

### Advanced Features (Planned)
- 🔄 **Gestures**: Swipe actions, long-press multi-select
- 🔄 **Media**: Image attachments and drawing canvas
- 🔄 **Sync**: Optional Firebase cloud sync
- 🔄 **Security**: App lock with PIN/biometric
- 🔄 **Backup**: Local export/import functionality

## 📱 Screens

- **Splash Screen**: Animated app introduction
- **Onboarding**: 3-slide introduction for new users
- **Home**: Main notes view with search and FAB
- **Note Editor**: Create/edit text and checklist notes
- **Labels**: Manage and organize labels
- **Archived**: View archived notes
- **Trash**: Manage deleted notes
- **Settings**: Theme, preferences, and app info
- **About**: App version and developer information

## 🏗️ Architecture

This app follows **Clean Architecture** principles:

```
lib/
├── core/                 # Shared utilities
│   ├── constants/        # App constants
│   ├── errors/          # Custom errors
│   ├── theme/           # App theming
│   ├── utils/           # Helper functions
│   └── widgets/         # Reusable widgets
├── data/                # Data layer
│   ├── datasources/     # Local (Hive) & Remote (Firebase)
│   ├── models/          # Data models with Hive adapters
│   └── repositories/    # Repository implementations
├── domain/              # Business logic
│   ├── entities/        # Pure business objects
│   ├── repositories/    # Abstract repository interfaces
│   └── usecases/        # Business use cases
└── presentation/        # UI layer
    ├── providers/       # Riverpod state management
    ├── routes/          # Navigation (GoRouter)
    ├── screens/         # App screens
    └── widgets/         # Screen-specific widgets
```

## 🛠 Tech Stack

- **Framework**: Flutter (latest stable)
- **Language**: Dart (null safety)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Local Storage**: Hive (offline-first)
- **UI**: Material 3 (Material You)
- **Architecture**: Clean Architecture
- **Optional Cloud**: Firebase (feature-flagged)

## 📋 Prerequisites

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.10.7)
- Android Studio / VS Code with Flutter extensions
- Android device or emulator

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone <repository-url>
cd note
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Generate Code (Hive adapters)
```bash
flutter packages pub run build_runner build
```

### 4. Run the App
```bash
flutter run
```

## 📦 Build Instructions

### Debug Build
```bash
flutter run --debug
```

### Release Build (Android)
```bash
flutter build apk --release
```

### App Bundle (Play Store)
```bash
flutter build appbundle --release
```

## 🔧 Configuration

### Firebase Setup (Optional)
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android app to Firebase project
3. Download `google-services.json` and place in `android/app/`
4. Set `firebaseSyncEnabled = true` in `lib/core/constants/app_constants.dart`

### Hive Initialization
The app automatically initializes Hive with these boxes:
- `notes_box`: Stores all notes
- `labels_box`: Stores label definitions
- `settings_box`: Stores app preferences

## 🎨 Customization

### Note Colors
Edit `AppConstants.noteColors` in `lib/core/constants/app_constants.dart` to customize the available note colors.

### Theme Colors
Modify `AppTheme.lightTheme` and `AppTheme.darkTheme` in `lib/core/theme/app_theme.dart` to customize the app theme.

## 📊 State Management

The app uses **Riverpod** for state management:

- **Providers**: Located in `lib/presentation/providers/`
- **Repositories**: Abstract interfaces in `lib/domain/repositories/`
- **Use Cases**: Business logic in `lib/domain/usecases/`

## 🔒 Security Features (Planned)

- App lock with PIN
- Biometric authentication (fingerprint/face)
- Secure credential storage

## 🌐 Offline-First Architecture

- All notes stored locally using Hive
- Fast read/write operations
- Optional cloud sync when enabled
- Conflict resolution for sync

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🐛 Bug Reports

Please report bugs through the issue tracker with:
- Device information
- Flutter version
- Steps to reproduce
- Expected vs actual behavior

## 🔄 Version History

- **v1.0.0**: Initial release with core features
  - Basic note creation/editing
  - Labels and organization
  - Theme support
  - Clean architecture

## 📞 Support

For support and questions:
- Create an issue on GitHub
- Check the documentation
- Review existing issues

---

**Built with ❤️ using Flutter**
