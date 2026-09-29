# segdude_app

A Flutter application for school timetable management. It lets a school create, generate, review and print class schedules, with sign-in and a purchase flow around it.

The project is built from a single Flutter codebase with support for phone, tablet, desktop and web platforms.

## Features

* **Authentication** — sign in, sign up and password reset, backed by Supabase Auth.
* **Schedule** — the core feature:

  * configure days, time slots, breaks and per-day overrides;
  * manage teachers, rooms, subjects (including consecutive-hour rules), levels and classes;
  * split classes into groups and merge classes;
  * apply manual overrides;
  * generate a schedule through the Schedule API;
  * review the result across several views and print it.
* **Payment** — a purchase page and a bank-transfer flow that unlocks the app.
* **Localization** — English, French and Arabic.
* **Local persistence** — the schedule setup is saved on the device with `shared_preferences`.

## Tech Stack

* Flutter and Dart (see `pubspec.yaml` for the exact SDK constraints)
* State management: [Riverpod](https://riverpod.dev/)
* Backend: [Supabase](https://supabase.com/) (authentication) and a separate Schedule API
* Localization: Flutter `gen-l10n` (`l10n.yaml`, ARB files in `lib/l10n`)

## Project Structure

The code follows a feature-first layout, with each feature split into `data`, `domain` and `presentation`.

```text
lib/
  main.dart                 App entry point and startup loading
  app/                      MaterialApp and router
  core/
    config/                 AppEnv: build-time configuration (dart-defines)
    constants/
    errors/
    network/
    providers/
    storage/
  features/
    auth/                   data / domain / presentation
    payment/                data / domain / presentation
    schedule/               data / domain / presentation
  l10n/                     ARB files and generated localizations
  shared/widgets/           Reusable widgets

test/                       Unit tests
images/                     App images

web/
android/
ios/
macos/
linux/
windows/
```

## Getting Started

### Prerequisites

* The Flutter SDK, on a version compatible with `pubspec.yaml`
* For Android: Android Studio or the Android SDK command-line tools
* A Supabase project and access to the Schedule API

Check your setup with:

```bash
flutter doctor
```

### Install Dependencies

```bash
flutter pub get
```

### Configuration

The app does not bundle a `.env` asset. Configuration is passed at build time with `--dart-define` and read through `AppEnv` (`lib/core/config/app_env.dart`).

At startup, `AppEnv.assertConfigured()` stops the app with a clear error if a required value is missing.

Create a local `.env` file at the project root with these variables:

```text
SCHEDULE_API_BASE_URL=<your Schedule API base URL>
SUPABASE_URL=<your Supabase project URL>
SUPABASE_ANON_KEY=<your Supabase anon/publishable key>
```

`.env` is listed in `.gitignore` and must never be committed.

See `lib/core/config/app_env.dart` for the full list of supported values.

### Run

From VS Code, open **Run and Debug**, select **segdude_app (Development)** and start it.

The configuration in `.vscode/launch.json` passes `.env` to Flutter automatically. Launching from the code lenses above `main()` bypasses this configuration and leaves the values undefined.

From the command line:

```bash
flutter run -d chrome --dart-define-from-file=.env
```

Replace `chrome` with any device from:

```bash
flutter devices
```

### Android

To run the application on an Android device or emulator:

```bash
flutter run -d <android-device-id> --dart-define-from-file=.env
```

The Android platform is included in the project and has been built and run successfully.

## Quality Checks

Run the following before committing changes:

```bash
flutter analyze
flutter test
```

If you change the ARB files in `lib/l10n`, regenerate the localizations:

```bash
flutter gen-l10n
```

## Platform Status

* **Android** — built and run successfully.
* **Web** — built and run successfully.
* **iOS**, **macOS**, **Linux** and **Windows** — platform folders are present but have not been fully verified yet.
* Production release setup, including Android signing and store configuration, is not covered yet.