import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/settings_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    if (!AppConstants.firebaseSyncEnabled) {
      _showSyncDisabledError();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithGoogle();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('] ')
            ? e.toString().split('] ').last
            : e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _skipLogin() {
    ref.read(isGuestProvider.notifier).setGuestMode(true);
    context.go('/home');
  }

  void _showSyncDisabledError() {
    setState(() {
      _errorMessage = 'Cloud sync is currently disabled in app settings.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.2),
              colorScheme.surface,
              colorScheme.secondaryContainer.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo & Title
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        size: 56,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppConstants.appName,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your moments. Beautifully organized.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 48),

                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.error.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: colorScheme.error,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Google Sign In
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      icon: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const FaIcon(FontAwesomeIcons.google, size: 18),
                      label: const Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Skip Option
                  TextButton(
                    onPressed: _isLoading ? null : _skipLogin,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Skip for now',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant.withValues(
                              alpha: 0.8,
                            ),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
