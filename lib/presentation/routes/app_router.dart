import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/note_editor_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/archived_screen.dart';
import '../screens/trash_screen.dart';
import '../screens/labels_screen.dart';
import '../screens/about_screen.dart';
import '../screens/developer_screen.dart';

final appRouterProvider = Provider((ref) => AppRouter());

class MainNavigationScreen extends ConsumerStatefulWidget {
  final Widget child;

  const MainNavigationScreen({super.key, required this.child});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.label_outlined),
      selectedIcon: Icon(Icons.label),
      label: 'Labels',
    ),
    NavigationDestination(
      icon: Icon(Icons.archive_outlined),
      selectedIcon: Icon(Icons.archive),
      label: 'Archived',
    ),
    NavigationDestination(
      icon: Icon(Icons.delete_outlined),
      selectedIcon: Icon(Icons.delete),
      label: 'Trash',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });

          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/labels');
              break;
            case 2:
              context.go('/archived');
              break;
            case 3:
              context.go('/trash');
              break;
            case 4:
              context.go('/settings');
              break;
          }
        },
        destinations: _destinations,
      ),
    );
  }
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // About
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),

      // Developer
      GoRoute(
        path: '/developer',
        builder: (context, state) => const DeveloperScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Main App (Bottom Navigation)
      ShellRoute(
        builder: (context, state, child) {
          return Consumer(
            builder: (context, ref, _) {
              return MainNavigationScreen(child: child);
            },
          );
        },
        routes: [
          // Home
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Labels
          GoRoute(
            path: '/labels',
            builder: (context, state) => const LabelsScreen(),
          ),

          // Archived
          GoRoute(
            path: '/archived',
            builder: (context, state) => const ArchivedScreen(),
          ),

          // Trash
          GoRoute(
            path: '/trash',
            builder: (context, state) => const TrashScreen(),
          ),

          // Settings
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),

      // Create New Note
      GoRoute(
        path: '/note/new',
        builder: (context, state) {
          final type = state.uri.queryParameters['type'] ?? 'text';
          return NoteEditorScreen(noteId: null, noteType: type);
        },
      ),

      // Note Editor
      GoRoute(
        path: '/note/:id',
        builder: (context, state) {
          final noteId = state.pathParameters['id']!;
          return NoteEditorScreen(noteId: noteId);
        },
      ),
    ],
  );
}
