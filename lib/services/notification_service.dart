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
      // Initialize timezone - use system timezone
      tz.initializeTimeZones();
      
      // Get the device's local timezone name
      final String timeZoneName = DateTime.now().timeZoneName;
      final String timeZoneOffset = DateTime.now().timeZoneOffset.toString();
      
      print('🌍 [NotificationService] Device timezone: $timeZoneName (UTC offset: $timeZoneOffset)');
      
      // Try to use the system timezone, fallback to UTC if not found
      try {
        // Common timezone mappings for Android/iOS
        String tzLocation;
        if (timeZoneName == 'IST') {
          tzLocation = 'Asia/Kolkata';
        } else if (timeZoneName == 'PST' || timeZoneName == 'PDT') {
          tzLocation = 'America/Los_Angeles';
        } else if (timeZoneName == 'EST' || timeZoneName == 'EDT') {
          tzLocation = 'America/New_York';
        } else if (timeZoneName == 'GMT' || timeZoneName == 'UTC') {
          tzLocation = 'UTC';
        } else {
          // Try to infer from offset
          final offset = DateTime.now().timeZoneOffset;
          if (offset.inHours == 5 && offset.inMinutes == 330) {
            tzLocation = 'Asia/Kolkata'; // IST
          } else if (offset.inHours == 0) {
            tzLocation = 'UTC';
          } else {
            // Default to UTC if we can't determine
            tzLocation = 'UTC';
          }
        }
        
        final location = tz.getLocation(tzLocation);
        tz.setLocalLocation(location);
        print('✅ [NotificationService] Timezone set to: ${tz.local.name}');
      } catch (e) {
        print('⚠️ [NotificationService] Could not find timezone location, using UTC: $e');
        tz.setLocalLocation(tz.getLocation('UTC'));
      }

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
    print('📅 [NotificationService] Scheduling notification:');
    print('   Medicine: ${medicine.name}');
    print('   Dose: ${medicine.dose}');
    print('   Time: ${medicine.time}');
    print('   Frequency: ${medicine.frequency}');
    print('   Selected Days: ${medicine.selectedDays}');

    // Cancel any existing notification
    await cancelMedicineNotification(medicine.id);

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
      ongoing: false,
      ticker: 'Medicine Reminder',
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
      switch (medicine.frequency) {
        case FrequencyType.daily:
          await _scheduleDailyNotification(medicine, notificationDetails);
          break;
        case FrequencyType.specificDays:
          await _scheduleSpecificDaysNotification(medicine, notificationDetails);
          break;
        case FrequencyType.interval:
          await _scheduleIntervalNotification(medicine, notificationDetails);
          break;
      }
      
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

  // Schedule daily notification (original behavior)
  Future<void> _scheduleDailyNotification(
    Medicine medicine,
    NotificationDetails notificationDetails,
  ) async {
    final scheduledDate = _convertToTZDateTime(medicine.time);
    print('   📆 Scheduling daily notification for: $scheduledDate');

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      medicine.id.hashCode,
      'Medicine Reminder',
      'Time to take ${medicine.name} - ${medicine.dose}',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      payload: medicine.id,
    );
  }

  // Schedule notification for specific days of the week
  Future<void> _scheduleSpecificDaysNotification(
    Medicine medicine,
    NotificationDetails notificationDetails,
  ) async {
    if (medicine.selectedDays.isEmpty) {
      print('⚠️ [NotificationService] No days selected for specific days notification');
      return;
    }

    print('   📆 Scheduling for specific days: ${medicine.selectedDays}');
    
    // Schedule a notification for each selected day
    // Using different IDs for each day to allow proper weekly scheduling
    for (int i = 0; i < medicine.selectedDays.length; i++) {
      final dayOfWeek = medicine.selectedDays[i];
      final notificationId = '${medicine.id}_$dayOfWeek'.hashCode;
      
      final scheduledDate = _getNextOccurrenceOfDay(
        medicine.time,
        dayOfWeek,
      );
      
      print('   📌 Day ${_getDayName(dayOfWeek)}: $scheduledDate (ID: $notificationId)');
      
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        'Medicine Reminder',
        'Time to take ${medicine.name} - ${medicine.dose}',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // Repeat weekly on specific day
        payload: medicine.id,
      );
    }
  }

  // Schedule notification with interval (every X days)
  Future<void> _scheduleIntervalNotification(
    Medicine medicine,
    NotificationDetails notificationDetails,
  ) async {
    final interval = medicine.intervalDays ?? 1;
    print('   📆 Scheduling with interval: every $interval day(s)');
    
    // For interval scheduling, we'll use the daily repeat and rely on app logic
    // Note: flutter_local_notifications doesn't natively support custom intervals
    // A better approach would be to calculate and schedule multiple individual notifications
    final scheduledDate = _convertToTZDateTime(medicine.time);
    
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      medicine.id.hashCode,
      'Medicine Reminder',
      'Time to take ${medicine.name} - ${medicine.dose}',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: medicine.id,
    );
  }

  // Get next occurrence of a specific day of week
  tz.TZDateTime _getNextOccurrenceOfDay(DateTime time, int dayOfWeek) {
    // dayOfWeek: 1=Monday, 2=Tuesday, ..., 7=Sunday
    final location = tz.local;
    var scheduledDate = tz.TZDateTime(
      location,
      tz.TZDateTime.now(location).year,
      tz.TZDateTime.now(location).month,
      tz.TZDateTime.now(location).day,
      time.hour,
      time.minute,
    );

    // Calculate days until target day of week
    // Flutter's DateTime.weekday: 1=Monday, 7=Sunday (same as our convention)
    final currentWeekday = scheduledDate.weekday;
    int daysUntilTarget = (dayOfWeek - currentWeekday) % 7;
    
    // If the day is today but time has passed, schedule for next week
    if (daysUntilTarget == 0 && scheduledDate.isBefore(tz.TZDateTime.now(location))) {
      daysUntilTarget = 7;
    }

    scheduledDate = scheduledDate.add(Duration(days: daysUntilTarget));
    return scheduledDate;
  }

  // Get day name from number
  String _getDayName(int dayNumber) {
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[dayNumber];
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
    print('🗑️ [NotificationService] Cancelling notifications for medicine: $medicineId');
    
    // Cancel main notification
    await cancelNotification(medicineId.hashCode);
    
    // Cancel all day-specific notifications (for specific days frequency)
    for (int day = 1; day <= 7; day++) {
      final dayNotificationId = '${medicineId}_$day'.hashCode;
      await cancelNotification(dayNotificationId);
    }
    
    print('✅ [NotificationService] All notifications cancelled for medicine');
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

  // Debug method: Print all pending notifications
  Future<void> debugPrintPendingNotifications() async {
    print('📋 [NotificationService] Checking pending notifications...');
    final pending = await getPendingNotifications();
    print('📊 [NotificationService] Total pending: ${pending.length}');
    
    if (pending.isEmpty) {
      print('⚠️ [NotificationService] No pending notifications found!');
    } else {
      for (var notification in pending) {
        print('   - ID: ${notification.id}');
        print('     Title: ${notification.title}');
        print('     Body: ${notification.body}');
        print('     Payload: ${notification.payload}');
      }
    }
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
