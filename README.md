# Medicine Reminder App

A Flutter application for managing daily medicine reminders with scheduled notifications.

## Features

- 📋 **Medicine List**: View all medicines sorted by time
- ➕ **Add Medicine**: Simple form to add medicine with name, dose, and time
- ⏰ **Scheduled Notifications**: Receive daily reminders at scheduled times
- 💾 **Local Storage**: All data stored locally using Hive
- 🎨 **Clean UI**: Teal and Orange color scheme

## Screenshots

*(Add screenshots after building the app)*

## Tech Stack

- **Flutter SDK**: ^3.8.1
- **State Management**: Provider
- **Local Storage**: Hive + Hive Flutter
- **Notifications**: Flutter Local Notifications
- **Timezone**: For accurate alarm scheduling

## Project Structure

```
lib/
├── main.dart
├── models/
│   └── medicine.dart
├── providers/
│   └── medicine_provider.dart
├── services/
│   ├── notification_service.dart
│   └── storage_service.dart
├── screens/
│   ├── home_screen.dart
│   └── add_medicine_screen.dart
├── widgets/
│   └── medicine_tile.dart
└── utils/
    └── app_colors.dart
```

## Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Android Studio / VS Code
- Android device or emulator (Android 6.0+)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/YadneshTeli/meds_remind.git
cd meds_remind
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Hive adapters:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the app:
```bash
flutter run
```

### Building APK

To build a release APK:

```bash
flutter build apk --release
```

The APK will be available at: `build/app/outputs/flutter-apk/app-release.apk`

## How It Works

1. **Add Medicine**: Tap the + button, fill in medicine details and select a time
2. **View Medicines**: All medicines are displayed on the home screen, sorted by time
3. **Notifications**: The app schedules daily notifications at the specified times
4. **Delete Medicine**: Tap the delete icon to remove a medicine

## Permissions

The app requires the following Android permissions:
- `RECEIVE_BOOT_COMPLETED`: To restore alarms after device restart
- `VIBRATE`: For notification vibration
- `SCHEDULE_EXACT_ALARM`: For precise alarm scheduling
- `POST_NOTIFICATIONS`: To show notifications (Android 13+)
- `WAKE_LOCK`: To wake the device for notifications

## Key Features Implementation

### State Management
Uses Provider for clean separation of UI and business logic.

### Notifications
- Scheduled using `flutter_local_notifications`
- Timezone-aware scheduling
- Works even when app is closed
- Daily repeating notifications

### Data Persistence
- Hive for fast, efficient local storage
- Type-safe storage with generated adapters
- Automatic data loading on app start

## Development

### Running Tests
```bash
flutter test
```

### Code Generation
If you modify the Medicine model:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Author

**Yadnesh Teli**

## License

This project is created as an assignment submission.

