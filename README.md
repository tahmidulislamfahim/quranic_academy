# quranic_academy

quranic_academy is a Flutter application that provides Islamic resources and utilities (prayer times, zakat calculations, location-based services, etc.). This repository contains the full Flutter project (Android, iOS, web, desktop targets) and the app source under `lib/`.

## Key Features

- Prayer times and notifications
- Zakat calculation utilities
- Location-based services using device GPS
- Modular app architecture (controllers, services, views, theme)

## Quick Start (Development)

Prerequisites

- Install Flutter (stable channel) — see https://flutter.dev/docs/get-started/install
- Have Android SDK / Xcode installed for mobile builds (or use an emulator/simulator)

Clone and install dependencies

```powershell
git clone <repository-url>
cd quranic_academy
flutter pub get
```

Run on a connected device or emulator

```powershell
flutter run -d all
```

Build release APK (Android)

```powershell
flutter build apk --release
```

Build for iOS (on macOS)

```bash
flutter build ios --release
```

Run tests

```powershell
flutter test
```

## Project Structure

- `lib/` — main Dart source:
	- `main.dart` — app entrypoint
	- `app/app.dart` — high-level app setup and routing
	- `controllers/` — state controllers
	- `services/` — API, location, prayer and zakat logic
	- `views/` — UI screens
	- `theme/` — app theming
- `assets/` — images and static assets
- `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/` — platform embedding
- `test/` — unit/widget tests

## Important Files

- `pubspec.yaml` — Dart/Flutter package and asset configuration
- `lib/main.dart` — application entry point
- `android/app/build.gradle` and `android/gradle.properties` — Android build config

## Environment & Configuration

- If your app uses API keys or environment values, prefer injecting them through platform-specific secure configuration or CI secrets. Do not commit secrets to the repo.
- See `local.properties` for Android SDK path on local machines (auto-generated).

## Android Release Signing (brief)

1. Generate a signing key (if you don't have one):

```powershell
keytool -genkey -v -keystore release_key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release_key
```

2. Configure `android/app/build.gradle` and `key.properties` per Flutter docs:
	 https://docs.flutter.dev/deployment/android

## Troubleshooting

- If `flutter build apk --release` fails (exit code 1), first run:

```powershell
flutter clean; flutter pub get
```

- Check for common issues:
	- Missing Android SDK or wrong `local.properties` path
	- Gradle plugin / Java version mismatch
	- Platform-specific plugin build failures (check the full error output)

If you need help debugging a specific failure, paste the full `flutter build` error and I can help pinpoint the cause.

## Contributing

- Fork the repo and open a PR for changes.
- Keep changes modular and add tests for new logic when possible.

## License & Contact

This project does not include a license file in the repository. If you want this project to be open-source, add a `LICENSE` file (for example MIT or Apache-2.0).

For questions or help, open an issue or contact the repository maintainer.

---

See `pubspec.yaml` for full dependency list and further configuration.
