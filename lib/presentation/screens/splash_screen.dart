import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../core/constants/app_constants.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutBack),
    );

    _init();
  }

  Future<void> _init() async {
    // Start animations immediately
    _logoController.forward();
    _textController.forward();

    // 1. HARD FAIL-SAFE: The Absolute Deadline
    final hardDeadline = Timer(const Duration(seconds: 6), () {
      debugPrint('SPLASH TIMEOUT: Force-navigating to home.');
      if (mounted) context.go('/home');
    });

    try {
      // 2. Parallel Startup Sequence with specific timeouts
      final results = await Future.wait([
        SharedPreferences.getInstance().timeout(const Duration(seconds: 3)),
        Future.delayed(const Duration(milliseconds: 1800)), // Visual minimum
      ]).timeout(const Duration(seconds: 5));

      final SharedPreferences prefs = results[0] as SharedPreferences;

      // 3. Firebase (if enabled) - Non-blocking relative to splash duration
      if (AppConstants.firebaseSyncEnabled) {
        await Firebase.initializeApp()
            .catchError((e) {
              debugPrint('Firebase init within splash failed: $e');
              return Firebase.app();
            })
            .timeout(const Duration(seconds: 2));
      }

      // 4. Versioned Installation Detection
      final currentVersion = AppConstants.appVersion;
      final lastRunVersion = prefs.getString('last_run_version') ?? '';
      final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;

      await prefs.setString('last_run_version', currentVersion);

      hardDeadline.cancel();

      if (mounted) {
        // Only show onboarding for absolute fresh installs on this device
        if (isFirstLaunch && lastRunVersion.isEmpty) {
          context.go('/onboarding');
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      hardDeadline.cancel();
      debugPrint('SPLASH RECOVERY LOGIC TRIGGERED: $e');
      if (mounted) context.go('/home');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.tertiary,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Mesh Gradient Background
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(
                    context,
                  ).colorScheme.tertiaryContainer.withValues(alpha: 0.2),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Animation
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _logoAnimation,
                      _textAnimation,
                    ]),
                    builder: (context, child) {
                      final opacity = _logoAnimation.value.clamp(0.0, 1.0);
                      return Opacity(
                        opacity: opacity,
                        child: Transform.scale(
                          scale: _logoAnimation.value,
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(36),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.edit_note_rounded,
                              size: 72,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 48),

                  // App Name Animation
                  AnimatedBuilder(
                    animation: _textAnimation,
                    builder: (context, child) {
                      final opacity = _textAnimation.value.clamp(0.0, 1.0);
                      return Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - _textAnimation.value)),
                          child: Column(
                            children: [
                              Text(
                                AppConstants.appName,
                                style: Theme.of(context).textTheme.displayMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -1.5,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Elevate your thoughts',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 100),

                  // Loading Indicator
                  AnimatedBuilder(
                    animation: _textAnimation,
                    builder: (context, child) {
                      final opacity = _textAnimation.value.clamp(0.0, 1.0);
                      return Opacity(
                        opacity: opacity,
                        child: const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
