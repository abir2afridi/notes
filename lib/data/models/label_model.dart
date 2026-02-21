import 'package:hive/hive.dart';
import '../../domain/entities/label.dart';

part 'label_model.g.dart';

@HiveType(typeId: 2)
class LabelModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String color;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime modifiedAt;

  const LabelModel({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    required this.modifiedAt,
  });

  // Convert from Domain Entity
  factory LabelModel.fromEntity(Label label) {
    return LabelModel(
      id: label.id,
      name: label.name,
      color: label.color,
      createdAt: label.createdAt,
      modifiedAt: label.modifiedAt,
    );
  }

  // Convert to Domain Entity
  Label toEntity() {
    return Label(
      id: id,
      name: name,
      color: color,
      createdAt: createdAt,
      modifiedAt: modifiedAt,
    );
  }

  LabelModel copyWith({
    String? id,
    String? name,
    String? color,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return LabelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
    };
  }

  factory LabelModel.fromJson(Map<String, dynamic> json) {
    return LabelModel(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: DateTime.parse(json['modifiedAt']),
    );
  }
}
