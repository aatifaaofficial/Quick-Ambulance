import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../config/firebase_config.dart';

class FirebaseService {
  static bool _isConfigured = false;

  static bool get isConfigured => _isConfigured;

  static Future<void> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isConfigured = true;
        return;
      }

      final options = FirebaseConfig.options;
      if (options == null) {
        _isConfigured = false;
        debugPrint('Firebase configuration is missing; using local demo mode.');
        return;
      }

      await Firebase.initializeApp(options: options);
      _isConfigured = true;
    } catch (error, stackTrace) {
      _isConfigured = false;
      debugPrint('Firebase initialization failed; using local demo mode: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static FirebaseAuth get auth {
    _requireConfigured();
    return FirebaseAuth.instance;
  }

  static FirebaseFirestore get firestore {
    _requireConfigured();
    return FirebaseFirestore.instance;
  }

  static FirebaseStorage get storage {
    _requireConfigured();
    return FirebaseStorage.instance;
  }

  static FirebaseMessaging get messaging {
    _requireConfigured();
    return FirebaseMessaging.instance;
  }

  static void _requireConfigured() {
    if (!_isConfigured) {
      throw StateError('Firebase is not configured. The app is running in demo mode.');
    }
  }
}
