import '../entities/note.dart';

abstract class NoteRepository {
  // CRUD Operations
  Future<List<Note>> getAllNotes();
  Future<Note?> getNoteById(String id);
  Future<void> saveNote(Note note);
  Future<void> deleteNote(String id);
  Future<void> deleteAllNotes();

  // Search and Filter
  Future<List<Note>> searchNotes(String query);
  Future<List<Note>> getNotesByLabel(String labelId);
  Future<List<Note>> getPinnedNotes();
  Future<List<Note>> getArchivedNotes();
  Future<List<Note>> getDeletedNotes();
  Future<List<Note>> getActiveNotes();

  // Batch Operations
  Future<void> archiveNotes(List<String> noteIds);
  Future<void> unarchiveNotes(List<String> noteIds);
  Future<void> pinNotes(List<String> noteIds);
  Future<void> unpinNotes(List<String> noteIds);
  Future<void> moveToTrash(List<String> noteIds);
  Future<void> restoreNotes(List<String> noteIds);
  Future<void> permanentlyDeleteNotes(List<String> noteIds);

  // Utility Operations
  Future<void> emptyTrash();
  Future<void> cleanupOldTrashItems(int daysOld);
  Future<Note> duplicateNote(String noteId);

  Future<void> updateNoteWallpaper(String noteId, String? wallpaperPath);
  Future<void> clearWallpaperForAllNotes();

  // Remote Sync Operations
  Future<void> syncNoteToRemote(Note note);
  Future<void> syncNotesToRemote(List<Note> notes);
}
