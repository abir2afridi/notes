// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rich_note_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RichNoteContentAdapter extends TypeAdapter<RichNoteContent> {
  @override
  final int typeId = 3;

  @override
  RichNoteContent read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RichNoteContent(
      deltaJson: fields[0] as String,
      plainText: fields[1] as String,
      length: fields[2] as int,
      lastModified: fields[3] as DateTime,
      metadata: (fields[4] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, RichNoteContent obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.deltaJson)
      ..writeByte(1)
      ..write(obj.plainText)
      ..writeByte(2)
      ..write(obj.length)
      ..writeByte(3)
      ..write(obj.lastModified)
      ..writeByte(4)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RichNoteContentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
