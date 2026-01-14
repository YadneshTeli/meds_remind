import 'package:hive/hive.dart';

part 'medicine.g.dart';

@HiveType(typeId: 0)
class Medicine extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String dose;

  @HiveField(3)
  final DateTime time;

  Medicine({
    required this.id,
    required this.name,
    required this.dose,
    required this.time,
  });

  // Copy with method for updates
  Medicine copyWith({
    String? id,
    String? name,
    String? dose,
    DateTime? time,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      time: time ?? this.time,
    );
  }

  // Convert to map for debugging/logging
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dose': dose,
      'time': time.toIso8601String(),
    };
  }
}
