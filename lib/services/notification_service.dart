import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/medicine.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  Future<void> init() async {
    print('🔔 [NotificationService] Initializing notification service...');
    
    try {
      // Initialize timezone
      tz.initializeTimeZones();
      final location = tz.getLocation('Asia/Kolkata');
      tz.setLocalLocation(location);
      print('🌍 [NotificationService] Timezone initialized to: ${tz.local.name}');

      // Create notification channel for Android 8.0+
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'medicine_reminders_v2', // id - Changed to force recreation with max importance
        'Medicine Reminders', // name
        description: 'Critical notifications for medicine reminders',
        importance: Importance.max, // Changed from high to max for heads-up display
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      print('📱 [NotificationService] Creating notification channel...');
      // Create the channel
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      print('✅ [NotificationService] Notification channel created successfully');

    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    print('🔧 [NotificationService] Notification plugin initialized');

    // Request permissions for Android 13+
    await _requestPermissions();
    print('✅ [NotificationService] Notification service initialization complete');
    } catch (e, stackTrace) {
      print('❌ [NotificationService] Error during initialization: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    print('🔐 [NotificationService] Requesting permissions...');
    
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Request notification permissions for Android 13+
    final bool? granted = await androidImplementation?.requestNotificationsPermission();
    print('📬 [NotificationService] Notification permission: ${granted == true ? "GRANTED" : "DENIED"} (result: $granted)');
    
    // Request exact alarm permissions for Android 12+
    final bool? exactAlarmGranted = await androidImplementation?.requestExactAlarmsPermission();
    print('⏰ [NotificationService] Exact alarm permission: ${exactAlarmGranted == true ? "GRANTED" : "DENIED"} (result: $exactAlarmGranted)');
    
    if (granted != true) {
      print('⚠️ [NotificationService] WARNING: Notification permission not granted - notifications will not work!');
    }
    
    if (exactAlarmGranted != true) {
      print('⚠️ [NotificationService] WARNING: Exact alarm permission not granted - scheduled alarms may not work!');
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    print('👆 [NotificationService] Notification tapped:');
    print('   ID: ${notificationResponse.id}');
    print('   Payload: ${notificationResponse.payload}');
    print('   Action: ${notificationResponse.actionId}');
    // Handle notification tap - can navigate to specific screen
  }

  // Schedule a notification for a medicine
  Future<void> scheduleMedicineNotification(Medicine medicine) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medicine_reminders_v2',
      'Medicine Reminders',
      channelDescription: 'Notifications for medicine reminders',
      importance: Importance.max, // Changed to max to match channel importance
      priority: Priority.max, // Changed to max for highest priority
      showWhen: true,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      autoCancel: false, // Don't auto-dismiss - user must acknowledge
      ongoing: false, // Allow swiping away after acknowledgment
      ticker: 'Medicine Reminder', // Text shown in status bar
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Convert DateTime to TZDateTime
    final scheduledDate = _convertToTZDateTime(medicine.time);
    print('📅 [NotificationService] Scheduling notification:');
    print('   Medicine: ${medicine.name}');
    print('   Dose: ${medicine.dose}');
    print('   Time: ${medicine.time}');
    print('   Scheduled for: $scheduledDate');
    print('   Notification ID: ${medicine.id.hashCode}');

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        medicine.id.hashCode, // Use hashCode of ID as notification ID
        'Medicine Reminder',
        'Time to take ${medicine.name} - ${medicine.dose}',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
        payload: medicine.id, // Add explicit payload
      );
      print('✅ [NotificationService] Notification scheduled successfully for ${medicine.name}');
      
      // Log pending notifications count
      final pending = await getPendingNotifications();
      print('📊 [NotificationService] Total pending notifications: ${pending.length}');
    } catch (e, stackTrace) {
      print('❌ [NotificationService] Error scheduling notification: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Convert DateTime to TZDateTime for scheduling
  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    final location = tz.local;
    final now = tz.TZDateTime.now(location);
    
    var scheduledDate = tz.TZDateTime(
      location,
      now.year,
      now.month,
      now.day,
      dateTime.hour,
      dateTime.minute,
    );

    // If the scheduled time is in the past, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int notificationId) async {
    print('🗑️ [NotificationService] Cancelling notification ID: $notificationId');
    await _flutterLocalNotificationsPlugin.cancel(notificationId);
    print('✅ [NotificationService] Notification cancelled');
  }

  // Cancel notification by medicine ID
  Future<void> cancelMedicineNotification(String medicineId) async {
    print('🗑️ [NotificationService] Cancelling notification for medicine: $medicineId (ID: ${medicineId.hashCode})');
    await cancelNotification(medicineId.hashCode);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    print('🗑️ [NotificationService] Cancelling all notifications...');
    await _flutterLocalNotificationsPlugin.cancelAll();
    print('✅ [NotificationService] All notifications cancelled');
  }

  // Get list of pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  // Test notification (for debugging)
  Future<void> showTestNotification() async {
    print('🔔 [NotificationService] Showing test notification...');
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medicine_reminders_v2',
      'Medicine Reminders',
      channelDescription: 'Notifications for medicine reminders',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      999,
      'Test Notification ✅',
      'This is a test notification from Medicine Reminder - Working!',
      notificationDetails,
    );
    print('✅ [NotificationService] Test notification sent');
  }

  // Test scheduled notification (30 seconds from now)
  Future<void> showTestScheduledNotification() async {
    print('⏰ [NotificationService] Scheduling test notification for 30 seconds from now...');
    
    final scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 30));
    
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medicine_reminders_v2',
      'Medicine Reminders',
      channelDescription: 'Notifications for medicine reminders',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      visibility: NotificationVisibility.public,
      autoCancel: false,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        998,
        '⏰ Test Scheduled Notification',
        'This notification was scheduled 30 seconds ago!',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'test',
      );
      print('✅ [NotificationService] Test notification scheduled for: $scheduledDate');
      print('⏳ [NotificationService] Wait 30 seconds to see the notification...');
    } catch (e, stackTrace) {
      print('❌ [NotificationService] Error scheduling test notification: $e');
      print('Stack trace: $stackTrace');
    }
  }
}
