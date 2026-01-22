import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';
import '../widgets/medicine_tile.dart';
import '../utils/app_colors.dart';
import '../services/notification_service.dart';
import 'add_medicine_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showDeleteDialog(BuildContext context, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: Text('Are you sure you want to delete $name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Provider.of<MedicineProvider>(context, listen: false)
                  .deleteMedicine(id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Medicine deleted successfully'),
                  backgroundColor: AppColors.teal,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Medicine Reminder',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        backgroundColor: AppColors.teal,
        elevation: 0,
        actions: [
          // Immediate test notification
          IconButton(
            icon: const Icon(Icons.notifications, color: AppColors.white),
            tooltip: 'Test Now',
            onPressed: () async {
              await NotificationService().showTestNotification();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Test notification sent NOW!'),
                    duration: Duration(seconds: 2),
                    backgroundColor: AppColors.teal,
                  ),
                );
              }
            },
          ),
          // Scheduled test notification (30 seconds)
          IconButton(
            icon: const Icon(Icons.alarm, color: AppColors.white),
            tooltip: 'Test 30s',
            onPressed: () async {
              await NotificationService().showTestScheduledNotification();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('⏰ Notification scheduled for 30 seconds from now!'),
                    duration: Duration(seconds: 3),
                    backgroundColor: AppColors.orange,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, provider, child) {
          final medicines = provider.medicinesSortedByTime;

          if (medicines.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 100,
                    color: AppColors.grey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No medicines added yet',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.grey.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first medicine',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final medicine = medicines[index];
              return MedicineTile(
                name: medicine.name,
                dose: medicine.dose,
                time: medicine.time,
                frequency: medicine.getFrequencyDisplay(),
                onDelete: () => _showDeleteDialog(
                  context,
                  medicine.id,
                  medicine.name,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddMedicineScreen(),
            ),
          );
        },
        backgroundColor: AppColors.orange,
        child: const Icon(
          Icons.add,
          color: AppColors.white,
        ),
      ),
    );
  }
}
