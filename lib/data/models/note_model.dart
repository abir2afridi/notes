import 'package:hive/hive.dart';
import '../../domain/entities/note.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime modifiedAt;

  @HiveField(6)
  final DateTime? reminderAt;

  @HiveField(7)
  final String backgroundColor;

  @HiveField(8)
  final bool isPinned;

  @HiveField(9)
  final bool isArchived;

  @HiveField(10)
  final bool isDeleted;

  @HiveField(11)
  final List<String> labelIds;

  @HiveField(12)
  final List<String> attachments;

  @HiveField(13)
  final List<ChecklistItemModel> checklistItems;

  @HiveField(14)
  final String? backgroundImagePath;

  @HiveField(15)
  final String? metadata;

  const NoteModel({
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
    this.labelIds = const [],
    this.attachments = const [],
    this.checklistItems = const [],
    this.backgroundImagePath,
    this.metadata,
  });

  // Convert from Domain Entity
  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      type: note.type,
      createdAt: note.createdAt,
      modifiedAt: note.modifiedAt,
      reminderAt: note.reminderAt,
      backgroundColor: note.backgroundColor,
      isPinned: note.isPinned,
      isArchived: note.isArchived,
      isDeleted: note.isDeleted,
      labelIds: note.labelIds,
      attachments: note.attachments,
      checklistItems: note.checklistItems
          .map((item) => ChecklistItemModel.fromEntity(item))
          .toList(),
      backgroundImagePath: note.backgroundImagePath,
      metadata: note.metadata,
    );
  }

  // Convert to Domain Entity
  Note toEntity() {
    return Note(
      id: id,
      title: title,
      content: content,
      type: type,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
      reminderAt: reminderAt,
      backgroundColor: backgroundColor,
      isPinned: isPinned,
      isArchived: isArchived,
      isDeleted: isDeleted,
      labelIds: labelIds,
      attachments: attachments,
      checklistItems: checklistItems.map((item) => item.toEntity()).toList(),
      backgroundImagePath: backgroundImagePath,
      metadata: metadata,
    );
  }

  NoteModel copyWith({
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
    List<ChecklistItemModel>? checklistItems,
    String? backgroundImagePath,
    String? metadata,
  }) {
    return NoteModel(
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
    );
  }
}

@HiveType(typeId: 1)
class ChecklistItemModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final bool isChecked;

  const ChecklistItemModel({
    required this.id,
    required this.text,
    this.isChecked = false,
  });

  // Convert from Domain Entity
  factory ChecklistItemModel.fromEntity(ChecklistItem item) {
    return ChecklistItemModel(
      id: item.id,
      text: item.text,
      isChecked: item.isChecked,
    );
  }

  // Convert to Domain Entity
  ChecklistItem toEntity() {
    return ChecklistItem(id: id, text: text, isChecked: isChecked);
  }

  ChecklistItemModel copyWith({String? id, String? text, bool? isChecked}) {
    return ChecklistItemModel(
      id: id ?? this.id,
      text: text ?? this.text,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
