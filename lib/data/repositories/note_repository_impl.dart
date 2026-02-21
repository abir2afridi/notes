import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../models/note_model.dart';

import '../datasources/remote/remote_data_source.dart';

class NoteRepositoryImpl implements NoteRepository {
  final LocalDataSource _localDataSource;
  final RemoteDataSource _remoteDataSource;

  NoteRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<List<Note>> getAllNotes() async {
    final noteModels = await _localDataSource.getAllNotes();
    return noteModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Note?> getNoteById(String id) async {
    final noteModel = await _localDataSource.getNoteById(id);
    return noteModel?.toEntity();
  }

  @override
  Future<void> saveNote(Note note) async {
    final noteModel = NoteModel.fromEntity(note);
    await _localDataSource.saveNote(noteModel);
    await _remoteDataSource.saveNote(noteModel);
  }

  @override
  Future<void> deleteNote(String id) async {
    await _localDataSource.deleteNote(id);
    await _remoteDataSource.deleteNote(id);
  }

  @override
  Future<void> deleteAllNotes() async {
    await _localDataSource.deleteAllNotes();
  }

  @override
  Future<List<Note>> searchNotes(String query) async {
    final noteModels = await _localDataSource.searchNotes(query);
    return noteModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Note>> getNotesByLabel(String labelId) async {
    final noteModels = await _localDataSource.getNotesByLabel(labelId);
    return noteModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Note>> getPinnedNotes() async {
    final noteModels = await _localDataSource.getPinnedNotes();
    return noteModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Note>> getArchivedNotes() async {
    final noteModels = await _localDataSource.getArchivedNotes();
    return noteModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Note>> getDeletedNotes() async {
    final noteModels = await _localDataSource.getDeletedNotes();
    return noteModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Note>> getActiveNotes() async {
    final noteModels = await _localDataSource.getActiveNotes();
    return noteModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> archiveNotes(List<String> noteIds) async {
    for (final noteId in noteIds) {
      final note = await getNoteById(noteId);
      if (note != null) {
        final archivedNote = note.copyWith(
          isArchived: true,
          modifiedAt: DateTime.now(),
        );
        await saveNote(archivedNote);
      }
    }
  }

  @override
  Future<void> unarchiveNotes(List<String> noteIds) async {
    for (final noteId in noteIds) {
      final note = await getNoteById(noteId);
      if (note != null) {
        final unarchivedNote = note.copyWith(
          isArchived: false,
          modifiedAt: DateTime.now(),
        );
        await saveNote(unarchivedNote);
      }
    }
  }

  @override
  Future<void> pinNotes(List<String> noteIds) async {
    for (final noteId in noteIds) {
      final note = await getNoteById(noteId);
      if (note != null) {
        final pinnedNote = note.copyWith(
          isPinned: true,
          modifiedAt: DateTime.now(),
        );
        await saveNote(pinnedNote);
      }
    }
  }

  @override
  Future<void> unpinNotes(List<String> noteIds) async {
    for (final noteId in noteIds) {
      final note = await getNoteById(noteId);
      if (note != null) {
        final unpinnedNote = note.copyWith(
          isPinned: false,
          modifiedAt: DateTime.now(),
        );
        await saveNote(unpinnedNote);
      }
    }
  }

  @override
  Future<void> moveToTrash(List<String> noteIds) async {
    for (final noteId in noteIds) {
      final note = await getNoteById(noteId);
      if (note != null) {
        final trashedNote = note.copyWith(
          isDeleted: true,
          deletedAt: DateTime.now(),
          modifiedAt: DateTime.now(),
        );
        await saveNote(trashedNote);
        await _remoteDataSource.moveToTrash([noteId]);
      }
    }
  }

  @override
  Future<void> restoreNotes(List<String> noteIds) async {
    for (final noteId in noteIds) {
      final note = await getNoteById(noteId);
      if (note != null) {
        final restoredNote = note.copyWith(
          isDeleted: false,
          deletedAt: null,
          modifiedAt: DateTime.now(),
        );
        await saveNote(restoredNote);
        await _remoteDataSource.restoreNotes([noteId]);
      }
    }
  }

  @override
  Future<void> permanentlyDeleteNotes(List<String> noteIds) async {
    for (final noteId in noteIds) {
      await deleteNote(noteId);
      await _remoteDataSource.permanentlyDeleteNotes([noteId]);
    }
  }

  @override
  Future<void> emptyTrash() async {
    await _localDataSource.emptyTrash();
    await _remoteDataSource.emptyTrash();
  }

  @override
  Future<void> cleanupOldTrashItems(int daysOld) async {
    await _localDataSource.cleanupOldTrashItems(daysOld);
  }

  @override
  Future<Note> duplicateNote(String noteId) async {
    final originalNote = await getNoteById(noteId);
    if (originalNote == null) {
      throw Exception('Note not found');
    }

    final duplicatedNote = originalNote.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${originalNote.title} (Copy)',
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      isPinned: false,
    );

    await saveNote(duplicatedNote);
    return duplicatedNote;
  }

  @override
  Future<void> updateNoteWallpaper(String noteId, String? wallpaperPath) async {
    final note = await getNoteById(noteId);
    if (note == null) return;

    final sanitizedPath = (wallpaperPath == null || wallpaperPath.isEmpty)
        ? null
        : wallpaperPath;

    final updated = note.copyWith(
      backgroundImagePath: sanitizedPath,
      modifiedAt: DateTime.now(),
    );

    await saveNote(updated);
  }

  @override
  Future<void> clearWallpaperForAllNotes() async {
    final notes = await getAllNotes();
    for (final note in notes) {
      if (note.backgroundImagePath != null) {
        final updated = note.copyWith(
          backgroundImagePath: null,
          modifiedAt: DateTime.now(),
        );
        await saveNote(updated);
      }
    }
  }

  @override
  Future<void> syncNoteToRemote(Note note) async {
    final noteModel = NoteModel.fromEntity(note);
    await _remoteDataSource.saveNote(noteModel);
  }

  @override
  Future<void> syncNotesToRemote(List<Note> notes) async {
    for (final note in notes) {
      final noteModel = NoteModel.fromEntity(note);
      await _remoteDataSource.saveNote(noteModel);
    }
  }
}
