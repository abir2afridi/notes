import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/rich_text_editor.dart';
// import '../widgets/wallpaper_picker_sheet.dart'; // No longer used as integrated
import '../../data/models/rich_note_model.dart';
import '../../domain/entities/note.dart';
import '../providers/note_provider.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;
  final String noteType;

  const NoteEditorScreen({super.key, this.noteId, this.noteType = 'text'});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  RichNoteContent? _richContent;
  late String _selectedColor;
  String? _selectedWallpaper;
  bool _isLoading = false;
  bool _isExistingNote = false;
  bool _isPinned = false;
  double _bgOpacity = 0.15;
  double _toolbarOpacity = 0.15;
  Note? _originalNote;
  final FocusNode _titleFocusNode = FocusNode();
  bool _isTitleFocused = false;

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
        if (context.canPop()) {
          context.pop();
        } else {
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

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(notesListProvider.notifier).moveToTrash(widget.noteId!);
      if (mounted) {
        context.pop();
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _saveNote();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
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
                          // Minimalist Title Area with Focus Animation
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _isTitleFocused
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            child: TextField(
                              controller: _titleController,
                              focusNode: _titleFocusNode,
                              decoration: InputDecoration(
                                hintText: 'Title',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.4),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: SimpleWorkingEditor(
                              initialContent: _richContent,
                              // Only use toolbarOpacity if we have a special background
                              toolbarOpacity:
                                  (_selectedWallpaper != null ||
                                      _selectedColor != '#FFFFFF')
                                  ? _toolbarOpacity
                                  : 1.0,
                              onContentChanged: (content) {
                                _richContent = content;
                              },
                              placeholder: 'Start typing...',
                              autoFocus: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Header extending to status bar
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color:
                            (_selectedWallpaper != null ||
                                _selectedColor != '#FFFFFF')
                            ? Colors.transparent
                            : Theme.of(context).colorScheme.primary,
                        child: SafeArea(
                          bottom: false,
                          child: AppBar(
                            title: Text(
                              _isExistingNote ? 'Edit Note' : 'New Note',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Colors
                                .transparent, // Always transparent within container
                            foregroundColor:
                                (_selectedWallpaper != null ||
                                    _selectedColor != '#FFFFFF')
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.onPrimary,
                            elevation: 0,
                            surfaceTintColor: Colors.transparent,
                            actions: [
                              IconButton(
                                icon: const Icon(Icons.save),
                                onPressed: _saveNote,
                              ),
                              IconButton(
                                icon: Icon(
                                  _isPinned
                                      ? Icons.push_pin
                                      : Icons.push_pin_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPinned = !_isPinned;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () => _showMoreOptions(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Customize Note',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),

                // Color Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.palette_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Background Color',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _getAvailableColors().length,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemBuilder: (context, index) {
                      final colorHex = _getAvailableColors()[index];
                      final isSelected = _selectedColor == colorHex;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedColor = colorHex);
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Color(
                              int.parse(colorHex.replaceAll('#', '0xFF')),
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey.withValues(alpha: 0.2),
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 20,
                                  color:
                                      ThemeData.estimateBrightnessForColor(
                                            Color(
                                              int.parse(
                                                colorHex.replaceAll(
                                                  '#',
                                                  '0xFF',
                                                ),
                                              ),
                                            ),
                                          ) ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Wallpaper Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.wallpaper_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Wallpapers',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _getAvailableWallpapers().length + 1,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // "None" option
                        final isSelected = _selectedWallpaper == null;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedWallpaper = null),
                          child: Container(
                            width: 70,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.block, color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      final wpPath = _getAvailableWallpapers()[index - 1];
                      final isSelected = _selectedWallpaper == wpPath;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedWallpaper = wpPath),
                        child: Container(
                          width: 70,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                            image: DecorationImage(
                              image: AssetImage(wpPath),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: isSelected
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(),

                // Sliders
                ListTile(
                  leading: const Icon(Icons.opacity),
                  title: const Text('Background Visibility'),
                  subtitle: Slider(
                    value: _bgOpacity,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (val) {
                      setSheetState(() => _bgOpacity = val);
                      setState(() {});
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.blur_on),
                  title: const Text('Toolbar Visibility'),
                  subtitle: Slider(
                    value: _toolbarOpacity,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (val) {
                      setSheetState(() => _toolbarOpacity = val);
                      setState(() {});
                    },
                  ),
                ),

                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Delete Note',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteNote();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _getAvailableColors() {
    return [
      '#FFFFFF',
      '#F28B82',
      '#FBBC04',
      '#FFF475',
      '#CCFF90',
      '#A7FFEB',
      '#CBF0F8',
      '#AECBFA',
      '#D7AEFB',
      '#FDCFE8',
      '#E6C9A8',
      '#E8EAED',
    ];
  }

  List<String> _getAvailableWallpapers() {
    return List.generate(
      13,
      (i) => 'assets/wallpaper_backgrund/wall${i + 1}.jpg',
    );
  }
}
