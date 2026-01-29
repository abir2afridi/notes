import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/label.dart';
import '../../domain/entities/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final Map<String, Label> labelLookup;
  final String? defaultWallpaper;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const NoteCard({
    super.key,
    required this.note,
    required this.labelLookup,
    required this.defaultWallpaper,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _parseColor(note.backgroundColor);
    String? wallpaperPath;
    if (note.backgroundImagePath?.isNotEmpty == true) {
      wallpaperPath = note.backgroundImagePath;
    } else if (defaultWallpaper?.isNotEmpty == true) {
      wallpaperPath = defaultWallpaper;
    }
    final hasWallpaper = wallpaperPath != null;
    final DecorationImage? backgroundImage = wallpaperPath == null
        ? null
        : DecorationImage(image: AssetImage(wallpaperPath), fit: BoxFit.cover);
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    final primaryTextColor = hasWallpaper
        ? Colors.white
        : brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
    final secondaryTextColor = hasWallpaper
        ? Colors.white.withOpacity(0.85)
        : primaryTextColor.withOpacity(0.75);

    final title = note.title.trim().isEmpty
        ? 'Untitled note'
        : note.title.trim();
    final content = note.content.trim();
    final labelNames = note.labelIds
        .map((id) => labelLookup[id])
        .where((label) => label != null)
        .cast<Label>()
        .toList();

    final cardColor = hasWallpaper ? Colors.black : backgroundColor;
    final overlayColor = hasWallpaper
        ? Colors.black.withOpacity(0.35)
        : backgroundColor.withOpacity(0.95);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            image: backgroundImage,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: overlayColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: primaryTextColor,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.isPinned) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.push_pin, size: 18, color: secondaryTextColor),
                    ],
                  ],
                ),
                if (content.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: secondaryTextColor),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (labelNames.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: labelNames
                        .map(
                          (label) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: hasWallpaper
                                  ? Colors.white24
                                  : AppTheme.getNoteColor(
                                      label.color,
                                    ).withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              label.name,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: hasWallpaper
                                        ? Colors.white
                                        : secondaryTextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  DateFormat('MMM d, yyyy • h:mm a').format(note.modifiedAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: secondaryTextColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (_) {
      return Colors.white;
    }
  }
}
