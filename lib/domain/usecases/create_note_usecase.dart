import '../entities/note.dart';
import '../repositories/note_repository.dart';

class CreateNoteUseCase {
  final NoteRepository _repository;

  CreateNoteUseCase(this._repository);

  Future<Note> call({
    required String title,
    required String content,
    required String type,
    String backgroundColor = '#FFFFFF',
    List<String> labelIds = const [],
    List<ChecklistItem> checklistItems = const [],
  }) async {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      type: type,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      backgroundColor: backgroundColor,
      labelIds: labelIds,
      checklistItems: checklistItems,
    );

    await _repository.saveNote(note);
    return note;
  }
}
