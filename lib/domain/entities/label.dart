import 'package:equatable/equatable.dart';

class Label extends Equatable {
  final String id;
  final String name;
  final String color;
  final DateTime createdAt;
  final DateTime modifiedAt;
  
  const Label({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    required this.modifiedAt,
  });

  Label copyWith({
    String? id,
    String? name,
    String? color,
    DateTime? createdAt,
    DateTime? modifiedAt,
  }) {
    return Label(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  @override
  List<Object?> get props => [id, name, color, createdAt, modifiedAt];
}
