# Note Craft

A modern, feature-rich note-taking Android application built with Flutter, featuring clean architecture, Material 3 design, and offline-first storage with optional cloud sync.

## 🚀 Features

### Core Features
- ✅ **Note Management**: Create, edit, delete, and organize notes with rich text editing
- ✅ **Labels/Tags**: Categorize and filter notes with custom labels
- ✅ **Search**: Real-time search across all note content
- ✅ **Archive & Trash**: Safe deletion workflow with restore functionality
- ✅ **Themes**: Light, dark, and system theme with Material You support
- ✅ **Material 3**: Modern Material Design with dynamic colors
- ✅ **Wallpapers**: Custom background images for notes
- ✅ **Rich Text Editor**: Full-featured text editor with formatting toolbar
- ✅ **State Management**: Riverpod with clean architecture
- ✅ **Navigation**: GoRouter for declarative routing
- ✅ **Local Storage**: Hive for offline-first data persistence
- ✅ **Onboarding**: Interactive setup with theme customization
- ✅ **Google Authentication**: Firebase-based login and cloud sync
- ✅ **Notifications**: Local notifications for reminders and alerts

### Advanced Features
- ✅ **Gestures**: Swipe actions, long-press multi-select
- ✅ **Media Support**: Image attachments and drawing canvas
- ✅ **Security**: App lock with PIN/biometric authentication
- ✅ **Cloud Sync**: Firebase integration with backup/restore
- ✅ **Wallpaper System**: Dynamic background loading
- ✅ **Developer Tools**: Advanced debugging and testing screen
- ✅ **Trash Management**: Soft delete with auto-cleanup
- ✅ **Export/Import**: Backup and restore notes locally
- ✅ **Performance**: Optimized for large note collections

## 📱 Screens

- **Splash Screen**: Animated app introduction
- **Onboarding**: 3-step setup for new users  
- **Home**: Main notes view with search, FAB, and filtering
- **Note Editor**: Rich text editor with formatting and media
- **Labels**: Manage and organize note categories
- **Archived**: View and restore archived notes
- **Trash**: Manage deleted notes with bulk actions
- **Settings**: Theme, sync, and app preferences
- **About**: App information and credits
- **Developer**: Debug tools and advanced settings

## 🏗️ Architecture

This app follows **Clean Architecture** principles:

```
lib/
├── core/                 # Shared utilities
│   ├── constants/        # App constants and feature flags
│   ├── errors/          # Custom error handling
│   ├── theme/           # Material 3 theming
│   ├── services/         # Notification and background services
│   ├── utils/           # Helper functions
│   └── widgets/         # Reusable UI components
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
- **Language**: Dart (>=3.10.7) 
- **State Management**: Riverpod (^2.4.9) with code generation
- **Navigation**: GoRouter (^12.1.3) for declarative routing
- **Local Storage**: Hive (^2.2.3) for offline-first persistence
- **Rich Text**: flutter_quill (^11.5.0) for advanced text editing
- **UI**: Material 3 with Material You (dynamic_color ^1.6.8)
- **Authentication**: Firebase Auth (^4.16.0) with Google Sign-In
- **Cloud Storage**: Firestore (^4.14.0) for note synchronization
- **Notifications**: flutter_local_notifications (^17.2.2) for reminders
- **Media**: image_picker (^1.0.4) for camera/gallery support
- **Security**: local_auth (^2.1.6) for PIN/biometric authentication
- **Icons**: FontAwesome (^10.6.0) and Cupertino icons
- **Animations**: Lottie (^3.3.2) for smooth transitions
- **Utilities**: intl, uuid, equatable, share_plus, url_launcher

## 📋 Prerequisites

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.10.7) 
- Android Studio / VS Code with Flutter extensions
- Android device or emulator (API 21+)
- Firebase project (for cloud sync features)
- Git for version control

## 🚀 Getting Started

### 1. Clone Repository
```bash
git clone <repository-url>
cd note_craft
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Setup Firebase (Optional)
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android app to Firebase project
3. Download `google-services.json` and place in `android/app/`
4. Set `firebaseSyncEnabled = true` in `lib/core/constants/app_constants.dart`

### 4. Generate Code
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 5. Run App
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

### Firebase Setup
1. **Create Firebase Project**: Visit [Firebase Console](https://console.firebase.google.com/)
2. **Add Android App**: Use package name `com.abir2afridi.notecraft`
3. **Download Config**: Get `google-services.json` and place in `android/app/`
4. **Enable Features**: 
   - Authentication (Google Sign-In)
   - Firestore Database
   - Storage (for attachments)

### Feature Flags
Edit `lib/core/constants/app_constants.dart`:
```dart
static bool firebaseSyncEnabled = true;  // Enable cloud sync
static bool notificationsEnabled = true;  // Enable notifications
```

### Hive Initialization
The app automatically initializes Hive with these boxes:
- `notes_box`: Stores all notes
- `labels_box`: Stores label definitions
- `settings_box`: Stores app preferences

## 🎨 Customization

### Note Colors
Edit `AppConstants.noteColors` in `lib/core/constants/app_constants.dart` to customize available note colors.

### Theme Colors
Modify `AppTheme.lightTheme` and `AppTheme.darkTheme` in `lib/core/theme/app_theme.dart` to customize app theme.

### Custom Fonts
Add fonts to `assets/fonts/` and update `pubspec.yaml` to include them.

## 📊 State Management

The app uses **Riverpod** for state management:

- **Providers**: Located in `lib/presentation/providers/`
- **Repositories**: Abstract interfaces in `lib/domain/repositories/`
- **Use Cases**: Business logic in `lib/domain/usecases/`
- **Data Sources**: Local (Hive) and Remote (Firebase) in `lib/data/datasources/`

## 🔒 Security Features

- ✅ **App Lock**: PIN-based authentication
- ✅ **Biometric Support**: Fingerprint and face recognition
- ✅ **Secure Storage**: Encrypted credential storage
- ✅ **Session Management**: Auto-logout after inactivity

## 🌐 Offline-First Architecture

- **Local Storage**: All notes stored locally using Hive
- **Fast Performance**: Instant read/write operations
- **Optional Sync**: Cloud sync when enabled
- **Conflict Resolution**: Smart merge for sync conflicts
- **Background Sync**: Automatic synchronization

## 🔔 Notification System

- **Local Notifications**: Scheduled reminders for notes
- **Permission Handling**: Proper Android/iOS permissions
- **Custom Sounds**: Configurable notification tones
- **Scheduling**: Advanced time-based notifications

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Dart/Flutter official style guide
- Use null safety throughout
- Add comments for complex logic
- Test thoroughly before submitting

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Bug Reports

Please report bugs through the issue tracker with:
- Device information and OS version
- Flutter version (`flutter --version`)
- Steps to reproduce the issue
- Expected vs actual behavior
- Screenshots if applicable

## 🔄 Version History

### v1.0.0+1 (Current)
- **Core Features**: Complete note management system
- **Authentication**: Google Sign-In with Firebase
- **UI/UX**: Material 3 with dynamic theming
- **Performance**: Optimized for large datasets
- **Security**: PIN and biometric authentication
- **Sync**: Cloud synchronization with conflict resolution
- **Notifications**: Local notification system
- **Developer Tools**: Advanced debugging screen
- **Export/Import**: Local backup functionality

## 📞 Support

For support and questions:
- Create an issue on GitHub
- Check the [Wiki](../../wiki) for documentation
- Review existing [Issues](../../issues)
- Join our community discussions

## 🌟 Acknowledgments

- **Flutter Team** for the amazing framework
- **Riverpod** for excellent state management
- **Material Design** team for design guidelines
- **Firebase** for backend services
- **Open Source** community contributors

---

**Built with ❤️ using Flutter**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
