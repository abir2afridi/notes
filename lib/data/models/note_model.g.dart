// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 0;

  @override
  NoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteModel(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      type: fields[3] as String,
      createdAt: fields[4] as DateTime,
      modifiedAt: fields[5] as DateTime,
      reminderAt: fields[6] as DateTime?,
      backgroundColor: fields[7] as String,
      isPinned: fields[8] as bool,
      isArchived: fields[9] as bool,
      isDeleted: fields[10] as bool,
      labelIds: (fields[11] as List).cast<String>(),
      attachments: (fields[12] as List).cast<String>(),
      checklistItems: (fields[13] as List).cast<ChecklistItemModel>(),
      backgroundImagePath: fields[14] as String?,
      metadata: fields[15] as String?,
      richContent: fields[16] as RichNoteContent?,
      bgOpacity: fields[17] as double,
      toolbarOpacity: fields[18] as double,
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.modifiedAt)
      ..writeByte(6)
      ..write(obj.reminderAt)
      ..writeByte(7)
      ..write(obj.backgroundColor)
      ..writeByte(8)
      ..write(obj.isPinned)
      ..writeByte(9)
      ..write(obj.isArchived)
      ..writeByte(10)
      ..write(obj.isDeleted)
      ..writeByte(11)
      ..write(obj.labelIds)
      ..writeByte(12)
      ..write(obj.attachments)
      ..writeByte(13)
      ..write(obj.checklistItems)
      ..writeByte(14)
      ..write(obj.backgroundImagePath)
      ..writeByte(15)
      ..write(obj.metadata)
      ..writeByte(16)
      ..write(obj.richContent)
      ..writeByte(17)
      ..write(obj.bgOpacity)
      ..writeByte(18)
      ..write(obj.toolbarOpacity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChecklistItemModelAdapter extends TypeAdapter<ChecklistItemModel> {
  @override
  final int typeId = 1;

  @override
  ChecklistItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChecklistItemModel(
      id: fields[0] as String,
      text: fields[1] as String,
      isChecked: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ChecklistItemModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.isChecked);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChecklistItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
