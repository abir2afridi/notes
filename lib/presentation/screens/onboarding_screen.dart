import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/vibrant_theme.dart';
import '../providers/first_launch_provider.dart';
import '../providers/settings_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  late AppThemeMode _selectedThemeMode;
  late String _selectedVibrantTheme;
  late double _selectedFontSize;
  late String _selectedNoteColor;

  int _currentPage = 0;

  static final List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      title: 'Capture Everything',
      description:
          'Quickly jot down thoughts, voice memos, and checklists with a tap.',
      lottieUrl: 'https://assets1.lottiefiles.com/packages/lf20_q5pk6p1k.json',
      gradient: [Color(0xFF6C63FF), Color(0xFF3F3D56)],
    ),
    _OnboardingSlide(
      title: 'Stay Organized',
      description:
          'Group notes with colorful labels, pin favorites, and find anything instantly.',
      lottieUrl:
          'https://assets2.lottiefiles.com/packages/lf20_KvK0ZJBQ0R.json',
      gradient: [Color(0xFF00B4DB), Color(0xFF0083B0)],
    ),
    _OnboardingSlide(
      title: 'Sync & Secure',
      description:
          'Your ideas stay safe and accessible whether you are online or offline.',
      lottieUrl: 'https://assets4.lottiefiles.com/packages/lf20_touohxv0.json',
      gradient: [Color(0xFFFF8748), Color(0xFFFFCC66)],
    ),
  ];

  int get _totalPages => _slides.length + 1; // +1 for setup page

  @override
  void initState() {
    super.initState();
    _selectedThemeMode = ref.read(themeModeProvider);
    _selectedVibrantTheme = ref.read(vibrantThemeProvider);
    _selectedFontSize = ref.read(fontSizeProvider);
    _selectedNoteColor = ref.read(defaultNoteColorProvider);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final vibrantNotifier = ref.read(vibrantThemeProvider.notifier);
    final fontNotifier = ref.read(fontSizeProvider.notifier);
    final colorNotifier = ref.read(defaultNoteColorProvider.notifier);

    await Future.wait([
      themeNotifier.setThemeMode(_selectedThemeMode),
      vibrantNotifier.setVibrantTheme(_selectedVibrantTheme),
      fontNotifier.setFontSize(_selectedFontSize),
      colorNotifier.setDefaultColor(_selectedNoteColor),
    ]);

    await ref.read(firstLaunchProvider.notifier).completeFirstLaunch();

    if (mounted) {
      context.go('/home');
    }
  }

  void _onSkip() {
    _handleComplete();
  }

  void _onNext() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _handleComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _currentPage > 0 ? 1 : 0,
                    child: TextButton(
                      onPressed: _currentPage > 0
                          ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                            )
                          : null,
                      child: const Text('Back'),
                    ),
                  ),
                  TextButton(onPressed: _onSkip, child: const Text('Skip')),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  if (index < _slides.length) {
                    final slide = _slides[index];
                    return _OnboardingSlideView(slide: slide, dark: isDark);
                  }
                  return _SetupPage(
                    themeMode: _selectedThemeMode,
                    vibrantTheme: _selectedVibrantTheme,
                    fontSize: _selectedFontSize,
                    noteColor: _selectedNoteColor,
                    onThemeModeChanged: (mode) => setState(() {
                      _selectedThemeMode = mode;
                    }),
                    onVibrantThemeChanged: (themeName) => setState(() {
                      _selectedVibrantTheme = themeName;
                    }),
                    onFontSizeChanged: (size) => setState(() {
                      _selectedFontSize = size;
                    }),
                    onNoteColorChanged: (color) => setState(() {
                      _selectedNoteColor = color;
                    }),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _totalPages,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: _currentPage == index ? 28 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primary.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _currentPage == _totalPages - 1
                              ? 'Get Started'
                              : 'Next',
                          key: ValueKey(_currentPage == _totalPages - 1),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
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

class _OnboardingSlide {
  final String title;
  final String description;
  final String lottieUrl;
  final List<Color> gradient;

  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.lottieUrl,
    required this.gradient,
  });
}

class _OnboardingSlideView extends StatelessWidget {
  final _OnboardingSlide slide;
  final bool dark;

  const _OnboardingSlideView({required this.slide, required this.dark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = slide.gradient;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: dark
                ? gradient.map((c) => c.withOpacity(0.7)).toList()
                : gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Lottie.network(
                    slide.lottieUrl,
                    repeat: true,
                    fit: BoxFit.contain,
                    frameRate: FrameRate.max,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.emoji_objects,
                      color: theme.colorScheme.onPrimary.withOpacity(0.85),
                      size: 120,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onPrimary.withOpacity(0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupPage extends StatelessWidget {
  final AppThemeMode themeMode;
  final String vibrantTheme;
  final double fontSize;
  final String noteColor;
  final ValueChanged<AppThemeMode> onThemeModeChanged;
  final ValueChanged<String> onVibrantThemeChanged;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<String> onNoteColorChanged;

  const _SetupPage({
    required this.themeMode,
    required this.vibrantTheme,
    required this.fontSize,
    required this.noteColor,
    required this.onThemeModeChanged,
    required this.onVibrantThemeChanged,
    required this.onFontSizeChanged,
    required this.onNoteColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final vibrantThemes = VibrantThemes.themes.keys.toList();
    final themeModeSegments = <ButtonSegment<AppThemeMode>>[
      const ButtonSegment(
        value: AppThemeMode.system,
        icon: Icon(Icons.auto_mode),
        label: Text('System'),
      ),
      const ButtonSegment(
        value: AppThemeMode.light,
        icon: Icon(Icons.light_mode),
        label: Text('Light'),
      ),
      const ButtonSegment(
        value: AppThemeMode.dark,
        icon: Icon(Icons.dark_mode),
        label: Text('Dark'),
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Make it yours',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your preferred theme, text size, and note color. You can always change these later in Settings.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text('Theme mode', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          SegmentedButton<AppThemeMode>(
            segments: themeModeSegments,
            showSelectedIcon: false,
            selected: {themeMode},
            onSelectionChanged: (selection) =>
                onThemeModeChanged(selection.first),
          ),
          const SizedBox(height: 24),
          Text('Color palette', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: vibrantThemes.map((name) {
              final colors = VibrantThemes.getThemeColors(name, false);
              final selected = vibrantTheme == name;
              return GestureDetector(
                onTap: () => onVibrantThemeChanged(name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      width: selected ? 2.5 : 1.2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ColorSwatchDot(color: colors.primary),
                          const SizedBox(width: 6),
                          _ColorSwatchDot(color: colors.secondary),
                          const SizedBox(width: 6),
                          _ColorSwatchDot(color: colors.tertiary),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _prettyName(name),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Default note color', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: AppConstants.noteColors.map((colorHex) {
              final selected = noteColor == colorHex;
              final color = AppTheme.getNoteColor(colorHex);
              final brightness = ThemeData.estimateBrightnessForColor(color);
              return GestureDetector(
                onTap: () => onNoteColorChanged(colorHex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      width: selected ? 3 : 1.2,
                    ),
                  ),
                  child: selected
                      ? Icon(
                          Icons.check,
                          color: brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Default font size', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              showValueIndicator: ShowValueIndicator.always,
            ),
            child: Slider(
              value: fontSize,
              min: 14,
              max: 24,
              divisions: 10,
              label: fontSize.toStringAsFixed(0),
              onChanged: onFontSizeChanged,
            ),
          ),
        ],
      ),
    );
  }

  String _prettyName(String key) {
    return key[0].toUpperCase() + key.substring(1);
  }
}

class _ColorSwatchDot extends StatelessWidget {
  final Color color;

  const _ColorSwatchDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 1),
      ),
    );
  }
}
