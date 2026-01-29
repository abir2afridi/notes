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

  // Initialize Hive and Data Sources before running the app
  LocalDataSource? localDataSource;
  try {
    // 1. Safe Hive Initialization
    await Hive.initFlutter().timeout(const Duration(seconds: 4));

    // 2. Resilient Adapter Registration (skip if already registered)
    try {
      if (!Hive.isAdapterRegistered(0))
        Hive.registerAdapter(NoteModelAdapter());
      if (!Hive.isAdapterRegistered(1))
        Hive.registerAdapter(ChecklistItemModelAdapter());
      if (!Hive.isAdapterRegistered(2))
        Hive.registerAdapter(LabelModelAdapter());
    } catch (e) {
      debugPrint('Adapter error: $e');
    }

    // 3. Initialize Firebase
    if (AppConstants.firebaseSyncEnabled) {
      await Firebase.initializeApp()
          .catchError((e) {
            debugPrint('Firebase init failed: $e');
            return Firebase.app();
          })
          .timeout(const Duration(seconds: 4));
    }

    // 4. Initialize LocalDataSource with a catch-all for corruption
    localDataSource = LocalDataSource();
    try {
      await localDataSource.init().timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('LocalDataSource Init Error (possible corruption): $e');
      // If boxes are corrupted after update, we clear them to prevent the stuck logo
      // This is better than being stuck on the splash screen forever.
      try {
        await Hive.deleteFromDisk();
        localDataSource = LocalDataSource();
        await localDataSource.init();
      } catch (innerError) {
        debugPrint('Emergency data reset failed: $innerError');
      }
    }

    debugPrint('Initialization completed successfully');
  } catch (e) {
    debugPrint('Critical Initialization failure: $e');
    // Final fail-safe: Ensure localDataSource is at least defined
    localDataSource ??= LocalDataSource();
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
