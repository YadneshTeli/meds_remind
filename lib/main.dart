import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/medicine_provider.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'utils/app_colors.dart';

void main() async {
  print('🚀 [Main] Starting Medicine Reminder App...');
  WidgetsFlutterBinding.ensureInitialized();
  print('✅ [Main] Flutter binding initialized');
  
  try {
    // Initialize services
    print('📦 [Main] Initializing services...');
    final storageService = StorageService();
    await storageService.init();
    
    final notificationService = NotificationService();
    await notificationService.init();
    
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
    rethrow;
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
