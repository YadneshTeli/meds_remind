import 'package:hive/hive.dart';

part 'medicine.g.dart';

// Frequency type enum
@HiveType(typeId: 1)
enum FrequencyType {
  @HiveField(0)
  daily,
  
  @HiveField(1)
  specificDays,
  
  @HiveField(2)
  interval, // Every X days
}

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

  @HiveField(4)
  final FrequencyType frequency;

  @HiveField(5)
  final List<int> selectedDays; // 1=Monday, 2=Tuesday, ..., 7=Sunday

  @HiveField(6)
  final int? intervalDays; // For interval frequency

  Medicine({
    required this.id,
    required this.name,
    required this.dose,
    required this.time,
    this.frequency = FrequencyType.daily,
    this.selectedDays = const [],
    this.intervalDays,
  });

  // Copy with method for updates
  Medicine copyWith({
    String? id,
    String? name,
    String? dose,
    DateTime? time,
    FrequencyType? frequency,
    List<int>? selectedDays,
    int? intervalDays,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dose: dose ?? this.dose,
      time: time ?? this.time,
      frequency: frequency ?? this.frequency,
      selectedDays: selectedDays ?? this.selectedDays,
      intervalDays: intervalDays ?? this.intervalDays,
    );
  }

  // Get frequency display string
  String getFrequencyDisplay() {
    switch (frequency) {
      case FrequencyType.daily:
        return 'Every day';
      case FrequencyType.specificDays:
        if (selectedDays.isEmpty) return 'No days selected';
        final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final days = selectedDays.map((d) => dayNames[d - 1]).join(', ');
        return days;
      case FrequencyType.interval:
        return intervalDays == 1 ? 'Every day' : 'Every $intervalDays days';
    }
  }

  // Convert to map for debugging/logging
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dose': dose,
      'time': time.toIso8601String(),
      'frequency': frequency.toString(),
      'selectedDays': selectedDays,
      'intervalDays': intervalDays,
    };
  }
}
