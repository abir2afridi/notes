import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'dart:ui';
import '../../data/models/rich_note_model.dart';

/// Frameless Rich Text Editor with integrated toolbar
class SimpleWorkingEditor extends StatefulWidget {
  final RichNoteContent? initialContent;
  final Function(RichNoteContent) onContentChanged;
  final FocusNode? focusNode;
  final bool autoFocus;
  final String? placeholder;
  final double toolbarOpacity;

  const SimpleWorkingEditor({
    super.key,
    this.initialContent,
    required this.onContentChanged,
    this.focusNode,
    this.autoFocus = false,
    this.placeholder,
    this.toolbarOpacity = 0.15,
  });

  @override
  State<SimpleWorkingEditor> createState() => SimpleWorkingEditorState();
}

class SimpleWorkingEditorState extends State<SimpleWorkingEditor> {
  late QuillController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _initializeController();
  }

  void _initializeController() {
    if (widget.initialContent != null) {
      try {
        final delta = widget.initialContent!.delta;
        final document = Document.fromJson(delta);
        _controller = QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
        );
      } catch (e) {
        _controller = QuillController.basic();
      }
    } else {
      _controller = QuillController.basic();
    }

    _controller.addListener(_handleControllerChange);

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Only autofocus if the editor isn't already focused
        if (!_focusNode.hasFocus) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  void _handleControllerChange() {
    if (!mounted) return;
    setState(() {}); // Updates the local toolbar state
    _notifyContentChanged();
  }

  void _notifyContentChanged() {
    final delta = _controller.document.toDelta();
    final plainText = _controller.document.toPlainText();

    final richContent = RichNoteContent.fromDelta(
      jsonEncode(delta.toJson()),
      plainText,
    );

    widget.onContentChanged(richContent);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    _controller.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        0,
        20,
        80,
      ), // More bottom padding for floating tools
      child: QuillEditor.basic(
        controller: _controller,
        focusNode: _focusNode,
        config: QuillEditorConfig(
          placeholder: widget.placeholder ?? 'Start typing...',
          autoFocus: widget.autoFocus,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  // Making this public so NoteEditorScreen can use it in its Stack
  Widget buildToolbar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surface.withValues(alpha: widget.toolbarOpacity),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: _buildFormattingToolbar(),
        ),
      ),
    );
  }

  Widget _buildFormattingToolbar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFormatButton(
            icon: Icons.format_bold,
            tooltip: 'Bold',
            isActive: _isAttributeApplied(Attribute.bold),
            onPressed: () => _formatSelection(Attribute.bold),
          ),
          _buildFormatButton(
            icon: Icons.format_italic,
            tooltip: 'Italic',
            isActive: _isAttributeApplied(Attribute.italic),
            onPressed: () => _formatSelection(Attribute.italic),
          ),
          _buildFormatButton(
            icon: Icons.format_underlined,
            tooltip: 'Underline',
            isActive: _isAttributeApplied(Attribute.underline),
            onPressed: () => _formatSelection(Attribute.underline),
          ),
          Container(
            height: 20,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          _buildFormatButton(
            icon: Icons.format_list_bulleted,
            tooltip: 'Bullet List',
            isActive: _isAttributeApplied(Attribute.ul),
            onPressed: () => _formatSelection(Attribute.ul),
          ),
          _buildFormatButton(
            icon: Icons.format_list_numbered,
            tooltip: 'Numbered List',
            isActive: _isAttributeApplied(Attribute.ol),
            onPressed: () => _formatSelection(Attribute.ol),
          ),
          Container(
            height: 20,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          // NEW: Color Picker Tool
          _buildColorPickerButton(),
          // NEW: Text Style Tool
          _buildStylePickerButton(),
        ],
      ),
    );
  }

  Widget _buildColorPickerButton() {
    final colors = [
      {'name': 'Black', 'color': Colors.black},
      {'name': 'Blue', 'color': Colors.blue},
      {'name': 'Red', 'color': Colors.red},
      {'name': 'Green', 'color': Colors.green},
      {'name': 'Orange', 'color': Colors.orange},
      {'name': 'Purple', 'color': Colors.purple},
      {'name': 'Deep Purple', 'color': Colors.deepPurple},
      {'name': 'Amber', 'color': Colors.amber},
      {'name': 'Teal', 'color': Colors.teal},
      {'name': 'Grey', 'color': Colors.grey},
    ];

    return IconButton(
      icon: const Icon(Icons.format_color_text),
      tooltip: 'Text Color',
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) => Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
                const SizedBox(height: 16),
                const Text(
                  'Select Text Color',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: colors.map((c) {
                    final color = c['color'] as Color;
                    return GestureDetector(
                      onTap: () {
                        _controller.formatSelection(
                          ColorAttribute(
                            '#${color.toARGB32().toRadixString(16).substring(2)}',
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStylePickerButton() {
    return IconButton(
      icon: const Icon(Icons.text_fields),
      tooltip: 'Text Style',
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.format_size),
                title: const Text('Heading 1'),
                onTap: () {
                  _controller.formatSelection(Attribute.h1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.format_size),
                title: const Text('Heading 2'),
                onTap: () {
                  _controller.formatSelection(Attribute.h2);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.text_format),
                title: const Text('Body Text'),
                onTap: () {
                  _controller.formatSelection(
                    Attribute.clone(Attribute.h1, null),
                  );
                  _controller.formatSelection(
                    Attribute.clone(Attribute.h2, null),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormatButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        tooltip: tooltip,
        iconSize: 22,
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        style: IconButton.styleFrom(
          backgroundColor: isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  void _formatSelection(Attribute attribute) {
    final isApplied = _isAttributeApplied(attribute);
    if (isApplied) {
      // Toggle off
      _controller.formatSelection(Attribute.clone(attribute, null));
    } else {
      // Toggle on
      _controller.formatSelection(attribute);
    }
  }

  bool _isAttributeApplied(Attribute attribute) {
    final style = _controller.getSelectionStyle();
    final attr = style.attributes[attribute.key];
    if (attr == null) return false;
    return attr.value == attribute.value;
  }
}
