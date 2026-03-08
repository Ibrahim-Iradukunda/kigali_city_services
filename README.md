# kigali_city_services

A new Flutter project.

## Web & Firebase

- **Run web**: Use `flutter run -d chrome` (or `flutter run -d web-server`) so the app and debug service run correctly. Avoid opening `index.html` as a file; use the URL Flutter prints.
- **Google Maps**: Loaded with `loading=async` in `web/index.html` for best practice.
- **Firebase Auth 400 (identitytoolkit)**: If sign-in or sign-up returns 400:
  1. In [Firebase Console](https://console.firebase.google.com) → your project → **Authentication** → **Sign-in method**.
  2. Enable **Email/Password** (and optionally Email link if you use it).
  3. Use a valid email and a password of at least 6 characters.

### "Failed to load resource: net::ERR_CONNECTION_REFUSED" (web debug)

- **What it means**: The browser tried to load a script or resource from a URL (often `http://127.0.0.1:port` or `ws://127.0.0.1:port`) and nothing was listening on that port, so the connection was refused.
- **Typical causes**:
  - You opened the app in a tab that was using an **old dev-server URL** (e.g. from a previous run). The port changes each run, so the old URL no longer works.
  - You opened `index.html` via **file://** or from a different server, so relative requests go to the wrong place.
- **What to do**:
  1. Stop the app (Ctrl+C in the terminal where `flutter run` is running).
  2. Start again with: `flutter run -d chrome`.
  3. Use **only** the URL that Flutter prints (e.g. `http://localhost:12345`). Open it in a new tab if needed.
  4. Do a hard refresh: **Ctrl+Shift+R** (Windows/Linux) or **Cmd+Shift+R** (Mac).
  5. If it still happens, clear the site’s cache for that host (e.g. localhost) and try again.

The lines **"DDC is about to load 1/2 scripts"** and **"This app is linked to the debug service: ws://127.0.0.1:..."** are normal: they mean the Dart Dev Compiler is loading the app and the debug service is attached. The app can still work; the REFUSED error is usually for one extra request (e.g. old URL or source map). Following the steps above avoids that.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
