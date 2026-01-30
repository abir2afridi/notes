# NoteKeeper Changelog

A full-featured Google Keep–like note-taking Android application built with Flutter, featuring clean architecture, Material 3 design, and offline-first storage.

## 🚀 Features

### Core Features
- ✅ **Note Types**: Text notes with rich text editing (flutter_quill)
- ✅ **Organization**: Labels/tags system for categorization
- ✅ **Views**: Grid and list view toggle
- ✅ **Search**: Real-time note filtering
- ✅ **Archive & Trash**: Safe deletion workflow
- ✅ **Themes**: Light, dark, and system theme support with Material You
- ✅ **Material 3**: Modern Material You design with dynamic colors
- ✅ **Wallpapers**: Custom background images for notes
- ✅ **Rich Text Editor**: Full-featured text editor with formatting
- ✅ **State Management**: Riverpod with clean architecture
- ✅ **Navigation**: GoRouter for declarative routing
- ✅ **Local Storage**: Hive for offline-first data persistence

### Advanced Features (Implemented)
- ✅ **Gestures**: Swipe actions, long-press multi-select
- ✅ **Media**: Image attachments and drawing canvas support
- ✅ **Security**: App lock with PIN/biometric (local_auth)
- ✅ **Firebase**: Cloud sync with feature flag support
- ✅ **Wallpaper System**: Dynamic background loading
- ✅ **Developer Screen**: Advanced debugging and testing tools

### Advanced Features (Planned)
- 🔄 **Backup**: Local export/import functionality
- 🔄 **Collaboration**: Real-time note sharing

## 📱 Screens

- **Splash Screen**: Animated app introduction
- **Onboarding**: 3-slide introduction for new users  
- **Home**: Main notes view with search, FAB, and wallpaper support
- **Note Editor**: Rich text editor with formatting toolbar
- **Labels**: Manage and organize labels
- **Archived**: View archived notes
- **Trash**: Manage deleted notes
- **Settings**: Theme, preferences, and app configuration
- **About**: App version and developer information
- **Developer**: Debug tools and testing utilities

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

- **Framework**: Flutter (>=3.10.0)
- **Language**: Dart (>=3.10.7, null safety)
- **State Management**: Riverpod (^2.4.9) with code generation
- **Navigation**: GoRouter (^12.1.3) for declarative routing
- **Local Storage**: Hive (^2.2.3) for offline-first persistence
- **Rich Text**: flutter_quill (^11.5.0) for advanced text editing
- **UI**: Material 3 with Material You (dynamic_color ^1.6.8)
- **Architecture**: Clean Architecture with domain/data/presentation layers
- **Media**: image_picker (^1.0.4) for camera/gallery support
- **Security**: local_auth (^2.1.6) for PIN/biometric authentication
- **Firebase**: Cloud sync with feature flags (firebase_core ^2.24.2)
- **Icons**: FontAwesome (^10.6.0) and Cupertino icons
- **Animations**: Lottie (^3.3.2) for smooth transitions
- **Utilities**: intl, uuid, equatable, share_plus, url_launcher

## 📋 Prerequisites

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.10.7) 
- Android Studio / VS Code with Flutter extensions
- Android device or emulator (API 21+)
- Git for version control

## 🚀 Getting Started

### 1. Clone the Repository
```bash
git clone <repository-url>
cd notes
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Setup Assets
Create the required asset directories:
```bash
mkdir -p assets/images assets/icons assets/wallpaper_backgrund
```

### 4. Generate Code (Hive adapters & Riverpod providers)
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 5. Run the App
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

- **v1.0.0+1**: Current release with advanced features
  - Rich text editing with flutter_quill
  - Dynamic wallpaper system
  - Material You theming with dynamic colors
  - Firebase cloud sync (feature-flagged)
  - Biometric/PIN security
  - Developer debugging tools
  - Clean architecture with Riverpod
  - Advanced gesture controls
  - Image attachments and drawing support

## 📞 Support

For support and questions:
- Create an issue on GitHub
- Check the documentation
- Review existing issues

---

**Built with ❤️ using Flutter**
