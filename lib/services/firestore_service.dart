import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/booking_request.dart';
import '../models/user_profile.dart';

class FirestoreService {
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  static Future<void> saveUserProfile(UserProfile user) async {
    try {
      await firestore.collection('users').doc(user.id).set({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'address': user.address,
        'role': user.role.name,
        'ambulanceType': user.ambulanceType,
      }, SetOptions(merge: true));
    } catch (_) {
      // Demo mode handles local state without Firebase.
    }
  }

  static Future<void> saveBooking(BookingRequest booking) async {
    try {
      await firestore.collection('bookings').doc(booking.id).set({
        'id': booking.id,
        'userId': booking.userId,
        'patientName': booking.patientName,
        'pickupLocation': booking.pickupLocation,
        'destination': booking.destination,
        'ambulanceType': booking.ambulanceType,
        'status': booking.status.name,
        'driverName': booking.driverName,
        'driverPhone': booking.driverPhone,
        'notes': booking.notes,
        'requestedAt': booking.requestedAt.toUtc().toIso8601String(),
        'etaMinutes': booking.etaMinutes,
      }, SetOptions(merge: true));
    } catch (_) {
      // Demo mode handles local state without Firebase.
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> bookingsStream() {
    return firestore.collection('bookings').orderBy('requestedAt', descending: true).snapshots();
  }
}
