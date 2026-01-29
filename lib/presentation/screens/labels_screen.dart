import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../providers/label_provider.dart';

class LabelsScreen extends ConsumerWidget {
  const LabelsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = ref.watch(labelsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Labels'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Create new label',
                onPressed: () => _showAddLabelDialog(context, ref),
              ),
            ],
          ),
          if (labels.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyLabelsState(
                onCreate: () => _showAddLabelDialog(context, ref),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final label = labels[index];
                  final color = AppTheme.getNoteColor(label.color);

                  return Card(
                    elevation: 0,
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.3),
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.label,
                          size: 20,
                          color: Colors.black54,
                        ),
                      ),
                      title: Text(
                        label.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        'Created ${_formatTimeAgo(label.createdAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onTap: () => _showRenameLabelDialog(
                        context,
                        ref,
                        label.id,
                        label.name,
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'rename') {
                            _showRenameLabelDialog(
                              context,
                              ref,
                              label.id,
                              label.name,
                            );
                          } else if (value == 'delete') {
                            _confirmDeleteLabel(
                              context,
                              ref,
                              label.id,
                              label.name,
                            );
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'rename',
                            child: ListTile(
                              leading: Icon(Icons.edit_outlined),
                              title: Text('Rename'),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              title: Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: labels.length),
              ),
            ),
        ],
      ),
      floatingActionButton: labels.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showAddLabelDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('New Label'),
            )
          : null,
    );
  }

  Future<void> _showAddLabelDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final notifier = ref.read(labelsProvider.notifier);
    final theme = Theme.of(context);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create label'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Label name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final success = await notifier.addLabel(controller.text);
              if (!context.mounted) return;
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Label name must be unique.')),
                );
                return;
              }
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Label "${controller.text.trim()}" created'),
                  backgroundColor: theme.colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Create'),
          ),
        ],
      ),
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

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename label'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Label name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteLabel(
    BuildContext context,
    WidgetRef ref,
    String labelId,
    String labelName,
  ) async {
    final notifier = ref.read(labelsProvider.notifier);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete label'),
        content: Text('Remove "$labelName" and detach it from all notes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () async {
              await notifier.deleteLabel(labelId);
              if (!context.mounted) return;
              Navigator.of(context).pop();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Label deleted')));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _EmptyLabelsState extends StatelessWidget {
  const _EmptyLabelsState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.label_outline, size: 88, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'Organize with labels',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Create personal categories to keep similar notes grouped together. Labels can be added to notes at any time.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create a label'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTimeAgo(DateTime date) {
  final difference = DateTime.now().difference(date);
  if (difference.inDays >= 1) {
    return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
  }
  if (difference.inHours >= 1) {
    return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
  }
  if (difference.inMinutes >= 1) {
    return '${difference.inMinutes} min${difference.inMinutes == 1 ? '' : 's'} ago';
  }
  return 'Just now';
}
