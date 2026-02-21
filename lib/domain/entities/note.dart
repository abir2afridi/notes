import 'package:equatable/equatable.dart';
import '../../data/models/rich_note_model.dart';

class Note extends Equatable {
  final String id;
  final String title;
  final String content;
  final String type; // 'text' or 'checklist'
  final DateTime createdAt;
  final DateTime modifiedAt;
  final RichNoteContent? richContent;
  final DateTime? reminderAt;
  final String backgroundColor;
  final bool isPinned;
  final bool isArchived;
  final bool isDeleted;
  final String? backgroundImagePath;
  final List<String> labelIds;
  final List<String> attachments;
  final List<ChecklistItem> checklistItems;
  final String? metadata;
  final double bgOpacity;
  final double toolbarOpacity;
  final DateTime? deletedAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    required this.modifiedAt,
    this.reminderAt,
    this.backgroundColor = '#FFFFFF',
    this.isPinned = false,
    this.isArchived = false,
    this.isDeleted = false,
    this.backgroundImagePath,
    this.richContent,
    this.labelIds = const [],
    this.attachments = const [],
    this.checklistItems = const [],
    this.metadata,
    this.bgOpacity = 0.15,
    this.toolbarOpacity = 0.15,
    this.deletedAt,
  });

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? type,
    DateTime? createdAt,
    DateTime? modifiedAt,
    DateTime? reminderAt,
    String? backgroundColor,
    bool? isPinned,
    bool? isArchived,
    bool? isDeleted,
    List<String>? labelIds,
    List<String>? attachments,
    List<ChecklistItem>? checklistItems,
    String? backgroundImagePath,
    String? metadata,
    RichNoteContent? richContent,
    double? bgOpacity,
    double? toolbarOpacity,
    DateTime? deletedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      reminderAt: reminderAt ?? this.reminderAt,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      labelIds: labelIds ?? this.labelIds,
      attachments: attachments ?? this.attachments,
      checklistItems: checklistItems ?? this.checklistItems,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      metadata: metadata ?? this.metadata,
      richContent: richContent ?? this.richContent,
      bgOpacity: bgOpacity ?? this.bgOpacity,
      toolbarOpacity: toolbarOpacity ?? this.toolbarOpacity,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    content,
    type,
    createdAt,
    modifiedAt,
    reminderAt,
    backgroundColor,
    isPinned,
    isArchived,
    isDeleted,
    labelIds,
    attachments,
    checklistItems,
    backgroundImagePath,
    metadata,
    richContent,
    bgOpacity,
    toolbarOpacity,
    deletedAt,
  ];
}

class ChecklistItem extends Equatable {
  final String id;
  final String text;
  final bool isChecked;

  const ChecklistItem({
    required this.id,
    required this.text,
    this.isChecked = false,
  });

  ChecklistItem copyWith({String? id, String? text, bool? isChecked}) {
    return ChecklistItem(
      id: id ?? this.id,
      text: text ?? this.text,
      isChecked: isChecked ?? this.isChecked,
    );
  }

  @override
  List<Object?> get props => [id, text, isChecked];
}
