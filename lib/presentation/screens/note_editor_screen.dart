import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/rich_text_editor.dart';
import '../../data/models/rich_note_model.dart';
import '../../domain/entities/note.dart';
import '../providers/note_provider.dart';
import '../providers/label_provider.dart';
import '../providers/ui_state_provider.dart';
import '../../core/theme/app_theme.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;
  final String noteType;

  const NoteEditorScreen({super.key, this.noteId, this.noteType = 'text'});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final GlobalKey<SimpleWorkingEditorState> _editorKey =
      GlobalKey<SimpleWorkingEditorState>();
  RichNoteContent? _richContent;
  late String _selectedColor;
  String? _selectedWallpaper;
  bool _isLoading = false;
  bool _isExistingNote = false;
  bool _isPinned = false;
  double _bgOpacity = 0.15;
  double _toolbarOpacity = 0.15;
  Note? _originalNote;
  bool _isTitleFocused = false;
  List<String> _selectedLabelIds = [];
  List<String> _attachments = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedColor = '#FFFFFF';
    _titleFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isTitleFocused = _titleFocusNode.hasFocus;
        });
      }
    });
    _loadNote();

    // Hide bottom navigation bar in shell when editor is open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(hideBottomNavProvider.notifier).state = true;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    if (widget.noteId != null) {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _isExistingNote = true;
        });
      }

      try {
        final notes = ref.read(notesListProvider);
        final note = notes.firstWhere((n) => n.id == widget.noteId);
        _originalNote = note;
        _titleController.text = note.title;
        _richContent = note.richContent ?? RichNoteContent.empty();
        _selectedColor = note.backgroundColor;
        _selectedWallpaper = note.backgroundImagePath;
        _isPinned = note.isPinned;
        _bgOpacity = note.bgOpacity;
        _toolbarOpacity = note.toolbarOpacity;
        _selectedLabelIds = List.from(note.labelIds);
        _attachments = List.from(note.attachments);
      } catch (e) {
        _isExistingNote = false;
        _richContent = RichNoteContent.empty();
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      _richContent = RichNoteContent.empty();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          _attachments.add(image.path);
        });
      }
    } catch (e) {
      _showMessage('Failed to pick image');
    }
  }

  Future<void> _saveNote() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final now = DateTime.now();
      final note =
          (_originalNote ??
                  Note(
                    id:
                        widget.noteId ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    title: '',
                    content: '',
                    type: widget.noteType,
                    createdAt: now,
                    modifiedAt: now,
                  ))
              .copyWith(
                title: _titleController.text,
                content: _richContent?.plainText ?? '',
                richContent: _richContent,
                backgroundColor: _selectedColor,
                backgroundImagePath: _selectedWallpaper,
                isPinned: _isPinned,
                bgOpacity: _bgOpacity,
                toolbarOpacity: _toolbarOpacity,
                labelIds: _selectedLabelIds,
                attachments: _attachments,
                modifiedAt: now,
              );

      if (_isExistingNote) {
        await ref.read(notesListProvider.notifier).updateNote(note);
      } else {
        await ref.read(notesListProvider.notifier).addNote(note);
      }

      // Force a tiny delay to ensure state propagates, though updateNote is async
      await Future.delayed(const Duration(milliseconds: 50));

      _showMessage('Note saved successfully!');

      if (mounted) {
        // Restore bottom navigation bar before navigating back
        ref.read(hideBottomNavProvider.notifier).state = false;

        if (context.canPop()) {
          context.pop();
        } else {
          HapticFeedback.mediumImpact();
          context.go('/home');
        }
      }
    } catch (e) {
      _showMessage('Failed to save note');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _deleteNote() async {
    if (widget.noteId == null) return;

    final confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(
              Icons.delete_sweep_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 12),
            const Text('Move to Trash?'),
          ],
        ),
        content: const Text(
          'Your thoughts will be kept in the junk for 30 days before they vanish forever.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'KEEP IT',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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

    if (confirmed == true && mounted) {
      await ref.read(notesListProvider.notifier).moveToTrash(widget.noteId!);
      if (mounted) {
        ref.read(hideBottomNavProvider.notifier).state = false;
        context.pop();
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: isError
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color:
                (isError ? theme.colorScheme.error : theme.colorScheme.primary)
                    .withValues(alpha: 0.2),
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Restore bottom navigation bar when popping via system back/swipe
          ref.read(hideBottomNavProvider.notifier).state = false;
          _saveNote();
        }
      },
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: theme.colorScheme.surface,
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: _selectedWallpaper != null
                          ? Colors.transparent
                          : (_selectedColor == '#FFFFFF'
                                ? Theme.of(context).colorScheme.surface
                                : Color(
                                    int.parse(
                                      _selectedColor.replaceAll('#', '0xFF'),
                                    ),
                                  )),
                      image: _selectedWallpaper != null
                          ? DecorationImage(
                              image: AssetImage(_selectedWallpaper!),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                (_selectedColor == '#FFFFFF'
                                        ? Colors
                                              .black // Default blend for white/none
                                        : Color(
                                            int.parse(
                                              _selectedColor.replaceAll(
                                                '#',
                                                '0xFF',
                                              ),
                                            ),
                                          ))
                                    .withValues(alpha: _bgOpacity),
                                BlendMode.darken,
                              ),
                            )
                          : null,
                    ),
                    child: Stack(
                      children: [
                        // Main Content Scrollable
                        SafeArea(
                          bottom: false,
                          child: Column(
                            children: [
                              // Space for the transparent appBar
                              const SizedBox(height: kToolbarHeight),

                              // Image Attachments Section
                              if (_attachments.isNotEmpty)
                                Container(
                                  height: 180,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    itemCount: _attachments.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        width: 140,
                                        margin: const EdgeInsets.only(
                                          right: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.2,
                                            ),
                                          ),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.file(
                                              File(_attachments[index]),
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: GestureDetector(
                                                onTap: () {
                                                  HapticFeedback.lightImpact();
                                                  setState(() {
                                                    _attachments.removeAt(
                                                      index,
                                                    );
                                                  });
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    4,
                                                  ),
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.black54,
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    size: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),

                              // Minimalist Title Area with Focus Animation
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  8,
                                  20,
                                  8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: _isTitleFocused
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.primary
                                                .withValues(alpha: 0.05),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: TextField(
                                  controller: _titleController,
                                  focusNode: _titleFocusNode,
                                  decoration: InputDecoration(
                                    hintText: 'Title',
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    hintStyle: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.3),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: SimpleWorkingEditor(
                                  key: _editorKey,
                                  initialContent: _richContent,
                                  onContentChanged: (content) {
                                    _richContent = content;
                                  },
                                  placeholder: 'Start typing...',
                                  autoFocus: true,
                                ),
                              ),
                              // Last Edited Indicator
                              if (_originalNote != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 110,
                                    top: 8,
                                  ),
                                  child: Text(
                                    'Edited ${_formatModifiedTime(_originalNote!.modifiedAt)}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.4),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Floating Toolbar managed via GlobalKey
                        Positioned(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                          left: 0,
                          right: 0,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: _isTitleFocused ? 0.0 : 1.0,
                            child: AbsorbPointer(
                              absorbing: _isTitleFocused,
                              child: _editorKey.currentState != null
                                  ? _editorKey.currentState!.buildToolbar(
                                      context,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ),
                        // Header extending to status bar
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      (_selectedWallpaper != null ||
                                          _selectedColor != '#FFFFFF')
                                      ? Colors.black.withValues(alpha: 0.2)
                                      : theme.colorScheme.surface.withValues(
                                          alpha: 0.8,
                                        ),
                                  border: Border(
                                    bottom: BorderSide(
                                      color: theme.colorScheme.outline
                                          .withValues(alpha: 0.1),
                                    ),
                                  ),
                                ),
                                child: SafeArea(
                                  bottom: false,
                                  child: Container(
                                    height: kToolbarHeight,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        _HeaderIconButton(
                                          icon:
                                              Icons.arrow_back_ios_new_rounded,
                                          onPressed: () {
                                            HapticFeedback.mediumImpact();
                                            _saveNote();
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.auto_awesome_rounded,
                                                    size: 10,
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'NOTE CRAFT',
                                                    style: theme
                                                        .textTheme
                                                        .labelSmall
                                                        ?.copyWith(
                                                          color: theme
                                                              .colorScheme
                                                              .primary,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          letterSpacing: 1.2,
                                                          fontSize: 10,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                _isExistingNote
                                                    ? 'Editor'
                                                    : 'Studio',
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      letterSpacing: -0.5,
                                                      height: 1.1,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _HeaderIconButton(
                                          icon:
                                              Icons.add_photo_alternate_rounded,
                                          tooltip: 'Attach Image',
                                          onPressed: () {
                                            HapticFeedback.lightImpact();
                                            _pickImage(ImageSource.gallery);
                                          },
                                        ),
                                        _HeaderIconButton(
                                          icon: _isPinned
                                              ? Icons.push_pin_rounded
                                              : Icons.push_pin_outlined,
                                          tooltip: _isPinned ? 'Unpin' : 'Pin',
                                          onPressed: () {
                                            HapticFeedback.selectionClick();
                                            setState(() {
                                              _isPinned = !_isPinned;
                                            });
                                          },
                                        ),
                                        _HeaderIconButton(
                                          icon: Icons.more_vert_rounded,
                                          tooltip: 'More Options',
                                          onPressed: () {
                                            HapticFeedback.mediumImpact();
                                            _showMoreOptions(context);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Note Studio',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Style Grid
                _buildStudioSection('Appearance', [
                  _buildColorGrid(setSheetState),
                  const SizedBox(height: 16),
                  _buildWallpaperGrid(setSheetState),
                ]),

                const SizedBox(height: 24),

                // Organization
                _buildStudioSection('Spaces', [
                  _buildLabelsList(setSheetState),
                ]),

                const SizedBox(height: 24),

                // Refinement
                _buildStudioSection('Refinement', [
                  _buildSlider(
                    'Background Opacity',
                    Icons.opacity_rounded,
                    _bgOpacity,
                    (val) {
                      setSheetState(() => _bgOpacity = val);
                      setState(() {});
                    },
                  ),
                  _buildSlider(
                    'Toolbar Presence',
                    Icons.blur_on_rounded,
                    _toolbarOpacity,
                    (val) {
                      setSheetState(() => _toolbarOpacity = val);
                      setState(() {});
                    },
                  ),
                ]),

                const SizedBox(height: 32),

                // Danger Zone
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteNote();
                    },
                    icon: const Icon(Icons.delete_sweep_rounded, size: 20),
                    label: const Text('Move to Trash'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: theme.colorScheme.error.withValues(alpha: 0.1),
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
    );
  }

  Widget _buildStudioSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildColorGrid(StateSetter setSheetState) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: _getAvailableColors().length,
        itemBuilder: (context, index) {
          final colorHex = _getAvailableColors()[index];
          final color = Color(int.parse(colorHex.replaceAll('#', '0xFF')));
          final isSelected = _selectedColor == colorHex;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setSheetState(() => _selectedColor = colorHex);
                setState(() {});
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.black.withValues(alpha: 0.1),
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check_rounded,
                        size: 20,
                        color:
                            ThemeData.estimateBrightnessForColor(color) ==
                                Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWallpaperGrid(StateSetter setSheetState) {
    final wallpapers = _getAvailableWallpapers();
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: wallpapers.length + 1,
        itemBuilder: (context, index) {
          final isNone = index == 0;
          final path = isNone ? null : wallpapers[index - 1];
          final isSelected = _selectedWallpaper == path;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                setSheetState(() => _selectedWallpaper = path);
                setState(() {});
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.black.withValues(alpha: 0.1),
                    width: isSelected ? 3 : 1,
                  ),
                  image: !isNone
                      ? DecorationImage(
                          image: AssetImage(path!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: isNone ? Colors.grey.withValues(alpha: 0.1) : null,
                ),
                child: isNone
                    ? const Icon(Icons.block_rounded, color: Colors.grey)
                    : isSelected
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabelsList(StateSetter setSheetState) {
    return Consumer(
      builder: (context, ref, _) {
        final labels = ref.watch(labelsProvider);
        if (labels.isEmpty) {
          return Center(
            child: Text(
              'No spaces yet',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: labels.map((label) {
                final isSelected = _selectedLabelIds.contains(label.id);
                final color = AppTheme.getNoteColor(label.color);
                final theme = Theme.of(context);

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setSheetState(() {
                        if (isSelected) {
                          _selectedLabelIds.remove(label.id);
                        } else {
                          _selectedLabelIds.add(label.id);
                        }
                      });
                      setState(() {});
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.1,
                                ),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            label.name,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlider(
    String label,
    IconData icon,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '${(value * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
          Slider(value: value, min: 0.0, max: 1.0, onChanged: onChanged),
        ],
      ),
    );
  }

  String _formatModifiedTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${time.day}/${time.month}/${time.year}';
  }

  List<String> _getAvailableColors() {
    return [
      '#FFFFFF', // None
      '#FF80AB', // Soft Pink
      '#FF8A80', // Coral
      '#FFD180', // Peach
      '#FFFF8D', // Soft Yellow
      '#CCFF90', // Mint
      '#A7FFEB', // Teal
      '#80D8FF', // Sky Blue
      '#82B1FF', // Ocean
      '#B388FF', // Lavender
      '#F8BBD0', // Rose
      '#CFD8DC', // Blue Grey
    ];
  }

  List<String> _getAvailableWallpapers() {
    return List.generate(
      13,
      (i) => 'assets/wallpaper_backgrund/wall${i + 1}.jpg',
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback onPressed;

  const _HeaderIconButton({
    required this.icon,
    this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 24),
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
