# Hourglass Flutter App

Cross-platform mobile application for iOS and Android.

## Setup

1. Install Flutter 3.2+ from [flutter.dev](https://flutter.dev)

2. Copy environment file:
```bash
cp .env.example .env
```

3. Edit `.env` with your Supabase credentials:
```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
API_BASE_URL=http://localhost:8000
```

4. Install dependencies:
```bash
flutter pub get
```

5. Generate code (for Freezed/JSON):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Running

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d chrome        # Web
flutter run -d iPhone        # iOS Simulator
flutter run -d android       # Android Emulator

# Run with specific flavor
flutter run --debug
flutter run --release
flutter run --profile
```

## Project Structure

```
lib/
├── core/               # Core utilities
│   ├── constants.dart  # App constants
│   ├── theme.dart      # Theme configuration
│   ├── router.dart     # GoRouter configuration
│   └── env.dart        # Environment variables
├── data/               # Data layer
│   ├── models/         # Data models (Freezed)
│   └── services/       # API services
├── logic/              # Business logic (Riverpod)
│   └── providers/      # State providers
└── ui/                 # Presentation layer
    ├── widgets/        # Reusable widgets
    └── screens/        # App screens
```

## Key Dependencies

- **flutter_riverpod**: State management
- **supabase_flutter**: Backend integration
- **go_router**: Navigation
- **freezed**: Immutable models
- **flutter_animate**: Animations

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/services/auto_valuation_test.dart
```

## Building

```bash
# Android APK
flutter build apk

# Android App Bundle
flutter build appbundle

# iOS
flutter build ios

# Web
flutter build web
```

## Troubleshooting

**Issue**: Build fails with "Target of URI doesn't exist"
**Solution**: Run `flutter pub get` and `flutter pub run build_runner build`

**Issue**: Supabase connection fails
**Solution**: Check `.env` file and ensure Supabase URL/keys are correct

**Issue**: Hot reload not working
**Solution**: Restart with `flutter run` or press 'R' in terminal
