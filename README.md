# Kigali City Services

A Flutter app to discover and add local services in Kigali (cafés, pharmacies, restaurants, police stations, and more).

## Features

- **Directory** — Browse services by category and search
- **My Listings** — Add and manage your own service listings
- **Map** — View services on a map
- **Near You** — Distances based on your location

## Prerequisites

- [Flutter](https://flutter.dev) (SDK ^3.10.8)
- Firebase project with Auth and Firestore enabled
- Google Maps API key (for map and location)

## Setup

1. Clone the repo and open the project folder.
2. Run `flutter pub get`.
3. Add your Firebase config:
   - Place `google-services.json` in `android/app/`
   - Configure iOS in Xcode if building for iOS
4. Ensure `lib/firebase_options.dart` exists (e.g. via `flutterfire configure`).
5. Add your Google Maps API key in `android/app/src/main/AndroidManifest.xml` (already has a placeholder).

## Run

```bash
flutter pub get
flutter run
```

For a physical device, enable USB debugging and run:

```bash
flutter devices
flutter run -d <device_id>
```

## Tech

- Flutter, Provider, Firebase (Auth + Firestore), Google Maps, Geolocator
