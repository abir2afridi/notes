import 'package:equatable/equatable.dart';
import 'dart:convert';

/// Rich text content model for storing formatted notes
class RichNoteContent extends Equatable {
  final String deltaJson;
  final String plainText;
  final int length;
  final DateTime lastModified;
  final Map<String, dynamic> metadata;

  const RichNoteContent({
    required this.deltaJson,
    required this.plainText,
    required this.length,
    required this.lastModified,
    this.metadata = const {},
  });

  /// Create empty rich content
  factory RichNoteContent.empty() {
    final now = DateTime.now();
    return RichNoteContent(
      deltaJson: '{"ops":[{"insert":"\\n"}]}',
      plainText: '',
      length: 0,
      lastModified: now,
    );
  }

  /// Create from plain text (for migration)
  factory RichNoteContent.fromPlainText(String text) {
    final now = DateTime.now();
    final delta = {
      'ops': [
        if (text.isNotEmpty) {'insert': text},
        {'insert': '\n'},
      ],
    };

    return RichNoteContent(
      deltaJson: jsonEncode(delta),
      plainText: text,
      length: text.length,
      lastModified: now,
    );
  }

  /// Create from Delta JSON
  factory RichNoteContent.fromDelta(String deltaJson, String plainText) {
    return RichNoteContent(
      deltaJson: deltaJson,
      plainText: plainText,
      length: plainText.length,
      lastModified: DateTime.now(),
    );
  }

  /// Get Delta as List
  List<dynamic> get delta {
    try {
      return jsonDecode(deltaJson);
    } catch (e) {
      // Fallback to empty delta
      return [
        {'insert': '\n'},
      ];
    }
  }

  /// Check if content is empty
  bool get isEmpty => plainText.trim().isEmpty;

  /// Check if content has formatting
  bool get hasFormatting {
    try {
      final deltaMap = jsonDecode(deltaJson);
      final ops = deltaMap['ops'] as List?;
      if (ops == null) return false;

      for (final op in ops) {
        if (op is Map && op.containsKey('attributes')) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get preview text (first 100 characters)
  String get preview {
    if (plainText.length <= 100) return plainText;
    return '${plainText.substring(0, 100)}...';
  }

  /// Copy with updated content
  RichNoteContent copyWith({
    String? deltaJson,
    String? plainText,
    int? length,
    DateTime? lastModified,
    Map<String, dynamic>? metadata,
  }) {
    return RichNoteContent(
      deltaJson: deltaJson ?? this.deltaJson,
      plainText: plainText ?? this.plainText,
      length: length ?? this.length,
      lastModified: lastModified ?? this.lastModified,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Update content with new delta
  RichNoteContent updateContent(String newDeltaJson, String newPlainText) {
    return copyWith(
      deltaJson: newDeltaJson,
      plainText: newPlainText,
      length: newPlainText.length,
      lastModified: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    deltaJson,
    plainText,
    length,
    lastModified,
    metadata,
  ];

  @override
  String toString() {
    return 'RichNoteContent('
        'length: $length, '
        'hasFormatting: $hasFormatting, '
        'preview: "$preview", '
        'lastModified: $lastModified)';
  }
}

/// Text formatting styles
enum TextStyleOption {
  normal,
  heading1,
  heading2,
  heading3,
  bold,
  italic,
  underline,
  strikethrough,
  code,
  quote,
}

/// Text alignment options
enum TextAlignment { left, center, right, justify }

/// List types
enum ListType { none, bullet, ordered, checked, unchecked }

/// Color information for text and background
class TextColor extends Equatable {
  final String color;
  final String? backgroundColor;

  const TextColor({required this.color, this.backgroundColor});

  factory TextColor.black() => const TextColor(color: '#000000');
  factory TextColor.white() => const TextColor(color: '#FFFFFF');
  factory TextColor.red() => const TextColor(color: '#FF0000');
  factory TextColor.blue() => const TextColor(color: '#0000FF');
  factory TextColor.green() => const TextColor(color: '#00FF00');
  factory TextColor.yellow() => const TextColor(color: '#FFFF00');
  factory TextColor.purple() => const TextColor(color: '#800080');
  factory TextColor.orange() => const TextColor(color: '#FFA500');

  Map<String, dynamic> toDeltaAttributes() {
    final attrs = <String, dynamic>{};

    if (color != '#000000') {
      attrs['color'] = color;
    }

    if (backgroundColor != null) {
      attrs['background'] = backgroundColor;
    }

    return attrs.isEmpty ? {} : {'color': attrs};
  }

  @override
  List<Object?> get props => [color, backgroundColor];
}

/// Font size options
enum FontSize { small, normal, large, extraLarge }

extension FontSizeExtension on FontSize {
  String get deltaAttribute {
    switch (this) {
      case FontSize.small:
        return 'small';
      case FontSize.normal:
        return '';
      case FontSize.large:
        return 'large';
      case FontSize.extraLarge:
        return 'huge';
    }
  }
}

/// Utility class for creating Delta operations
class DeltaOperations {
  /// Create text operation with attributes
  static Map<String, dynamic> text(
    String text, [
    Map<String, dynamic>? attributes,
  ]) {
    final operation = <String, dynamic>{'insert': text};
    if (attributes != null && attributes.isNotEmpty) {
      operation['attributes'] = attributes;
    }
    return operation;
  }

  /// Create bold text
  static Map<String, dynamic> bold(String text) {
    return DeltaOperations.text(text, {'bold': true});
  }

  /// Create italic text
  static Map<String, dynamic> italic(String text) {
    return DeltaOperations.text(text, {'italic': true});
  }

  /// Create underline text
  static Map<String, dynamic> underline(String text) {
    return DeltaOperations.text(text, {'underline': true});
  }

  /// Create strikethrough text
  static Map<String, dynamic> strikethrough(String text) {
    return DeltaOperations.text(text, {'strike': true});
  }

  /// Create code text
  static Map<String, dynamic> code(String text) {
    return DeltaOperations.text(text, {'code': true});
  }

  /// Create heading
  static Map<String, dynamic> heading(String text, int level) {
    return DeltaOperations.text(text, {'header': level});
  }

  /// Create bullet list item
  static Map<String, dynamic> bulletListItem(String text) {
    return DeltaOperations.text(text, {'list': 'bullet'});
  }

  /// Create ordered list item
  static Map<String, dynamic> orderedListItem(String text) {
    return DeltaOperations.text(text, {'list': 'ordered'});
  }

  /// Create checked list item
  static Map<String, dynamic> checkedListItem(String text, bool checked) {
    return DeltaOperations.text(text, {'list': 'checked', 'checked': checked});
  }

  /// Create quote
  static Map<String, dynamic> quote(String text) {
    return DeltaOperations.text(text, {'blockquote': true});
  }

  /// Create colored text
  static Map<String, dynamic> colored(String text, String color) {
    return DeltaOperations.text(text, {'color': color});
  }

  /// Create highlighted text
  static Map<String, dynamic> highlighted(String text, String backgroundColor) {
    return DeltaOperations.text(text, {'background': backgroundColor});
  }

  /// Create text with font size
  static Map<String, dynamic> sized(String text, FontSize size) {
    final attr = size.deltaAttribute;
    return attr.isEmpty
        ? DeltaOperations.text(text)
        : DeltaOperations.text(text, {attr: true});
  }

  /// Create alignment
  static Map<String, dynamic> align(TextAlignment alignment) {
    String alignValue;
    switch (alignment) {
      case TextAlignment.center:
        alignValue = 'center';
        break;
      case TextAlignment.right:
        alignValue = 'right';
        break;
      case TextAlignment.justify:
        alignValue = 'justify';
        break;
      case TextAlignment.left:
        alignValue = '';
        break;
    }

    return {
      'insert': '\n',
      'attributes': {'align': alignValue},
    };
  }

  /// Create newline
  static Map<String, dynamic> newline([Map<String, dynamic>? attributes]) {
    final operation = <String, dynamic>{'insert': '\n'};
    if (attributes != null && attributes.isNotEmpty) {
      operation['attributes'] = attributes;
    }
    return operation;
  }
}
