# Kampus Collab

A Flutter mobile application for campus collaboration — enabling students to connect, share posts, and collaborate on projects.

---

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) >= 3.41.x (stable channel)
- Dart >= 3.7.x
- [Xcode](https://developer.apple.com/xcode/) >= 16 (for iOS)
- [Android Studio](https://developer.android.com/studio) with Android SDK >= 36 (for Android)
- A running instance of the [Kampus Collab backend](https://github.com/simonbassey) (.NET API)

---

## Getting Started

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Run the app

#### Using VS Code (recommended)

Three launch configurations are pre-configured in [`.vscode/launch.json`](.vscode/launch.json):

| Configuration | Target |
| --- | --- |
| **Local (iOS Simulator)** | Your local backend on `localhost:5001` |
| **Local (Android Emulator)** | Your local backend on `10.0.2.2:5001` |
| **Remote Dev (Azure)** | Shared remote dev server on Azure |

Open the **Run and Debug** panel (`F5`) and select the appropriate config. These configs support full debugging — breakpoints, variable inspection, and hot reload all work as expected.

#### Using the terminal

```bash
# List connected/running devices
flutter devices 

# Or with timeout
flutter devices --device-timeout 5

# iOS Simulator — local backend
flutter run -d ios --dart-define=API_BASE_URL=http://localhost:5001

# Android Emulator — local backend
# Note: Android emulators use 10.0.2.2 to reach the host machine's localhost
flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:5001

# Remote dev server (default, no flag needed)
flutter run
```

> Without `--dart-define=API_BASE_URL`, the app points to the shared Azure dev server.

---

## Backend & Services

### REST API

The backend is a .NET API hosted on Azure. The base URL is configured in [`lib/constants/api.dart`](lib/constants/api.dart) and is overridable at build time via `--dart-define` as shown above.

**Default remote URL:** `https://kampus-colab-cdgdg9gec3g7b0bb.canadacentral-01.azurewebsites.net`

To run the backend locally, clone the backend repo and start the server on port `5001`.

### Supabase

The app uses [Supabase](https://supabase.com) for image storage (post images). Configuration is in [`lib/config/supabase_config.dart`](lib/config/supabase_config.dart). No local setup is required — the shared Supabase project is used in all environments.

---

## Android Setup Notes

### ADB port conflict

ADB uses port `5037` by default. If your local backend or another service is running on that port, ADB will fail to start. To avoid conflicts:

- Run your backend on a different port (e.g. `5001`)
- Or change ADB's port: `export ADB_SERVER_PORT=5038` (add to `~/.zshrc` to persist)

If ADB gets into a broken state:

```bash
pgrep -a adb          # find stuck processes
kill -9 <PID>         # kill them
adb start-server      # restart cleanly
```

### Starting an Android emulator

```bash
# List available AVDs
~/Library/Android/sdk/emulator/emulator -list-avds

# Launch one
~/Library/Android/sdk/emulator/emulator -avd <AVD_NAME>
```

---

## Project Structure

```text
lib/
├── bindings/        # GetX dependency injection bindings
├── config/          # Supabase and other service config
├── constants/       # API endpoints and app-wide constants
├── controllers/     # GetX controllers (state management)
├── models/          # Data models
├── pages/           # UI screens organized by feature
├── routes/          # App navigation/routing
├── services/        # API and data services
├── utils/           # Helpers and utilities
├── widgets/         # Shared/reusable widgets
└── main.dart        # App entry point
```

---

## Key Dependencies

| Package | Purpose |
| --- | --- |
| `get` | State management & routing (GetX) |
| `supabase_flutter` | Image storage |
| `http` | REST API calls |
| `image_picker` | Camera / gallery access |
| `google_fonts` | Typography |
| `shimmer` | Skeleton loading UI |
| `url_launcher` | Opening links |
