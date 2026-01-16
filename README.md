# Medicine Reminder App 💊

A Flutter application for managing daily medicine reminders with scheduled notifications. Never miss your medication with smart, timezone-aware notifications that work even when the app is closed.

## ✨ Features

- 📋 **Medicine Management**: View all medicines sorted by scheduled time
- ➕ **Easy Add Medicine**: Simple form to add medicine with name, dose, and time
- ⏰ **Smart Notifications**: Receive daily reminders at scheduled times with sound and vibration
- 🌍 **Auto Timezone Detection**: Automatically uses device's system timezone for accurate scheduling
- 💾 **Local Storage**: All data stored securely on device using Hive
- 🔔 **Background Notifications**: Notifications fire even when app is minimized or closed
- 🎨 **Clean UI**: Modern design with teal and orange color scheme
- 🧪 **Test Notifications**: Built-in test buttons to verify notification system
- 📱 **Lock Screen Support**: Notifications appear on lock screen with full details
- 🔊 **High Priority**: MAX importance notifications ensure they're never missed

## 📱 Screenshots

*(Screenshots showcasing the app interface)*

## 🛠️ Tech Stack

- **Flutter SDK**: ^3.8.1 (Dart 3.0+)
- **State Management**: Provider ^6.1.1
- **Local Storage**: Hive ^2.2.3 + Hive Flutter ^1.1.0
- **Notifications**: Flutter Local Notifications ^17.0.0
- **Timezone**: ^0.9.2 for accurate alarm scheduling
- **Serialization**: json_annotation ^4.8.1
- **Code Generation**: build_runner ^2.4.7

### Android Configuration
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 34 (Android 14)
- **Compile SDK**: Set by Flutter

## 📂 Project Structure

```
lib/
├── main.dart                      # App entry point
├── models/
│   ├── medicine.dart              # Medicine data model
│   └── medicine.g.dart            # Generated Hive adapter
├── providers/
│   └── medicine_provider.dart     # State management with Provider
├── services/
│   ├── notification_service.dart  # Notification scheduling & management
│   └── storage_service.dart       # Hive database operations
├── screens/
│   ├── home_screen.dart           # Main screen with medicine list
│   └── add_medicine_screen.dart   # Form to add new medicine
├── widgets/
│   └── medicine_tile.dart         # Individual medicine card
└── utils/
    └── app_colors.dart            # App color constants

android/
├── app/
│   ├── build.gradle.kts           # Android build configuration
│   └── src/main/
│       ├── AndroidManifest.xml    # App permissions & receivers
│       └── java/.../MainActivity.java  # Notification channel setup
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.8.1 or higher ([Install Flutter](https://flutter.dev/docs/get-started/install))
- Android Studio / VS Code with Flutter extension
- Android device or emulator (Android 5.0 / API 21+)
- Git for version control

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/YadneshTeli/meds_remind.git
cd meds_remind
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Generate Hive adapters:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Connect device or start emulator**, then run:
```bash
flutter run
```

### Building APK

To build a release APK for distribution:

```bash
flutter build apk --release
```

The APK will be available at: `build/app/outputs/flutter-apk/app-release.apk`

For split APKs (smaller size):
```bash
flutter build apk --split-per-abi --release
```

## 📖 How to Use

### Adding a Medicine
1. Tap the **+** button on the home screen
2. Enter medicine name (e.g., "Paracetamol")
3. Enter dosage (e.g., "1 tablet", "5ml syrup")
4. Select time using the time picker
5. Tap "Add Medicine"

### Managing Medicines
- **View**: All medicines displayed on home screen, sorted by time
- **Delete**: Tap the delete icon (🗑️) on any medicine card
- **Auto-notification**: Notifications scheduled automatically when medicine is added

### Testing Notifications
- **Immediate Test**: Tap the bell icon (🔔) for instant notification
- **Scheduled Test**: Tap the alarm icon (⏰) for notification in 30 seconds
- Use these to verify notification system is working before relying on medicine reminders

### First-Time Setup
1. **Grant permissions** when prompted:
   - Notification permission (Android 13+)
   - Schedule exact alarms permission (Android 12+)
2. **Check notification settings**:
   - Settings → Apps → Medicine Reminder → Notifications
   - Ensure "Medicine Reminders" channel is enabled and set to "Urgent"

## ⚙️ Permissions

The app requires the following Android permissions for full functionality:

| Permission | Purpose |
|------------|---------|
| `RECEIVE_BOOT_COMPLETED` | Restore alarms after device restart |
| `VIBRATE` | Notification vibration alerts |
| `SCHEDULE_EXACT_ALARM` | Precise alarm scheduling |
| `USE_EXACT_ALARM` | Fallback for exact alarms |
| `POST_NOTIFICATIONS` | Show notifications (Android 13+) |
| `WAKE_LOCK` | Wake device for critical notifications |

All permissions are handled automatically by the app with appropriate runtime requests.

## 🔧 Key Features Implementation

### State Management with Provider
- **MedicineProvider**: Manages medicine list state
- **NotifyListeners**: Updates UI automatically when data changes
- **Clean separation**: UI components remain stateless

### Notification System
- **Platform**: `flutter_local_notifications` v17.0.0
- **Scheduling**: `AndroidScheduleMode.exactAllowWhileIdle` for background reliability
- **Importance**: `MAX` priority for heads-up notifications
- **Channel**: Separate notification channel with alarm audio attributes
- **Timezone-aware**: Automatically detects system timezone (IST, PST, EST, etc.)
- **Daily repeat**: Uses `DateTimeComponents.time` for daily recurrence
- **Background execution**: Works when app is closed via `ScheduledNotificationReceiver`

### Data Persistence with Hive
- **Type-safe**: Generated adapters for Medicine model
- **Fast**: NoSQL database optimized for mobile
- **Automatic**: Data loads on app start, saves immediately on changes
- **Box**: Named "medicines" box stores all medicine data

### Debug Logging
- **Emoji-prefixed logs**: Easy to filter and identify (🚀📦💾🔔⏰✅❌)
- **Comprehensive**: Logs all operations (add, delete, schedule, permission checks)
- **Production-ready**: Can be disabled by removing print statements

## 🐛 Troubleshooting

### Notifications not appearing?

1. **Check permissions:**
   - Settings → Apps → Medicine Reminder → Permissions
   - Ensure Notifications and Alarms & reminders are enabled

2. **Check notification channel:**
   - Settings → Apps → Medicine Reminder → Notifications
   - Tap "Medicine Reminders" channel
   - Set to "Urgent" or "Make sound and pop on screen"

3. **Battery optimization:**
   - Settings → Battery → Battery optimization
   - Find Medicine Reminder and set to "Don't optimize"

4. **Reinstall if needed:**
   - Android caches notification channel settings
   - Uninstall completely, then reinstall to reset channels

### App crashes on startup?

1. **Run build_runner:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

2. **Clean and rebuild:**
```bash
flutter clean
flutter pub get
flutter run
```

### Notifications work when app is open but not closed?

- Ensure `SCHEDULE_EXACT_ALARM` permission is granted
- Check that the app is not being killed by aggressive battery savers (Xiaomi, Oppo, Vivo devices)
- Verify notification importance is set to MAX in device settings

## 🧪 Development

### Running Tests
```bash
flutter test
```

### Code Generation
After modifying the Medicine model or adding new Hive models:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Debug Logs
View detailed logs using:
```bash
flutter run --verbose
```

Or filter logs by service:
```bash
adb logcat | grep "NotificationService"
adb logcat | grep "StorageService"
adb logcat | grep "MedicineProvider"
```

### Hot Reload/Restart
- Hot reload: `r` in terminal or Ctrl+S in IDE
- Hot restart: `R` in terminal or Shift+Ctrl+F5 in IDE
- Full restart: `flutter run` again

## 📋 Git Commit History

This project was developed incrementally with logical commit batches:
1. Storage service logging implementation
2. App lifecycle logging
3. Android SDK configuration (minSdk, targetSdk)
4. AndroidManifest receiver addition
5. MainActivity enhancement with notification channels
6. Core notification service implementation
7. UI enhancements (test buttons, home screen)
8. Platform files update
9. Notification importance upgrade to MAX
10. Timezone auto-detection feature

## 🤝 Contributing

This is an assignment project, but suggestions are welcome:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 Future Enhancements

- [ ] Multiple notifications per day per medicine
- [ ] Medicine inventory tracking
- [ ] Notification history/log
- [ ] Snooze functionality
- [ ] Refill reminders
- [ ] Export/Import medicine data
- [ ] Dark mode support
- [ ] Cloud sync (Firebase)

## 👨‍💻 Author

**Yadnesh Teli**
- GitHub: [@YadneshTeli](https://github.com/YadneshTeli)
- Repository: [meds_remind](https://github.com/YadneshTeli/meds_remind)

## 📄 License

This project is created as an assignment submission for educational purposes.

---

**Built with ❤️ using Flutter**

