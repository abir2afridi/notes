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
      title: 'Organize Effortlessly',
      description:
          'Create spaces for your thoughts, projects, and daily tasks with powerful organization tools.',
      lottieUrl:
          'https://assets8.lottiefiles.com/packages/lf20_m6cu9scu.json', // Premium organization animation
      gradient: [Color(0xFF6750A4), Color(0xFFD0BCFF)],
    ),
    _OnboardingSlide(
      title: 'Smart Tagging',
      description:
          'Our AI automatically categorizes your notes with relevant tags and links.',
      lottieUrl:
          'https://assets3.lottiefiles.com/packages/lf20_w51pcehl.json', // Search/AI animation
      gradient: [Color(0xFF0061A4), Color(0xFFD1E4FF)],
    ),
    _OnboardingSlide(
      title: 'Secure Cloud Sync',
      description:
          'Access your notes from any device with real-time Firebase synchronization.',
      lottieUrl:
          'https://assets10.lottiefiles.com/packages/lf20_ygl8v08m.json', // Cloud sync animation
      gradient: [Color(0xFF137FEC), Color(0xFFD3E4FF)],
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
                              : theme.colorScheme.primary.withValues(
                                  alpha: 0.25,
                                ),
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
                              : 'Next Step',
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
                ? gradient.map((c) => c.withValues(alpha: 0.7)).toList()
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
                      color: theme.colorScheme.onPrimary.withValues(
                        alpha: 0.85,
                      ),
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
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
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
    final colorScheme = theme.colorScheme;

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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Personalize',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Set up your canvas exactly how you want it to be. You can change these later in settings.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          _buildSectionHeader(context, 'Visual Style', Icons.palette_outlined),
          const SizedBox(height: 16),

          // Theme Mode
          Text('Theme mode', style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<AppThemeMode>(
              segments: themeModeSegments,
              showSelectedIcon: true,
              selected: {themeMode},
              onSelectionChanged: (selection) =>
                  onThemeModeChanged(selection.first),
              style: SegmentedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Color Palette
          Text('Color palette', style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: vibrantThemes.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final name = vibrantThemes[index];
                final colors = VibrantThemes.getThemeColors(name, false);
                final selected = vibrantTheme == name;
                return GestureDetector(
                  onTap: () => onVibrantThemeChanged(name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected
                          ? colorScheme.primaryContainer
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ColorSwatchDot(color: colors.primary),
                            const SizedBox(width: 4),
                            _ColorSwatchDot(color: colors.secondary),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _prettyName(name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: selected
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          _buildSectionHeader(
            context,
            'Typography & Content',
            Icons.text_fields_rounded,
          ),
          const SizedBox(height: 16),

          // Font Size
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Font size', style: theme.textTheme.titleSmall),
              Text(
                '${fontSize.toStringAsFixed(0)}px',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: fontSize,
            min: 14,
            max: 24,
            divisions: 10,
            onChanged: onFontSizeChanged,
          ),

          const SizedBox(height: 24),

          // Note Color
          Text('Default note color', style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppConstants.noteColors.take(6).map((colorHex) {
              final selected = noteColor == colorHex;
              final color = AppTheme.getNoteColor(colorHex);
              final isLight =
                  ThemeData.estimateBrightnessForColor(color) ==
                  Brightness.light;
              return GestureDetector(
                onTap: () => onNoteColorChanged(colorHex),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant.withValues(alpha: 0.3),
                      width: selected ? 3 : 1,
                    ),
                  ),
                  child: selected
                      ? Icon(
                          Icons.check,
                          size: 20,
                          color: isLight ? Colors.black : Colors.white,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          _buildSectionHeader(
            context,
            'Connectivity',
            Icons.cloud_done_outlined,
          ),
          const SizedBox(height: 12),

          // Sync Information
          // Sync Information
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sync_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cloud Sync Ready',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your notes will be automatically synchronized across all your devices.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
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
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
    );
  }
}
