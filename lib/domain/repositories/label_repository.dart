import '../entities/label.dart';

abstract class LabelRepository {
  // CRUD Operations
  Future<List<Label>> getAllLabels();
  Future<Label?> getLabelById(String id);
  Future<void> saveLabel(Label label);
  Future<void> deleteLabel(String id);
  Future<void> deleteAllLabels();

  // Utility Operations
  Future<Label?> getLabelByName(String name);
  Future<bool> isLabelNameUnique(String name, {String? excludeId});
}
