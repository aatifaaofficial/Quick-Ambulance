# Quick Ambulance Setup Guide

## 1. Install Flutter

Install Flutter 3.11+ and ensure `flutter` is available in your terminal.

## 2. Get project dependencies

```bash
cd "Quick Ambulance"
flutter pub get
```

## 3. Run the app

```bash
flutter run
```

## 4. Demo mode

The app is configured to run without Firebase by default. Demo data is supplied through the provider layer so the project keeps working while backend setup is pending.

## 5. Firebase configuration (optional)

To connect to Firebase for production-like behavior:

1. Create a Firebase project.
2. Enable Authentication, Firestore, Storage, and Cloud Messaging.
3. Add the Android app package ID (currently `com.quickambulance`).
4. Download `google-services.json` and place it in `android/app`.
5. Add Firebase options or replace the placeholder values in `lib/config/firebase_config.dart`.
6. Re-run:

```bash
flutter pub get
flutter run
```

## 6. Demo roles

- Patient: `patient@example.com` / `123456`
- Driver: `driver@example.com` / `123456`
- Admin: `admin@quickambulance.com` / `123456`

## 7. Troubleshooting

- If you see errors on launch: `flutter clean && flutter pub get`
- If Android SDK is missing: install Android Studio and SDK components
- If Firebase is not configured: app remains fully functional in demo mode
