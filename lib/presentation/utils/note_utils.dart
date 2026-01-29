import '../../domain/entities/note.dart';

String buildShareContent(Note note) {
  final buffer = StringBuffer();

  if (note.title.isNotEmpty) {
    buffer.writeln(note.title);
    buffer.writeln();
  }

  if (note.content.isNotEmpty) {
    buffer.writeln(note.content);
    buffer.writeln();
  }

  if (note.checklistItems.isNotEmpty) {
    buffer.writeln('Checklist:');
    for (final item in note.checklistItems) {
      buffer.writeln('- [${item.isChecked ? 'x' : ' '}] ${item.text}');
    }
  }

  return buffer.toString().trim();
}
