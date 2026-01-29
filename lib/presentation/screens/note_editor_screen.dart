import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import '../../domain/entities/note.dart';
import '../../core/constants/app_constants.dart';
import '../providers/note_provider.dart';
import '../providers/settings_providers.dart';
import '../utils/wallpaper_loader.dart';
import '../widgets/wallpaper_picker_sheet.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;
  final String noteType;

  const NoteEditorScreen({super.key, this.noteId, this.noteType = 'text'});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  late quill.QuillController _contentController;
  late String _selectedColor;
  String? _selectedWallpaper;
  bool _isLoading = false;
  bool _isExistingNote = false;
  Note? _originalNote;

  @override
  void initState() {
    super.initState();
    _contentController = quill.QuillController.basic();
    _selectedColor = ref.read(defaultNoteColorProvider);
    _selectedWallpaper = ref.read(defaultWallpaperProvider);
    if (widget.noteId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadNote();
      });
    }
  }

  Future<void> _loadNote() async {
    final repository = ref.read(noteRepositoryProvider);
    final note = await repository.getNoteById(widget.noteId!);

    if (!mounted) return;

    if (note != null) {
      setState(() {
        _originalNote = note;
        _isExistingNote = true;
        _titleController.text = note.title;

        // Load Quill Delta from metadata if available, otherwise from plain text content
        if (note.metadata != null && note.metadata!.isNotEmpty) {
          try {
            final json = jsonDecode(note.metadata!);
            _contentController = quill.QuillController(
              document: quill.Document.fromJson(json),
              selection: const TextSelection.collapsed(offset: 0),
            );
          } catch (e) {
            debugPrint('Failed to decode metadata (Delta): $e');
            _loadPlaintextContent(note.content);
          }
        } else {
          _loadPlaintextContent(note.content);
        }

        _selectedColor = note.backgroundColor;
        _selectedWallpaper = note.backgroundImagePath ?? _selectedWallpaper;
      });
    }
  }

  void _loadPlaintextContent(String content) {
    if (content.isNotEmpty) {
      _contentController = quill.QuillController(
        document: quill.Document()..insert(0, content),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _openWallpaperSheet() async {
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
        selectedPath: _selectedWallpaper,
        allowNoWallpaper: true,
      ),
    );

    if (!mounted || selectedPath == null) return;

    setState(() {
      _selectedWallpaper = selectedPath.isEmpty ? null : selectedPath;
    });
  }

  Future<void> _saveOrDeleteParams() async {
    final title = _titleController.text.trim();
    final content = _contentController.document.toPlainText().trim();

    if (title.isEmpty && content.isEmpty) return;

    await _saveNote(silent: true);
  }

  Future<void> _saveNote({bool silent = false}) async {
    final title = _titleController.text.trim();
    final plainText = _contentController.document.toPlainText().trim();

    if (title.isEmpty && plainText.isEmpty) {
      if (!silent) _showMessage('Please add a title or content');
      return;
    }

    if (!silent) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final now = DateTime.now();
      final noteId = widget.noteId ?? now.millisecondsSinceEpoch.toString();

      // Save content as plain text (for search/preview) and metadata as Delta JSON
      final deltaJson = jsonEncode(
        _contentController.document.toDelta().toJson(),
      );

      final note = Note(
        id: noteId,
        title: title,
        content: plainText,
        metadata: deltaJson,
        type: widget.noteType,
        createdAt: _isExistingNote ? _originalNote?.createdAt ?? now : now,
        modifiedAt: now,
        backgroundColor: _selectedColor,
        isPinned: _originalNote?.isPinned ?? false,
        isArchived: _originalNote?.isArchived ?? false,
        isDeleted: _originalNote?.isDeleted ?? false,
        backgroundImagePath: _selectedWallpaper,
        labelIds: _originalNote?.labelIds ?? [],
        attachments: _originalNote?.attachments ?? [],
        checklistItems: _originalNote?.checklistItems ?? [],
        reminderAt: _originalNote?.reminderAt,
      );

      if (widget.noteId == null) {
        await ref.read(notesListProvider.notifier).addNote(note);
      } else {
        await ref.read(notesListProvider.notifier).updateNote(note);
      }

      if (mounted && !silent) {
        _showMessage('Note saved successfully');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted && !silent) {
        _showMessage('Error saving note: $e');
      }
    } finally {
      if (mounted && !silent) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasWallpaper =
        _selectedWallpaper != null && _selectedWallpaper!.isNotEmpty;
    final decorationImage = hasWallpaper
        ? DecorationImage(
            image: AssetImage(_selectedWallpaper!),
            fit: BoxFit.cover,
          )
        : null;
    final baseBackgroundColor = _selectedColor == '#FFFFFF'
        ? Theme.of(context).scaffoldBackgroundColor
        : _parseColor(_selectedColor);
    final scaffoldBackgroundColor = hasWallpaper
        ? Colors.black
        : baseBackgroundColor;

    final appBarBackgroundColor = hasWallpaper
        ? Colors.black.withOpacity(0.6)
        : _selectedColor == '#FFFFFF'
        ? Theme.of(context).colorScheme.primary
        : baseBackgroundColor;

    final appBarForegroundColor = hasWallpaper
        ? Colors.white
        : _selectedColor == '#FFFFFF'
        ? Theme.of(context).colorScheme.onPrimary
        : Colors.black87;

    final titleTextColor = hasWallpaper
        ? Colors.white
        : _selectedColor == '#FFFFFF'
        ? null
        : Colors.black87;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        await _saveOrDeleteParams();
        if (mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(widget.noteId == null ? 'New Note' : 'Edit Note'),
          backgroundColor: appBarBackgroundColor,
          foregroundColor: appBarForegroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await _saveOrDeleteParams();
              if (mounted) Navigator.of(context).pop();
            },
          ),
          actions: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            if (!_isLoading) ...[
              IconButton(
                icon: const Icon(Icons.wallpaper),
                onPressed: _openWallpaperSheet,
                tooltip: 'Change wallpaper',
              ),
              IconButton(icon: const Icon(Icons.save), onPressed: _saveNote),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'color':
                      _showColorPicker();
                      break;
                    case 'delete':
                      _deleteNote();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'color',
                    child: Row(
                      children: [
                        Icon(Icons.palette),
                        SizedBox(width: 8),
                        Text('Change color'),
                      ],
                    ),
                  ),
                  if (widget.noteId != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            color: hasWallpaper ? Colors.black : null,
            image: decorationImage,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: hasWallpaper
                  ? Colors.black.withOpacity(0.35)
                  : Colors.transparent,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: hasWallpaper ? Colors.white70 : null,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: titleTextColor,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                if (!hasWallpaper)
                  Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                Expanded(
                  child: quill.QuillEditor.basic(
                    configurations: quill.QuillEditorConfigurations(
                      controller: _contentController,
                      readOnly: false,
                      sharedConfigurations:
                          const quill.QuillSharedConfigurations(
                            locale: Locale('en'),
                          ),
                      placeholder: 'Start typing...',
                      padding: const EdgeInsets.all(16),
                      autoFocus: false,
                      expands: true,
                      customStyles: quill.DefaultStyles(
                        placeHolder: quill.DefaultTextBlockStyle(
                          TextStyle(
                            fontSize: 16,
                            color: hasWallpaper ? Colors.white54 : Colors.grey,
                          ),
                          const quill.VerticalSpacing(0, 0),
                          const quill.VerticalSpacing(0, 0),
                          null,
                        ),
                        paragraph: quill.DefaultTextBlockStyle(
                          TextStyle(
                            fontSize: 16,
                            color: hasWallpaper ? Colors.white : Colors.black87,
                            height: 1.5,
                          ),
                          const quill.VerticalSpacing(0, 0),
                          const quill.VerticalSpacing(0, 0),
                          null,
                        ),
                      ),
                    ),
                  ),
                ),
                _buildQuillToolbar(hasWallpaper),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuillToolbar(bool hasWallpaper) {
    return Container(
      decoration: BoxDecoration(
        color: hasWallpaper ? Colors.black87 : Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: quill.QuillToolbar.simple(
          configurations: quill.QuillSimpleToolbarConfigurations(
            controller: _contentController,
            showAlignmentButtons: false,
            showDirection: false,
            showFontFamily: false,
            showFontSize: true,
            showBoldButton: true,
            showItalicButton: true,
            showSmallButton: false,
            showUnderLineButton: true,
            showStrikeThrough: true,
            showInlineCode: true,
            showColorButton: true,
            showBackgroundColorButton: true,
            showClearFormat: true,
            showListNumbers: true,
            showListBullets: true,
            showListCheck: true,
            showCodeBlock: false,
            showQuote: true,
            showIndent: false,
            showLink: true,
            showUndo: true,
            showRedo: true,
            multiRowsDisplay: false,
            sharedConfigurations: const quill.QuillSharedConfigurations(
              locale: Locale('en'),
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose color'),
        content: SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.noteColors.map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _parseColor(color),
                    borderRadius: BorderRadius.circular(20),
                    border: _selectedColor == color
                        ? Border.all(color: Colors.black, width: 2)
                        : null,
                  ),
                  child: _selectedColor == color
                      ? const Icon(Icons.check, color: Colors.black, size: 20)
                      : null,
                ),
              );
            }).toList(),
          ),
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

  void _deleteNote() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This note will be moved to trash.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (widget.noteId != null) {
                ref.read(notesListProvider.notifier).deleteNote(widget.noteId!);
              }
              _showMessage('Note deleted');
              context.go('/home');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
