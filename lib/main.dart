import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/vibrant_theme.dart';
import 'presentation/providers/settings_providers.dart';
import 'presentation/providers/note_provider.dart';
import 'presentation/routes/app_router.dart';
import 'data/datasources/local/local_data_source.dart';
import 'data/models/note_model.dart';
import 'data/models/label_model.dart';
import 'core/constants/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Core Bootstrapping with Timeout & Error Boundary
  LocalDataSource? localDataSource;

  try {
    // Run initialization tasks in parallel where possible, with a global timeout
    await Future.wait([
      // A: Hive Initialization (Critical)
      Hive.initFlutter(),

      // B: Firebase Initialization (Non-blocking fail-safe)
      if (AppConstants.firebaseSyncEnabled)
        Firebase.initializeApp().catchError((e) {
          debugPrint('Firebase init failed: $e');
          return Firebase.app();
        }),
    ]).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('Bootstrap components timed out after 5s');
        return [];
      },
    );

    // 2. Resilient Adapter Registration
    _registerAdapters();

    // 3. Initialize Data Source with Internal Migration Logic
    localDataSource = LocalDataSource();
    await localDataSource.init().timeout(const Duration(seconds: 4));
  } catch (e, stack) {
    debugPrint('BOOTSTRAP CRITICAL ERROR: $e');
    debugPrint('STACKTRACE: $stack');

    // EMERGENCY RESCUE: If the above failed (likely DB corruption),
    // attempt to provide a clean state or at least let the app run.
    try {
      localDataSource = LocalDataSource();
      await localDataSource.init();
    } catch (_) {
      // If even this fails, we let the app run; the UI will show errors
      // instead of freezing on splash.
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        if (localDataSource != null)
          localDataSourceProvider.overrideWithValue(localDataSource),
      ],
      child: const NoteKeeperApp(),
    ),
  );
}

void _registerAdapters() {
  try {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ChecklistItemModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(LabelModelAdapter());
    }
  } catch (e) {
    debugPrint('Adapter registration warning: $e');
  }
}

class NoteKeeperApp extends ConsumerWidget {
  const NoteKeeperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      themeMode: themeMode.toThemeMode(),
      theme: ref.watch(appThemeProvider),
      darkTheme: ref.watch(appThemeProvider),
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
