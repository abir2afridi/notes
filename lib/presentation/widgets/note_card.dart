import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

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
    final theme = Theme.of(context);
    final backgroundColor = _parseColor(note.backgroundColor);

    String? wallpaperPath;
    if (note.backgroundImagePath?.isNotEmpty == true) {
      wallpaperPath = note.backgroundImagePath;
    } else if (defaultWallpaper?.isNotEmpty == true) {
      wallpaperPath = defaultWallpaper;
    }

    final hasWallpaper = wallpaperPath != null;
    final brightness = ThemeData.estimateBrightnessForColor(backgroundColor);

    final primaryTextColor = hasWallpaper
        ? Colors.white
        : brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;

    final secondaryTextColor = hasWallpaper
        ? Colors.white.withValues(alpha: 0.8)
        : primaryTextColor.withValues(alpha: 0.6);

    final title = note.title.trim().isEmpty ? 'Untitled' : note.title.trim();
    final content = note.content.trim();

    final labelNames = note.labelIds
        .map((id) => labelLookup[id])
        .where((label) => label != null)
        .cast<Label>()
        .toList();

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: hasWallpaper ? Colors.black : backgroundColor,
                image: hasWallpaper
                    ? DecorationImage(
                        image: AssetImage(wallpaperPath),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withValues(alpha: 0.4),
                          BlendMode.darken,
                        ),
                      )
                    : null,
                border: Border.all(
                  color: hasWallpaper
                      ? Colors.white.withValues(alpha: 0.1)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (note.attachments.isNotEmpty)
                        _buildImagePreview(note.attachments.first),

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: primaryTextColor,
                                          letterSpacing: -0.5,
                                          height: 1.2,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (note.isPinned) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.push_pin_rounded,
                                    size: 14,
                                    color: primaryTextColor.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (content.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                content,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: secondaryTextColor,
                                  height: 1.5,
                                  fontSize: 13,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (labelNames.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: labelNames
                                    .map(
                                      (label) => _buildLabelChip(
                                        label,
                                        primaryTextColor,
                                        hasWallpaper,
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('MMM d').format(note.modifiedAt),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: secondaryTextColor.withValues(
                                      alpha: 0.4,
                                    ),
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Row(
                                  children: [
                                    if (note.attachments.isNotEmpty)
                                      _buildIndicatorIcon(
                                        Icons.image_outlined,
                                        secondaryTextColor,
                                      ),
                                    if (note.type == 'checklist')
                                      _buildIndicatorIcon(
                                        Icons.checklist_rounded,
                                        secondaryTextColor,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Glassmorphic overlay if using wallpaper
                  if (hasWallpaper)
                    Positioned.fill(
                      child: ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 0.5),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.4),
                                ],
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildImagePreview(String path) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildLabelChip(Label label, Color textColor, bool hasWallpaper) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: hasWallpaper
            ? Colors.white.withValues(alpha: 0.15)
            : textColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasWallpaper
              ? Colors.white.withValues(alpha: 0.1)
              : textColor.withValues(alpha: 0.1),
        ),
      ),
      child: Text(
        label.name,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildIndicatorIcon(IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Icon(icon, size: 14, color: color.withValues(alpha: 0.3)),
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
