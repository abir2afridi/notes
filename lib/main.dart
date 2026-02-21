import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'presentation/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/models/note_model.dart';
import 'data/models/label_model.dart';
import 'presentation/providers/settings_providers.dart';
import 'data/datasources/local/local_data_source.dart';
import 'presentation/providers/note_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(NoteModelAdapter());
  Hive.registerAdapter(LabelModelAdapter());

  // Open Hive boxes
  await Hive.openBox<NoteModel>('notes');
  await Hive.openBox<LabelModel>('labels');
  await Hive.openBox('settings');

  // Initialize LocalDataSource
  final localDataSource = LocalDataSource();
  await localDataSource.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        // Override the LocalDataSource provider with initialized instance
        localDataSourceProvider.overrideWithValue(localDataSource),
      ],
      child: const NoteCraftApp(),
    ),
  );
}

class NoteCraftApp extends ConsumerWidget {
  const NoteCraftApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Note Craft',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode.toThemeMode(),

      // Router configuration
      routerConfig: appRouter,

      // Builder for custom transitions and overlays
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0), // Prevent text scaling
          ),
          child: child!,
        );
      },
    );
  }
}
