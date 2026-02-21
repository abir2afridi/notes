import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'note_provider.dart';
import 'label_provider.dart';
import 'settings_repository_provider.dart';
import 'auth_provider.dart';
import '../../data/models/note_model.dart';
import '../../data/models/label_model.dart';
import 'remote_provider.dart';

final syncProvider = StateNotifierProvider<SyncNotifier, AsyncValue<void>>((
  ref,
) {
  return SyncNotifier(ref);
});

class SyncNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  SyncNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> backupToCloud() async {
    state = const AsyncValue.loading();
    try {
      final remoteDataSource = _ref.read(remoteDataSourceProvider);

      // Check if user is authenticated
      final authRepo = _ref.read(authRepositoryProvider);
      final currentUser = authRepo.currentUser;
      if (currentUser == null) {
        // Don't throw error, just return silently
        debugPrint('User not authenticated. Skipping cloud backup.');
        state = AsyncValue.error(
          'Please sign in to enable cloud sync',
          StackTrace.current,
        );
        return;
      }

      debugPrint('Starting cloud backup...');

      // 1. Sync Labels
      final labels = await _ref.read(labelRepositoryProvider).getAllLabels();
      debugPrint('Found ${labels.length} labels to sync');
      for (final label in labels) {
        await remoteDataSource.saveLabel(LabelModel.fromEntity(label));
        debugPrint('Synced label: ${label.name}');
      }

      // 2. Sync Notes
      final notes = await _ref.read(noteRepositoryProvider).getAllNotes();
      debugPrint('Found ${notes.length} notes to sync');
      for (final note in notes) {
        await remoteDataSource.saveNote(NoteModel.fromEntity(note));
        debugPrint('Synced note: ${note.title}');
      }

      // 3. Sync Settings
      final settingsRepo = _ref.read(settingsRepositoryProvider);
      final settings = await settingsRepo.getSettings();
      await remoteDataSource.saveSettings(settings);
      debugPrint('Synced settings successfully');

      state = const AsyncValue.data(null);
      debugPrint('Cloud backup completed successfully');
    } catch (e, stack) {
      debugPrint('Cloud backup failed: $e');
      debugPrint('Stack trace: $stack');
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> restoreFromCloud(BuildContext context) async {
    state = const AsyncValue.loading();
    try {
      final remoteDataSource = _ref.read(remoteDataSourceProvider);

      // 1. Sync Labels
      final remoteLabels = await remoteDataSource.getAllLabels();
      final labelRepo = _ref.read(labelRepositoryProvider);
      for (final model in remoteLabels) {
        await labelRepo.saveLabel(model.toEntity());
      }
      await _ref.read(labelsProvider.notifier).loadLabels();

      // 2. Sync Notes
      final remoteNotes = await remoteDataSource.getAllNotes();
      final noteRepo = _ref.read(noteRepositoryProvider);
      for (final model in remoteNotes) {
        await noteRepo.saveNote(model.toEntity());
      }
      await _ref.read(notesListProvider.notifier).loadNotes();

      // 3. Sync Settings
      final settingsRepo = _ref.read(settingsRepositoryProvider);
      await settingsRepo.syncWithRemote();

      // We might need to refresh individual settings providers here
      // This part is tricky because those providers are currently standalone

      // Navigate to home page after successful restore
      if (context.mounted) {
        context.go('/home');
      }

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
