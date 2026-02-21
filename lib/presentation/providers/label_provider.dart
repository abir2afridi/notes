import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/repositories/label_repository_impl.dart';
import '../../domain/entities/label.dart';
import '../../domain/repositories/label_repository.dart';
import 'note_provider.dart';

import 'remote_provider.dart';

final labelRepositoryProvider = Provider<LabelRepository>((ref) {
  final dataSource = ref.watch(localDataSourceProvider);
  final remoteDataSource = ref.watch(remoteDataSourceProvider);
  return LabelRepositoryImpl(dataSource, remoteDataSource);
});

final labelsProvider = StateNotifierProvider<LabelsNotifier, List<Label>>((
  ref,
) {
  final repository = ref.watch(labelRepositoryProvider);
  return LabelsNotifier(ref, repository)..loadLabels();
});

class LabelsNotifier extends StateNotifier<List<Label>> {
  LabelsNotifier(this._ref, this._repository) : super(const []);

  final Ref _ref;
  final LabelRepository _repository;

  Future<void> loadLabels() async {
    try {
      final labels = await _repository.getAllLabels();
      labels.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      state = labels;
    } catch (_) {
      state = const [];
    }
  }

  Future<bool> addLabel(String name, {String? color}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;

    final isUnique = await _repository.isLabelNameUnique(trimmed);
    if (!isUnique) {
      return false;
    }

    final selectedColor = color ?? _defaultColorForName(trimmed);
    final now = DateTime.now();
    final label = Label(
      id: now.microsecondsSinceEpoch.toString(),
      name: trimmed,
      color: selectedColor,
      createdAt: now,
      modifiedAt: now,
    );

    await _repository.saveLabel(label);
    await loadLabels();
    return true;
  }

  Future<bool> renameLabel(String labelId, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return false;

    final isUnique = await _repository.isLabelNameUnique(
      trimmed,
      excludeId: labelId,
    );
    if (!isUnique) {
      return false;
    }

    final label = state.firstWhere((label) => label.id == labelId);
    final updated = label.copyWith(name: trimmed, modifiedAt: DateTime.now());
    await _repository.saveLabel(updated);
    await loadLabels();
    return true;
  }

  Future<void> deleteLabel(String labelId) async {
    await _repository.deleteLabel(labelId);
    await loadLabels();
    await _ref
        .read(notesListProvider.notifier)
        .removeLabelFromAllNotes(labelId);
  }

  Label? getLabelById(String id) {
    try {
      return state.firstWhere((label) => label.id == id);
    } catch (_) {
      return null;
    }
  }

  String _defaultColorForName(String name) {
    if (name.isEmpty) return AppConstants.noteColors.first;
    final index =
        name.codeUnits.fold<int>(0, (prev, code) => prev + code) %
        AppConstants.noteColors.length;
    return AppConstants.noteColors[index];
  }
}
