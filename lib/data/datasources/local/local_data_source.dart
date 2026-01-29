import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/note_model.dart';
import '../../models/label_model.dart';

class LocalDataSource {
  static const String _notesBoxName = 'notes_box';
  static const String _labelsBoxName = 'labels_box';
  static const String _settingsBoxName = 'settings_box';

  static const int _currentSchemaVersion = 2; // Incremented for versioning

  late Box<NoteModel> _notesBox;
  late Box<LabelModel> _labelsBox;
  late Box _settingsBox;

  Future<void> init() async {
    try {
      _notesBox = await Hive.openBox<NoteModel>(_notesBoxName);
      _labelsBox = await Hive.openBox<LabelModel>(_labelsBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);

      await _handleMigration();
    } catch (e) {
      debugPrint('HIVE BOX OPEN FAIL: $e. Attempting repair...');
      await _emergencyRepair();
    }
  }

  Future<void> _handleMigration() async {
    final lastVersion = _settingsBox.get('schema_version', defaultValue: 1);

    if (lastVersion < _currentSchemaVersion) {
      debugPrint(
        'Migrating database from $lastVersion to $_currentSchemaVersion',
      );

      try {
        if (lastVersion == 1) {
          // Migration from v1: Ensure all notes are valid
          for (final note in _notesBox.values) {
            // Logic to ensure data integrity
            await _notesBox.put(note.id, note);
          }
        }

        await _settingsBox.put('schema_version', _currentSchemaVersion);
        debugPrint('Migration successful');
      } catch (e) {
        debugPrint('Migration Error: $e');
      }
    }
  }

  Future<void> _emergencyRepair() async {
    // Only wipe as a last resort if box is totally unreadable
    try {
      await Hive.deleteBoxFromDisk(_notesBoxName);
      _notesBox = await Hive.openBox<NoteModel>(_notesBoxName);
      _labelsBox = await Hive.openBox<LabelModel>(_labelsBoxName);
      _settingsBox = await Hive.openBox(_settingsBoxName);
    } catch (e) {
      debugPrint('Emergency repair failed: $e');
    }
  }

  // Notes Operations
  Future<List<NoteModel>> getAllNotes() async {
    return _notesBox.values.toList();
  }

  Future<NoteModel?> getNoteById(String id) async {
    return _notesBox.get(id);
  }

  Future<void> saveNote(NoteModel note) async {
    await _notesBox.put(note.id, note);
  }

  Future<void> deleteNote(String id) async {
    await _notesBox.delete(id);
  }

  Future<void> deleteAllNotes() async {
    await _notesBox.clear();
  }

  // Labels Operations
  Future<List<LabelModel>> getAllLabels() async {
    return _labelsBox.values.toList();
  }

  Future<LabelModel?> getLabelById(String id) async {
    return _labelsBox.get(id);
  }

  Future<LabelModel?> getLabelByName(String name) async {
    final target = name.trim().toLowerCase();
    for (final label in _labelsBox.values) {
      if (label.name.trim().toLowerCase() == target) {
        return label;
      }
    }
    return null;
  }

  Future<bool> isLabelNameUnique(String name, {String? excludeId}) async {
    final target = name.trim().toLowerCase();
    for (final label in _labelsBox.values) {
      if (excludeId != null && label.id == excludeId) continue;
      if (label.name.trim().toLowerCase() == target) {
        return false;
      }
    }
    return true;
  }

  Future<void> saveLabel(LabelModel label) async {
    await _labelsBox.put(label.id, label);
  }

  Future<void> deleteLabel(String id) async {
    await _labelsBox.delete(id);
  }

  Future<void> deleteAllLabels() async {
    await _labelsBox.clear();
  }

  // Settings Operations
  Future<T?> getSetting<T>(String key) async {
    return _settingsBox.get(key);
  }

  Future<void> saveSetting<T>(String key, T value) async {
    await _settingsBox.put(key, value);
  }

  Future<void> deleteSetting(String key) async {
    await _settingsBox.delete(key);
  }

  // Search Operations
  Future<List<NoteModel>> searchNotes(String query) async {
    final allNotes = _notesBox.values.toList();

    if (query.isEmpty) return allNotes;

    final lowerQuery = query.toLowerCase();
    return allNotes.where((note) {
      return note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Filter Operations
  Future<List<NoteModel>> getNotesByLabel(String labelId) async {
    final allNotes = _notesBox.values.toList();
    return allNotes.where((note) => note.labelIds.contains(labelId)).toList();
  }

  Future<List<NoteModel>> getPinnedNotes() async {
    final allNotes = _notesBox.values.toList();
    return allNotes
        .where((note) => note.isPinned && !note.isArchived && !note.isDeleted)
        .toList();
  }

  Future<List<NoteModel>> getArchivedNotes() async {
    final allNotes = _notesBox.values.toList();
    return allNotes
        .where((note) => note.isArchived && !note.isDeleted)
        .toList();
  }

  Future<List<NoteModel>> getDeletedNotes() async {
    final allNotes = _notesBox.values.toList();
    return allNotes.where((note) => note.isDeleted).toList();
  }

  Future<List<NoteModel>> getActiveNotes() async {
    final allNotes = _notesBox.values.toList();
    return allNotes
        .where((note) => !note.isArchived && !note.isDeleted)
        .toList();
  }

  // Cleanup Operations
  Future<void> emptyTrash() async {
    final allNotes = _notesBox.values.toList();
    for (final note in allNotes) {
      if (note.isDeleted) {
        await _notesBox.delete(note.id);
      }
    }
  }

  Future<void> cleanupOldTrashItems(int daysOld) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    final allNotes = _notesBox.values.toList();

    for (final note in allNotes) {
      if (note.isDeleted && note.modifiedAt.isBefore(cutoffDate)) {
        await _notesBox.delete(note.id);
      }
    }
  }

  // Close all boxes
  Future<void> close() async {
    await _notesBox.close();
    await _labelsBox.close();
    await _settingsBox.close();
  }
}
