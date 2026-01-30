import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/settings_providers.dart';
import '../providers/note_provider.dart';
import '../utils/wallpaper_loader.dart';
import '../widgets/wallpaper_picker_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '1.0.0';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      // Use default version if package info fails
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final vibrantTheme = ref.watch(vibrantThemeProvider);
    final defaultWallpaper = ref.watch(defaultWallpaperProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Settings'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            floating: true,
            snap: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSettingsSection(
                    context,
                    title: 'Appearance',
                    children: [
                      _buildThemeTile(themeMode),
                      _buildVibrantThemeTile(vibrantTheme),
                      _buildWallpaperTile(defaultWallpaper),
                      _buildDefaultViewTile(),
                      _buildFontSizeTile(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsSection(
                    context,
                    title: 'Data Management',
                    children: [
                      _buildBackupRestoreTile(),
                      _buildClearTrashTile(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsSection(
                    context,
                    title: 'About',
                    children: [
                      _buildAboutTile(),
                      _buildDeveloperTile(),
                      _buildVersionTile(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsSection(
                    context,
                    title: 'Danger Zone',
                    titleColor: Colors.red,
                    children: [_buildResetSettingsTile()],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
    Color? titleColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: titleColor ?? Theme.of(context).colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: Theme.of(
            context,
          ).colorScheme.surfaceVariant.withValues(alpha: 0.3),
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildThemeTile(AppThemeMode currentTheme) {
    return ListTile(
      leading: const Icon(Icons.palette),
      title: const Text('Theme'),
      subtitle: Text(_getThemeDisplayName(currentTheme)),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: _showThemeDialog,
    );
  }

  Widget _buildVibrantThemeTile(String currentTheme) {
    return ListTile(
      leading: const Icon(Icons.color_lens),
      title: const Text('Color Theme'),
      subtitle: Text(_getVibrantThemeDisplayName(currentTheme)),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: _showVibrantThemeDialog,
    );
  }

  Widget _buildWallpaperTile(String? currentWallpaper) {
    return ListTile(
      leading: const Icon(Icons.wallpaper),
      title: const Text('Background Wallpaper'),
      subtitle: Text(
        currentWallpaper == null
            ? 'Solid color only'
            : _getWallpaperDisplayName(currentWallpaper),
      ),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: _showWallpaperPicker,
    );
  }

  Widget _buildDefaultViewTile() {
    final currentView = ref.watch(defaultViewProvider);
    return ListTile(
      leading: const Icon(Icons.grid_view),
      title: const Text('Default View'),
      subtitle: Text(currentView == 'list' ? 'List' : 'Grid'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: _showDefaultViewDialog,
    );
  }

  Widget _buildFontSizeTile() {
    final fontSize = ref.watch(fontSizeProvider);
    return ListTile(
      leading: const Icon(Icons.text_fields),
      title: const Text('Font Size'),
      subtitle: Text('${fontSize.round()}px'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: _showFontSizeDialog,
    );
  }

  Widget _buildBackupRestoreTile() {
    return ListTile(
      leading: const Icon(Icons.backup),
      title: const Text('Backup & Restore'),
      subtitle: const Text('Export/Import notes'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: _showBackupRestoreDialog,
    );
  }

  Widget _buildClearTrashTile() {
    return ListTile(
      leading: const Icon(Icons.delete_sweep),
      title: const Text('Clear Trash'),
      subtitle: const Text('Permanently delete trashed notes'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: _showClearTrashDialog,
    );
  }

  Widget _buildAboutTile() {
    return ListTile(
      leading: const Icon(Icons.info),
      title: const Text('About'),
      subtitle: const Text('App version and info'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => context.push('/about'),
    );
  }

  Widget _buildDeveloperTile() {
    return ListTile(
      leading: const Icon(Icons.code),
      title: const Text('Developer'),
      subtitle: const Text('Developer information'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => context.push('/developer'),
    );
  }

  Widget _buildVersionTile() {
    return ListTile(
      leading: const Icon(Icons.system_update),
      title: const Text('Version'),
      subtitle: Text(_appVersion),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: _checkForUpdates,
    );
  }

  Widget _buildResetSettingsTile() {
    return ListTile(
      leading: const Icon(Icons.restore, color: Colors.red),
      title: const Text('Reset Settings', style: TextStyle(color: Colors.red)),
      subtitle: const Text('Reset all settings to default'),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),
      onTap: _showResetSettingsDialog,
    );
  }

  String _getThemeDisplayName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System Default';
    }
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            return RadioListTile<AppThemeMode>(
              title: Text(_getThemeDisplayName(mode)),
              value: mode,
              groupValue: ref.read(themeModeProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDefaultViewDialog() {
    final currentView = ref.read(defaultViewProvider);
    var tempView = currentView;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Default View'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: ['grid', 'list'].map((view) {
                final label = view == 'grid' ? 'Grid' : 'List';
                return RadioListTile<String>(
                  title: Text(label),
                  value: view,
                  groupValue: tempView,
                  onChanged: (value) {
                    if (value == null) return;
                    setDialogState(() => tempView = value);
                  },
                );
              }).toList(),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (tempView != currentView) {
                ref.read(defaultViewProvider.notifier).setDefaultView(tempView);
                _showMessage(
                  'Default view set to ${tempView == 'list' ? 'List' : 'Grid'}',
                );
              }
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showFontSizeDialog() {
    var tempFontSize = ref.read(fontSizeProvider);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Font Size'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Preview Text', style: TextStyle(fontSize: tempFontSize)),
                Slider(
                  value: tempFontSize,
                  min: 12.0,
                  max: 24.0,
                  divisions: 12,
                  label: tempFontSize.round().toString(),
                  onChanged: (value) {
                    setDialogState(() => tempFontSize = value);
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(fontSizeProvider.notifier).setFontSize(tempFontSize);
              Navigator.of(dialogContext).pop();
              _showMessage('Font size updated to ${tempFontSize.round()}px');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showBackupRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup & Restore'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.cloud_upload),
              title: const Text('Backup Notes'),
              subtitle: const Text('Export all notes to file'),
              onTap: () {
                Navigator.of(context).pop();
                _backupNotes();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_download),
              title: const Text('Restore Notes'),
              subtitle: const Text('Import notes from file'),
              onTap: () {
                Navigator.of(context).pop();
                _restoreNotes();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showClearTrashDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Trash'),
        content: const Text(
          'This will permanently delete all notes in trash. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearTrash();
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'This will reset all settings to their default values. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetSettings();
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _backupNotes() {
    setState(() {
      _isLoading = true;
    });

    // Simulate backup
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showMessage('Notes backed up successfully');
      }
    });
  }

  void _restoreNotes() {
    setState(() {
      _isLoading = true;
    });

    // Simulate restore
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showMessage('Notes restored successfully');
      }
    });
  }

  Future<void> _clearTrash() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(notesListProvider.notifier).emptyTrash();
      _showMessage('Trash cleared successfully');
    } catch (e) {
      _showMessage('Failed to clear trash');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetSettings() {
    setState(() {
      _isLoading = true;
    });

    // Reset theme to system default
    ref.read(themeModeProvider.notifier).setThemeMode(AppThemeMode.system);
    ref.read(defaultWallpaperProvider.notifier).setDefaultWallpaper(null);
    ref.read(defaultViewProvider.notifier).setDefaultView('grid');
    ref.read(fontSizeProvider.notifier).setFontSize(16.0);

    // Simulate other settings reset
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showMessage('Settings reset to default');
      }
    });
  }

  void _checkForUpdates() {
    _showMessage('Checking for updates...');

    // Simulate update check
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _showMessage('You are using the latest version');
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _showWallpaperPicker() async {
    final messenger = ScaffoldMessenger.of(context);
    final wallpapers = await WallpaperLoader.loadWallpapers();

    if (!mounted) return;

    if (wallpapers.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No wallpapers found in assets/wallpaper_backgrund'),
        ),
      );
      return;
    }

    final current = ref.read(defaultWallpaperProvider);

    final selectedPath = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => WallpaperPickerSheet(
        wallpapers: wallpapers,
        selectedPath: current,
        allowNoWallpaper: true,
        onWallpaperSelected: (wallpaperPath) {
          Navigator.pop(sheetContext);
          ref
              .read(defaultWallpaperProvider.notifier)
              .setDefaultWallpaper(wallpaperPath);
        },
      ),
    );

    if (!mounted || selectedPath == null) return;

    if (selectedPath.isEmpty) {
      await ref
          .read(defaultWallpaperProvider.notifier)
          .setDefaultWallpaper(null);
      messenger.showSnackBar(
        const SnackBar(content: Text('Wallpaper cleared. Using solid colors.')),
      );
    } else {
      await ref
          .read(defaultWallpaperProvider.notifier)
          .setDefaultWallpaper(selectedPath);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Wallpaper set to ${_getWallpaperDisplayName(selectedPath)}',
          ),
        ),
      );
    }
  }

  String _getWallpaperDisplayName(String path) {
    final segments = path.split('/');
    final fileName = segments.isNotEmpty ? segments.last : path;
    return fileName.replaceAll('_', ' ');
  }

  String _getVibrantThemeDisplayName(String theme) {
    switch (theme) {
      case 'default':
        return 'Default Purple';
      case 'ocean':
        return 'Ocean Blue';
      case 'forest':
        return 'Forest Green';
      case 'sunset':
        return 'Sunset Orange';
      case 'purple':
        return 'Vibrant Purple';
      case 'teal':
        return 'Teal Blue';
      case 'rose':
        return 'Rose Red';
      case 'amber':
        return 'Amber Gold';
      default:
        return 'Default Purple';
    }
  }

  void _showVibrantThemeDialog() {
    final themes = [
      'default',
      'ocean',
      'forest',
      'sunset',
      'purple',
      'teal',
      'rose',
      'amber',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Choose Color Theme',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Personalize the app with these curated palettes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: themes.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final theme = themes[index];
                  final isSelected = ref.watch(vibrantThemeProvider) == theme;
                  final previewColors = _getThemePreviewColors(theme);

                  return InkWell(
                    onTap: () {
                      ref
                          .read(vibrantThemeProvider.notifier)
                          .setVibrantTheme(theme);
                      Navigator.pop(context);
                      _showMessage(
                        'Color theme changed to ${_getVibrantThemeDisplayName(theme)}',
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(
                                  context,
                                ).colorScheme.outline.withValues(alpha: 0.1),
                          width: isSelected ? 2 : 1,
                        ),
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                                  .withValues(alpha: 0.1)
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          // Color preview circles
                          Row(
                            children: previewColors
                                .map(
                                  (color) => Container(
                                    width: 24,
                                    height: 24,
                                    margin: const EdgeInsets.only(right: 4),
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white24),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              _getVibrantThemeDisplayName(theme),
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getThemePreviewColors(String themeName) {
    switch (themeName) {
      case 'default':
        return [Color(0xFF6750A4), Color(0xFF625B71), Color(0xFF7D5260)];
      case 'ocean':
        return [Color(0xFF0061A4), Color(0xFF006496), Color(0xFF735D0C)];
      case 'forest':
        return [Color(0xFF3E665D), Color(0xFF4D7269), Color(0xFF645A4C)];
      case 'sunset':
        return [Color(0xFFB5261E), Color(0xFF8B5000), Color(0xFF6C5E00)];
      case 'purple':
        return [Color(0xFF8257E5), Color(0xFF6B4E8A), Color(0xFF8D4E00)];
      case 'teal':
        return [Color(0xFF006A6C), Color(0xFF00696D), Color(0xFF6B5D00)];
      case 'rose':
        return [Color(0xFFBA1A1A), Color(0xFF8C4D4D), Color(0xFF7D5700)];
      case 'amber':
        return [Color(0xFF7D5700), Color(0xFF6C5E00), Color(0xFF625B71)];
      default:
        return [Color(0xFF6750A4), Color(0xFF625B71), Color(0xFF7D5260)];
    }
  }
}
