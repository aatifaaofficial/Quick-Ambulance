import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import 'firebase_service.dart';

class StorageService {
  static Future<String> uploadBytes({
    required Uint8List bytes,
    required String storagePath,
    required String contentType,
  }) async {
    if (bytes.isEmpty) {
      throw ArgumentError.value(bytes, 'bytes', 'Cannot upload an empty file.');
    }

    final reference = FirebaseService.storage.ref(storagePath);
    final result = await reference.putData(
      bytes,
      SettableMetadata(contentType: contentType),
    );
    return result.ref.getDownloadURL();
  }
}
