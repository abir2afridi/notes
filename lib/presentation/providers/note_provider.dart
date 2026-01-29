import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../data/repositories/note_repository_impl.dart';
import '../../data/datasources/local/local_data_source.dart';

/// Provides an initialized [LocalDataSource].
///
/// This provider must be overridden with a pre-initialized instance
/// (see `main.dart`).
final localDataSourceProvider = Provider<LocalDataSource>((ref) {
  throw UnimplementedError('LocalDataSource provider must be overridden');
});

// Note provider
final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  final dataSource = ref.watch(localDataSourceProvider);
  return NoteRepositoryImpl(dataSource);
});

// Notes list provider
final notesListProvider = StateNotifierProvider<NotesListNotifier, List<Note>>((
  ref,
) {
  return NotesListNotifier(ref.read(noteRepositoryProvider))..loadNotes();
});

final activeNotesProvider = Provider<List<Note>>((ref) {
  final notes = ref.watch(notesListProvider);
  return notes.where((note) => !note.isArchived && !note.isDeleted).toList();
});

final archivedNotesProvider = Provider<List<Note>>((ref) {
  final notes = ref.watch(notesListProvider);
  return notes.where((note) => note.isArchived && !note.isDeleted).toList();
});

final trashedNotesProvider = Provider<List<Note>>((ref) {
  final notes = ref.watch(notesListProvider);
  return notes.where((note) => note.isDeleted).toList();
});

class NotesListNotifier extends StateNotifier<List<Note>> {
  final NoteRepository _repository;

  NotesListNotifier(this._repository) : super([]);

  Future<void> loadNotes() async {
    try {
      final notes = await _repository.getAllNotes();
      state = notes;
    } catch (e) {
      // Handle error
    }
  }

  Future<void> addNote(Note note) async {
    try {
      await _repository.saveNote(note);
      await loadNotes(); // Reload notes
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      await _repository.saveNote(note);
      await loadNotes(); // Reload notes
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _repository.deleteNote(id);
      await loadNotes(); // Reload notes
    } catch (e) {
      // Handle error
    }
  }

  Future<void> archiveNote(String id) async {
    try {
      await _repository.archiveNotes([id]);
      await loadNotes();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> unarchiveNote(String id) async {
    try {
      await _repository.unarchiveNotes([id]);
      await loadNotes();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> moveToTrash(String id) async {
    try {
      await _repository.moveToTrash([id]);
      await loadNotes();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> restoreFromTrash(String id) async {
    try {
      await _repository.restoreNotes([id]);
      await loadNotes();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> permanentlyDelete(String id) async {
    await deleteNote(id);
  }

  Future<void> emptyTrash() async {
    try {
      await _repository.emptyTrash();
      await loadNotes();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> duplicateNote(String id) async {
    try {
      await _repository.duplicateNote(id);
      await loadNotes();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> setNoteWallpaper(String id, String? path) async {
    try {
      await _repository.updateNoteWallpaper(id, path);
      await loadNotes();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> removeLabelFromAllNotes(String labelId) async {
    bool updatedAny = false;
    for (final note in state) {
      if (note.labelIds.contains(labelId)) {
        final updatedLabels = List<String>.from(note.labelIds)..remove(labelId);
        final updated = note.copyWith(
          labelIds: updatedLabels,
          modifiedAt: DateTime.now(),
        );
        await _repository.saveNote(updated);
        updatedAny = true;
      }
    }
    if (updatedAny) {
      await loadNotes();
    }
  }

  Future<void> updateNoteLabels(String noteId, List<String> labelIds) async {
    try {
      final note = state.firstWhere((note) => note.id == noteId);
      final updated = note.copyWith(
        labelIds: labelIds,
        modifiedAt: DateTime.now(),
      );
      await updateNote(updated);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> togglePin(String noteId) async {
    try {
      final note = state.firstWhere((note) => note.id == noteId);
      final updated = note.copyWith(
        isPinned: !note.isPinned,
        modifiedAt: DateTime.now(),
      );
      await updateNote(updated);
    } catch (e) {
      // Handle error
    }
  }
}
