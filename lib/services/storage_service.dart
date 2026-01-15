import 'package:hive_flutter/hive_flutter.dart';
import '../models/medicine.dart';

class StorageService {
  static const String _boxName = 'medicines';
  Box<Medicine>? _box;

  // Initialize Hive and open box
  Future<void> init() async {
    print('💾 [StorageService] Initializing storage...');
    try {
      await Hive.initFlutter();
      print('📦 [StorageService] Hive initialized');
      
      Hive.registerAdapter(MedicineAdapter());
      print('🔧 [StorageService] Medicine adapter registered');
      
      _box = await Hive.openBox<Medicine>(_boxName);
      print('✅ [StorageService] Storage box opened: $_boxName');
      print('📊 [StorageService] Current medicine count: ${_box?.length ?? 0}');
    } catch (e, stackTrace) {
      print('❌ [StorageService] Error initializing storage: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Get all medicines
  List<Medicine> getAllMedicines() {
    final medicines = _box?.values.toList() ?? [];
    print('📖 [StorageService] Retrieved ${medicines.length} medicines');
    return medicines;
  }

  // Add a new medicine
  Future<void> addMedicine(Medicine medicine) async {
    print('➕ [StorageService] Adding medicine: ${medicine.name} (ID: ${medicine.id})');
    try {
      await _box?.put(medicine.id, medicine);
      print('✅ [StorageService] Medicine added successfully');
    } catch (e) {
      print('❌ [StorageService] Error adding medicine: $e');
      rethrow;
    }
  }

  // Update an existing medicine
  Future<void> updateMedicine(Medicine medicine) async {
    print('✏️ [StorageService] Updating medicine: ${medicine.name} (ID: ${medicine.id})');
    try {
      await _box?.put(medicine.id, medicine);
      print('✅ [StorageService] Medicine updated successfully');
    } catch (e) {
      print('❌ [StorageService] Error updating medicine: $e');
      rethrow;
    }
  }

  // Delete a medicine
  Future<void> deleteMedicine(String id) async {
    print('🗑️ [StorageService] Deleting medicine ID: $id');
    try {
      await _box?.delete(id);
      print('✅ [StorageService] Medicine deleted successfully');
    } catch (e) {
      print('❌ [StorageService] Error deleting medicine: $e');
      rethrow;
    }
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
