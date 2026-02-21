import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../providers/label_provider.dart';

class LabelsScreen extends ConsumerWidget {
  const LabelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = ref.watch(labelsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'NOTE CRAFT',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'My Spaces',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.95,
                        ),
                        letterSpacing: -1.5,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                // Predefined system spaces
                if (index == 0) {
                  return _SpaceCard(
                    name: 'Archive',
                    description: 'Stored safely',
                    icon: Icons.inventory_2_rounded,
                    color: Colors.blueGrey,
                    highlightColor: Colors.blue,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/archived');
                    },
                  );
                }
                if (index == 1) {
                  return _SpaceCard(
                    name: 'Trash',
                    description: 'Recently junked',
                    icon: Icons.delete_sweep_rounded,
                    color: Colors.redAccent,
                    highlightColor: Colors.orange,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/trash');
                    },
                  );
                }

                // Offset index for custom labels
                final labelIndex = index - 2;
                if (labelIndex < labels.length) {
                  final label = labels[labelIndex];
                  final color = AppTheme.getNoteColor(label.color);
                  return _SpaceCard(
                    name: label.name,
                    description: 'Personal Space',
                    icon: Icons.folder_rounded,
                    color: color,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.go('/home?labelId=${label.id}');
                    },
                    onLongPress: () {
                      HapticFeedback.mediumImpact();
                      _showSpaceActions(context, ref, label.id, label.name);
                    },
                  );
                }

                if (labelIndex == labels.length) {
                  return _AddSpaceCard(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      _showAddLabelDialog(context, ref);
                    },
                  );
                }

                return null;
              }, childCount: labels.length + 3),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddLabelDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final notifier = ref.read(labelsProvider.notifier);
    final theme = Theme.of(context);

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
        title: Text(
          'New Space',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Give your new organization space a meaningful name.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              autofocus: true,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'e.g. Work, Journal, Travel',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              onSubmitted: (_) async {
                if (controller.text.trim().isNotEmpty) {
                  final success = await notifier.addLabel(controller.text);
                  if (context.mounted && success) Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              final success = await notifier.addLabel(controller.text);
              if (!context.mounted) return;
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Label name must be unique.')),
                );
                return;
              }
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text('CREATE'),
          ),
        ],
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  void _showSpaceActions(
    BuildContext context,
    WidgetRef ref,
    String labelId,
    String labelName,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.folder_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              labelName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Space Options',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.edit_rounded),
                  title: const Text('Rename Space'),
                  onTap: () {
                    Navigator.pop(context);
                    _showRenameLabelDialog(context, ref, labelId, labelName);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: theme.colorScheme.error,
                  ),
                  title: Text(
                    'Delete Space',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeleteLabel(context, ref, labelId, labelName);
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showRenameLabelDialog(
    BuildContext context,
    WidgetRef ref,
    String labelId,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);
    final notifier = ref.read(labelsProvider.notifier);
    final theme = Theme.of(context);

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Rename Space'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter new name',
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              final success = await notifier.renameLabel(
                labelId,
                controller.text,
              );
              if (!context.mounted) return;
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Label name must be unique.')),
                );
                return;
              }
              Navigator.of(context).pop();
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  Future<void> _confirmDeleteLabel(
    BuildContext context,
    WidgetRef ref,
    String labelId,
    String labelName,
  ) async {
    final theme = Theme.of(context);
    final notifier = ref.read(labelsProvider.notifier);

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            const Text('Delete Space'),
          ],
        ),
        content: Text(
          'Are you sure you want to remove "$labelName"? This will detach the space from all notes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('KEEP'),
          ),
          ElevatedButton(
            onPressed: () async {
              await notifier.deleteLabel(labelId);
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }
}

class _SpaceCard extends StatelessWidget {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final Color? highlightColor;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _SpaceCard({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.highlightColor,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(36),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.2),
                        (highlightColor ?? color).withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: color.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const Spacer(),
                Text(
                  name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.6,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddSpaceCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddSpaceCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 2,
          style: BorderStyle.none,
        ),
        color: theme.colorScheme.primary.withValues(alpha: 0.03),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(36),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Add Space',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
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
