import 'dart:convert';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ambulance.dart';
import '../models/booking_request.dart';
import '../models/hospital.dart';
import '../models/user_profile.dart';
import 'firebase_service.dart';

class FirestoreService {
  static FirebaseFirestore get firestore => FirebaseService.firestore;

  static Future<void> saveUserProfile(UserProfile user) {
    return firestore.collection('users').doc(user.id).set({
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'phone': user.phone,
      'address': user.address,
      'role': user.role.name,
      'ambulanceType': user.ambulanceType,
      'age': user.age,
    }, SetOptions(merge: true));
  }

  static Future<UserProfile?> getUserProfile(String userId) async {
    final snapshot = await firestore.collection('users').doc(userId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      return null;
    }

    return UserProfile.fromMap(data, id: snapshot.id);
  }

  static Future<void> saveBooking(BookingRequest booking) {
    return firestore.collection('bookings').doc(booking.id).set({
      'id': booking.id,
      'userId': booking.userId,
      'patientName': booking.patientName,
      'patientPhone': booking.patientPhone,
      'pickupLocation': booking.pickupLocation,
      'destination': booking.destination,
      'ambulanceType': booking.ambulanceType,
      'status': booking.statusKey,
      'driverName': booking.driverName,
      'driverPhone': booking.driverPhone,
      'driverId': booking.driverId,
      'driverLatitude': booking.driverLatitude,
      'driverLongitude': booking.driverLongitude,
      'notes': booking.notes,
      'requestedAt': Timestamp.fromDate(booking.requestedAt),
      'etaMinutes': booking.etaMinutes,
    }, SetOptions(merge: true));
  }

  static Stream<List<BookingRequest>> bookingsStream(UserProfile user) {
    if (user.role == UserRole.patient) {
      return _bookingQuery(firestore
        .collection('bookings')
        .where('userId', isEqualTo: user.id));
    }
    if (user.role == UserRole.admin) {
      return _bookingQuery(firestore.collection('bookings'));
    }

    late StreamController<List<BookingRequest>> controller;
    StreamSubscription<List<BookingRequest>>? pendingSubscription;
    StreamSubscription<List<BookingRequest>>? assignedSubscription;
    var pending = <BookingRequest>[];
    var assigned = <BookingRequest>[];

    void emit() {
      final byId = <String, BookingRequest>{
        for (final booking in [...pending, ...assigned]) booking.id: booking,
      };
      controller.add(byId.values.toList(growable: false));
    }

    controller = StreamController<List<BookingRequest>>(
      onListen: () {
        pendingSubscription = _bookingQuery(
          firestore
              .collection('bookings')
              .where('status', isEqualTo: 'pending'),
        ).listen((value) {
          pending = value;
          emit();
        }, onError: controller.addError);
        assignedSubscription = _bookingQuery(
          firestore
              .collection('bookings')
              .where('driverId', isEqualTo: user.id),
        ).listen((value) {
          assigned = value;
          emit();
        }, onError: controller.addError);
      },
      onCancel: () async {
        await pendingSubscription?.cancel();
        await assignedSubscription?.cancel();
      },
    );
    return controller.stream;
  }

  static Stream<List<BookingRequest>> _bookingQuery(
    Query<Map<String, dynamic>> query,
  ) {
    return query
        .snapshots()
        .map(
          (snapshot) {
            final bookings = snapshot.docs.map((document) {
            final data = Map<String, dynamic>.from(document.data());
            final requestedAt = data['requestedAt'];
            if (requestedAt is Timestamp) {
              data['requestedAt'] = requestedAt.toDate();
            }
            return BookingRequest.fromMap(data, id: document.id);
            }).toList();
            bookings.sort(
              (first, second) => second.requestedAt.compareTo(first.requestedAt),
            );
            return bookings;
          },
        );
  }

  static Stream<List<Hospital>> hospitalsStream() {
    return firestore.collection('hospitals').snapshots().map(
          (snapshot) => snapshot.docs
              .map((document) => Hospital.fromMap(
                    document.data(),
                    id: document.id,
                  ))
              .toList(growable: false),
        );
  }

  static Stream<List<Ambulance>> ambulancesStream() {
    return firestore.collection('ambulances').snapshots().map(
          (snapshot) => snapshot.docs
              .map((document) => Ambulance.fromMap(
                    document.data(),
                    id: document.id,
                  ))
              .toList(growable: false),
        );
  }

  static Stream<List<UserProfile>> usersStream() {
    return firestore.collection('users').snapshots().map(
          (snapshot) => snapshot.docs
              .map((document) => UserProfile.fromMap(
                    document.data(),
                    id: document.id,
                  ))
              .toList(growable: false),
        );
  }

  static Future<void> saveAmbulance(Ambulance ambulance) {
    return firestore.collection('ambulances').doc(ambulance.id).set({
      'id': ambulance.id,
      'type': ambulance.type,
      'plateNumber': ambulance.plateNumber,
      'driverName': ambulance.driverName,
      'currentLocation': ambulance.currentLocation,
      'status': ambulance.status.name,
      'capacity': ambulance.capacity,
      'distanceKm': ambulance.distanceKm,
      'driverId': ambulance.driverId,
    }, SetOptions(merge: true));
  }

  static Future<void> deleteAmbulance(String ambulanceId) {
    return firestore.collection('ambulances').doc(ambulanceId).delete();
  }

  static Future<void> saveHospital(Hospital hospital) {
    return firestore.collection('hospitals').doc(hospital.id).set({
      'id': hospital.id,
      'name': hospital.name,
      'address': hospital.address,
      'emergencyLevel': hospital.emergencyLevel,
      'rating': hospital.rating,
      'phone': hospital.phone,
      'specialties': hospital.specialties,
      'distanceKm': hospital.distanceKm,
    }, SetOptions(merge: true));
  }

  static Future<void> deleteHospital(String hospitalId) {
    return firestore.collection('hospitals').doc(hospitalId).delete();
  }

  static Future<void> deleteUser(String userId) {
    return firestore.collection('users').doc(userId).delete();
  }

  static Future<void> saveMessagingToken(String userId, String token) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(base64Url.encode(utf8.encode(token)))
        .set({
      'token': token,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
