import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class MedicineProvider extends ChangeNotifier {
  final StorageService _storageService;
  final NotificationService _notificationService;

  List<Medicine> _medicines = [];

  MedicineProvider({
    required StorageService storageService,
    required NotificationService notificationService,
  })  : _storageService = storageService,
        _notificationService = notificationService {
    print('🎯 [MedicineProvider] Initializing provider...');
    loadMedicines();
  }

  // Get all medicines sorted by time
  List<Medicine> get medicinesSortedByTime {
    final list = [..._medicines];
    list.sort((a, b) => a.time.compareTo(b.time));
    return list;
  }

  // Get count of medicines
  int get medicineCount => _medicines.length;

  // Load medicines from storage
  Future<void> loadMedicines() async {
    print('📥 [MedicineProvider] Loading medicines from storage...');
    try {
      _medicines = _storageService.getAllMedicines();
      print('✅ [MedicineProvider] Loaded ${_medicines.length} medicines');
      notifyListeners();
    } catch (e) {
      print('❌ [MedicineProvider] Error loading medicines: $e');
      rethrow;
    }
  }

  // Add a new medicine
  Future<void> addMedicine({
    required String name,
    required String dose,
    required DateTime time,
  }) async {
    print('➕ [MedicineProvider] Adding new medicine: $name');
    print('   Dose: $dose');
    print('   Time: $time');
    
    try {
      final medicine = Medicine(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        dose: dose,
        time: time,
      );
      print('   Generated ID: ${medicine.id}');

      await _storageService.addMedicine(medicine);
      await _notificationService.scheduleMedicineNotification(medicine);

      _medicines.add(medicine);
      notifyListeners();
      print('✅ [MedicineProvider] Medicine added and notification scheduled');
    } catch (e, stackTrace) {
      print('❌ [MedicineProvider] Error adding medicine: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Update an existing medicine
  Future<void> updateMedicine(Medicine medicine) async {
    print('✏️ [MedicineProvider] Updating medicine: ${medicine.name} (ID: ${medicine.id})');
    try {
      await _storageService.updateMedicine(medicine);
      
      // Cancel old notification and schedule new one
      await _notificationService.cancelMedicineNotification(medicine.id);
      await _notificationService.scheduleMedicineNotification(medicine);

      final index = _medicines.indexWhere((m) => m.id == medicine.id);
      if (index != -1) {
        _medicines[index] = medicine;
        notifyListeners();
        print('✅ [MedicineProvider] Medicine updated successfully');
      } else {
        print('⚠️ [MedicineProvider] Medicine not found in list');
      }
    } catch (e) {
      print('❌ [MedicineProvider] Error updating medicine: $e');
      rethrow;
    }
  }

  // Delete a medicine
  Future<void> deleteMedicine(String id) async {
    print('🗑️ [MedicineProvider] Deleting medicine ID: $id');
    try {
      await _storageService.deleteMedicine(id);
      await _notificationService.cancelMedicineNotification(id);

      _medicines.removeWhere((m) => m.id == id);
      notifyListeners();
      print('✅ [MedicineProvider] Medicine deleted successfully');
    } catch (e) {
      print('❌ [MedicineProvider] Error deleting medicine: $e');
      rethrow;
    }
  }

  // Get a specific medicine
  Medicine? getMedicine(String id) {
    try {
      return _medicines.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear all medicines (for testing)
  Future<void> clearAllMedicines() async {
    await _storageService.clearAll();
    await _notificationService.cancelAllNotifications();
    _medicines.clear();
    notifyListeners();
  }
}
