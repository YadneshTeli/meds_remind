import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/medicine_provider.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'utils/app_colors.dart';

void main() async {
  print('🚀 [Main] Starting Medicine Reminder App...');
  
  runApp(const MaterialApp(
    home: Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    ),
  ));
  
  WidgetsFlutterBinding.ensureInitialized();
  print('✅ [Main] Flutter binding initialized');
  
  try {
    // Initialize services
    print('📦 [Main] Initializing services...');
    final storageService = StorageService();
    await storageService.init();
    print('✅ [Main] Storage service initialized');
    
    final notificationService = NotificationService();
    await notificationService.init();
    print('✅ [Main] Notification service initialized');
    
    print('✅ [Main] All services initialized successfully');
    print('🎬 [Main] Launching app...');

    runApp(
      MyApp(
        storageService: storageService,
        notificationService: notificationService,
      ),
    );
  } catch (e, stackTrace) {
    print('❌ [Main] CRITICAL ERROR during app initialization: $e');
    print('Stack trace: $stackTrace');
    
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'App Failed to Start',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please clear app data and try again:\nSettings → Apps → Meds Remind → Storage → Clear Data',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final StorageService storageService;
  final NotificationService notificationService;

  const MyApp({
    super.key,
    required this.storageService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MedicineProvider(
        storageService: storageService,
        notificationService: notificationService,
      ),
      child: MaterialApp(
        title: 'Medicine Reminder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.teal,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.teal,
            primary: AppColors.teal,
            secondary: AppColors.orange,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
