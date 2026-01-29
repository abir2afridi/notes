import '../../domain/entities/label.dart';
import '../../domain/repositories/label_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../models/label_model.dart';

class LabelRepositoryImpl implements LabelRepository {
  final LocalDataSource _localDataSource;

  LabelRepositoryImpl(this._localDataSource);

  @override
  Future<List<Label>> getAllLabels() async {
    final labels = await _localDataSource.getAllLabels();
    return labels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Label?> getLabelById(String id) async {
    final label = await _localDataSource.getLabelById(id);
    return label?.toEntity();
  }

  @override
  Future<Label?> getLabelByName(String name) async {
    final label = await _localDataSource.getLabelByName(name);
    return label?.toEntity();
  }

  @override
  Future<bool> isLabelNameUnique(String name, {String? excludeId}) {
    return _localDataSource.isLabelNameUnique(name, excludeId: excludeId);
  }

  @override
  Future<void> saveLabel(Label label) async {
    final model = LabelModel.fromEntity(label);
    await _localDataSource.saveLabel(model);
  }

  @override
  Future<void> deleteLabel(String id) {
    return _localDataSource.deleteLabel(id);
  }

  @override
  Future<void> deleteAllLabels() {
    return _localDataSource.deleteAllLabels();
  }
}
