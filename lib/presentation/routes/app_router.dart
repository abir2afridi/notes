import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/note_editor_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/labels_screen.dart';
import '../screens/about_screen.dart';
import '../screens/developer_screen.dart';
import '../screens/search_screen.dart';
import '../screens/login_screen.dart';
import '../screens/trash_screen.dart';
import '../screens/archived_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_providers.dart';
import '../providers/first_launch_provider.dart';
import '../providers/ui_state_provider.dart';
import 'package:animations/animations.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: AuthListenable(ref),
    redirect: (context, state) {
      final user = authState.value;
      final isGuest = ref.read(isGuestProvider);
      final isFirstLaunch = ref.read(firstLaunchProvider);

      final isLoggingIn = state.matchedLocation == '/login';
      final isSplashing = state.matchedLocation == '/splash';
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (isSplashing) return null;

      // Rule 1: Always force onboarding if it's the first launch
      if (isFirstLaunch && !isOnboarding) {
        return '/onboarding';
      }

      // Rule 2: If not logged in and not a guest, and not on login/onboarding, go to login
      if (user == null && !isGuest && !isLoggingIn && !isOnboarding) {
        return '/login';
      }

      // Rule 3: If logged in or guest, and trying to access login/onboarding, go home
      if ((user != null || isGuest) && (isLoggingIn || isOnboarding)) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Login Screen
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

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
          return MainNavigationScreen(child: child);
        },
        routes: [
          // Home
          GoRoute(
            path: '/home',
            builder: (context, state) {
              final labelId = state.uri.queryParameters['labelId'];
              return HomeScreen(initialLabelId: labelId);
            },
          ),

          // Search
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),

          // Labels (Spaces)
          GoRoute(
            path: '/labels',
            builder: (context, state) => const LabelsScreen(),
          ),

          // Trash
          GoRoute(
            path: '/trash',
            builder: (context, state) => const TrashScreen(),
          ),

          // Archived
          GoRoute(
            path: '/archived',
            builder: (context, state) => const ArchivedScreen(),
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
});

class AuthListenable extends ChangeNotifier {
  AuthListenable(Ref ref) {
    _authSubscription = ref.listen(authStateProvider, (_, __) {
      notifyListeners();
    });
    _guestSubscription = ref.listen(isGuestProvider, (_, __) {
      notifyListeners();
    });
  }

  late final ProviderSubscription _authSubscription;
  late final ProviderSubscription _guestSubscription;

  @override
  void dispose() {
    _authSubscription.close();
    _guestSubscription.close();
    super.dispose();
  }
}

class MainNavigationScreen extends ConsumerStatefulWidget {
  final Widget child;

  const MainNavigationScreen({super.key, required this.child});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showNewNoteSheet(BuildContext context) {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(40),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 32),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'CREATE NEW',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 32),
                _NewNoteTile(
                  icon: Icons.notes_rounded,
                  title: 'Studio Note',
                  subtitle: 'Rich text and media editor',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push('/note/new?type=text');
                  },
                ),
                const SizedBox(height: 16),
                _NewNoteTile(
                  icon: Icons.checklist_rounded,
                  title: 'Task List',
                  subtitle: 'Organize with checkable items',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push('/note/new?type=checklist');
                  },
                ),
                const SizedBox(height: 16),
                _NewNoteTile(
                  icon: Icons.auto_fix_high_rounded,
                  title: 'AI Draft',
                  subtitle: 'Generate ideas with Intelligence',
                  comingSoon: true,
                  onTap: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final bool forceHide = ref.watch(hideBottomNavProvider);

    return Scaffold(
      extendBody: true,
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
          return FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            fillColor: theme.colorScheme.surface,
            child: child,
          );
        },
        child: widget.child,
      ),
      floatingActionButton: (isKeyboardVisible || forceHide)
          ? null
          : Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: RawMaterialButton(
                onPressed: () => _showNewNoteSheet(context),
                shape: const CircleBorder(),
                elevation: 0,
                child: const Icon(
                  Icons.add_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: (isKeyboardVisible || forceHide)
          ? null
          : Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              height: 72,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _NavBarItem(
                          icon: Icons.home_outlined,
                          activeIcon: Icons.home_rounded,
                          label: 'Home',
                          isActive: _currentIndex == 0,
                          onTap: () => _onNavTap(0),
                        ),
                        _NavBarItem(
                          icon: Icons.search_rounded,
                          activeIcon: Icons.search_rounded,
                          label: 'Search',
                          isActive: _currentIndex == 1,
                          onTap: () => _onNavTap(1),
                        ),
                        const SizedBox(width: 48), // Spacer for FAB
                        _NavBarItem(
                          icon: Icons.folder_outlined,
                          activeIcon: Icons.folder_rounded,
                          label: 'Spaces',
                          isActive: _currentIndex == 2,
                          onTap: () => _onNavTap(2),
                        ),
                        _NavBarItem(
                          icon: Icons.settings_outlined,
                          activeIcon: Icons.settings_rounded,
                          label: 'Settings',
                          isActive: _currentIndex == 3,
                          onTap: () => _onNavTap(3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void _onNavTap(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/labels');
        break;
      case 3:
        context.go('/settings');
        break;
    }
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(isActive ? activeIcon : icon, color: color, size: 26),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewNoteTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool comingSoon;

  const _NewNoteTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: comingSoon ? null : onTap,
      borderRadius: BorderRadius.circular(24),
      child: Opacity(
        opacity: comingSoon ? 0.6 : 1.0,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.2),
                      theme.colorScheme.primary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (comingSoon)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'SOON',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      fontSize: 8,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
