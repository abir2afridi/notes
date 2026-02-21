import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/note_model.dart';
import '../../models/label_model.dart';
import '../../models/settings_model.dart';

import '../../../core/constants/app_constants.dart';

class RemoteDataSource {
  FirebaseFirestore? get _firestore =>
      AppConstants.firebaseSyncEnabled ? FirebaseFirestore.instance : null;
  FirebaseAuth? get _auth =>
      AppConstants.firebaseSyncEnabled ? FirebaseAuth.instance : null;

  String? get _userId => _auth?.currentUser?.uid;

  // Collections
  DocumentReference? get _userDoc {
    final uid = _userId;
    if (uid == null) return null;
    return _firestore?.collection('users').doc(uid);
  }

  CollectionReference? get _notesCollection => _userDoc?.collection('notes');
  CollectionReference? get _labelsCollection => _userDoc?.collection('labels');
  DocumentReference? get _settingsDoc =>
      _userDoc?.collection('config').doc('settings');

  // --- Notes ---
  Future<void> saveNote(NoteModel note) async {
    if (_userId == null) return;
    await _notesCollection?.doc(note.id).set(note.toJson());
  }

  Future<void> deleteNote(String id) async {
    if (_userId == null) return;
    await _notesCollection?.doc(id).delete();
  }

  Future<List<NoteModel>> getAllNotes() async {
    if (_userId == null) return [];
    final snapshot = await _notesCollection?.get();
    return snapshot?.docs
            .map(
              (doc) => NoteModel.fromJson(doc.data() as Map<String, dynamic>),
            )
            .toList() ??
        [];
  }

  Stream<List<NoteModel>> get notesStream {
    if (_userId == null) return const Stream.empty();
    return _notesCollection?.snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => NoteModel.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        ) ??
        const Stream.empty();
  }

  // --- Labels ---
  Future<void> saveLabel(LabelModel label) async {
    if (_userId == null) return;
    await _labelsCollection?.doc(label.id).set(label.toJson());
  }

  Future<void> deleteLabel(String id) async {
    if (_userId == null) return;
    await _labelsCollection?.doc(id).delete();
  }

  Future<List<LabelModel>> getAllLabels() async {
    if (_userId == null) return [];
    final snapshot = await _labelsCollection?.get();
    return snapshot?.docs
            .map(
              (doc) => LabelModel.fromJson(doc.data() as Map<String, dynamic>),
            )
            .toList() ??
        [];
  }

  // --- Settings ---
  Future<void> saveSettings(SettingsModel settings) async {
    if (_userId == null) return;
    await _settingsDoc?.set(settings.toJson());
  }

  Future<SettingsModel?> getSettings() async {
    if (_userId == null) return null;
    final doc = await _settingsDoc?.get();
    if (doc == null || !doc.exists) return null;
    return SettingsModel.fromJson(doc.data() as Map<String, dynamic>);
  }

  // --- User Profile ---
  Future<void> saveUserProfile(Map<String, dynamic> userData) async {
    if (_userId == null) return;
    await _userDoc?.set(userData, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    if (_userId == null) return null;
    final doc = await _userDoc?.get();
    if (doc == null || !doc.exists) return null;
    return doc.data() as Map<String, dynamic>;
  }

  // --- Trash Operations ---
  Future<void> moveToTrash(List<String> noteIds) async {
    if (_userId == null) return;
    for (final noteId in noteIds) {
      await _notesCollection?.doc(noteId).update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> restoreNotes(List<String> noteIds) async {
    if (_userId == null) return;
    for (final noteId in noteIds) {
      await _notesCollection?.doc(noteId).update({
        'isDeleted': false,
        'deletedAt': FieldValue.delete(),
      });
    }
  }

  Future<void> permanentlyDeleteNotes(List<String> noteIds) async {
    if (_userId == null) return;
    for (final noteId in noteIds) {
      await _notesCollection?.doc(noteId).delete();
    }
  }

  Future<void> emptyTrash() async {
    if (_userId == null) return;
    final snapshot = await _notesCollection?.get();
    for (final doc in snapshot?.docs ?? []) {
      if (doc.data()['isDeleted'] == true) {
        await doc.reference.delete();
      }
    }
  }
}
