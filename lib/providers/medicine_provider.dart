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
    _medicines = _storageService.getAllMedicines();
    notifyListeners();
  }

  // Add a new medicine
  Future<void> addMedicine({
    required String name,
    required String dose,
    required DateTime time,
  }) async {
    final medicine = Medicine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      dose: dose,
      time: time,
    );

    await _storageService.addMedicine(medicine);
    await _notificationService.scheduleMedicineNotification(medicine);

    _medicines.add(medicine);
    notifyListeners();
  }

  // Update an existing medicine
  Future<void> updateMedicine(Medicine medicine) async {
    await _storageService.updateMedicine(medicine);
    
    // Cancel old notification and schedule new one
    await _notificationService.cancelMedicineNotification(medicine.id);
    await _notificationService.scheduleMedicineNotification(medicine);

    final index = _medicines.indexWhere((m) => m.id == medicine.id);
    if (index != -1) {
      _medicines[index] = medicine;
      notifyListeners();
    }
  }

  // Delete a medicine
  Future<void> deleteMedicine(String id) async {
    await _storageService.deleteMedicine(id);
    await _notificationService.cancelMedicineNotification(id);

    _medicines.removeWhere((m) => m.id == id);
    notifyListeners();
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
