import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicine.dart';

class StorageService {
  static const String _boxName = 'medicines';
  Box<Medicine>? _box;

  // Initialize Hive and open box
  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MedicineAdapter());
    _box = await Hive.openBox<Medicine>(_boxName);
  }

  // Get all medicines
  List<Medicine> getAllMedicines() {
    return _box?.values.toList() ?? [];
  }

  // Add a new medicine
  Future<void> addMedicine(Medicine medicine) async {
    await _box?.put(medicine.id, medicine);
  }

  // Update an existing medicine
  Future<void> updateMedicine(Medicine medicine) async {
    await _box?.put(medicine.id, medicine);
  }

  // Delete a medicine
  Future<void> deleteMedicine(String id) async {
    await _box?.delete(id);
  }

  // Get a specific medicine by ID
  Medicine? getMedicine(String id) {
    return _box?.get(id);
  }

  // Clear all medicines (for testing/reset)
  Future<void> clearAll() async {
    await _box?.clear();
  }

  // Close the box
  Future<void> close() async {
    await _box?.close();
  }
}
