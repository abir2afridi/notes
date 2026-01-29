import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
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
  State<SimpleWorkingEditor> createState() => _SimpleWorkingEditorState();
}

class _SimpleWorkingEditorState extends State<SimpleWorkingEditor> {
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
    return Column(
      children: [
        // Editor Area - Expanded to take space
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: QuillEditor.basic(
              controller: _controller,
              focusNode: _focusNode,
            ),
          ),
        ),

        // Dynamic bottom toolbar that feels part of the screen
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: widget.toolbarOpacity),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          child: _buildFormattingToolbar(),
        ),
        // Add space for the keyboard
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 0 : 8),
      ],
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
        ],
      ),
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
    _controller.formatSelection(attribute);
  }

  bool _isAttributeApplied(Attribute attribute) {
    final style = _controller.getSelectionStyle();
    final attr = style.attributes[attribute.key];
    if (attr == null) return false;
    return attr.value == attribute.value;
  }
}
