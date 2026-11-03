import 'dart:math';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/ambulance.dart';
import '../models/booking_request.dart';
import '../models/hospital.dart';
import '../models/notification_item.dart';
import '../models/user_profile.dart';
import '../services/firebase_service.dart';
import '../services/firestore_service.dart';
import '../services/messaging_service.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class AppState extends ChangeNotifier {
  AppState() {
    _users.addAll([
      UserProfile.demoPatient(),
      UserProfile.demoDriver(),
      UserProfile.demoAdmin(),
      const UserProfile(
        id: 'p002',
        name: 'Nadia Sultana',
        email: 'nadia@example.com',
        phone: '+8801722222222',
        address: 'Motijheel, Dhaka',
        password: '123456',
        role: UserRole.patient,
      ),
    ]);

    _ambulances.addAll([
      const Ambulance(
        id: 'AMB-102',
        type: 'Basic Life Support',
        plateNumber: 'DHA-102',
        driverName: 'Rahim Ahmed',
        currentLocation: 'Uttara, Dhaka',
        status: AmbulanceStatus.available,
        capacity: 2,
        distanceKm: 1.2,
        driverId: 'd001',
      ),
      const Ambulance(
        id: 'A-205',
        type: 'ICU',
        plateNumber: 'DHA-205',
        driverName: 'Ali Hasan',
        currentLocation: 'Bashundhara, Dhaka',
        status: AmbulanceStatus.busy,
        capacity: 1,
      ),
      const Ambulance(
        id: 'A-210',
        type: 'Neonatal',
        plateNumber: 'DHA-210',
        driverName: 'Sabbir Ahmed',
        currentLocation: 'Mirpur, Dhaka',
        status: AmbulanceStatus.available,
        capacity: 1,
      ),
    ]);

    _hospitals.addAll([
      const Hospital(
        id: 'H1',
        name: 'Dhaka Medical College Hospital',
        address: 'Dhaka',
        emergencyLevel: 'Level 1',
        rating: 4.8,
        phone: '+8801712345678',
        specialties: ['Emergency', 'Trauma', 'Cardiac'],
        distanceKm: 2.5,
      ),
      const Hospital(
        id: 'H_CITY',
        name: 'City Hospital',
        address: 'Dhaka',
        emergencyLevel: 'Level 1',
        rating: 4.7,
        phone: '+8801700000000',
        specialties: ['Emergency', 'Trauma', 'Surgery'],
        distanceKm: 2.5,
      ),
      const Hospital(
        id: 'H2',
        name: 'Square Hospital',
        address: 'Panthapath, Dhaka',
        emergencyLevel: 'Level 2',
        rating: 4.9,
        phone: '+8801812345678',
        specialties: ['ICU', 'Orthopedic', 'Surgery'],
      ),
      const Hospital(
        id: 'H3',
        name: 'Apollo Hospitals Dhaka',
        address: 'Bashundhara, Dhaka',
        emergencyLevel: 'Level 2',
        rating: 4.7,
        phone: '+8801912345678',
        specialties: ['Neurology', 'Emergency', 'Radiology'],
      ),
      const Hospital(
        id: 'H4',
        name: 'Holy Family Red Crescent Medical College',
        address: 'Moghbazar, Dhaka',
        emergencyLevel: 'Level 1',
        rating: 4.6,
        phone: '+8801612345678',
        specialties: ['Critical care', 'Maternity', 'Trauma'],
      ),
    ]);

    _bookings.addAll([
      BookingRequest(
        id: 'B-1001',
        userId: 'p001',
        patientName: 'Aatifaa Jyoti',
        patientPhone: '01602381861',
        pickupLocation: 'Uttara Sector 7',
        destination: 'Dhaka Medical College Hospital',
        ambulanceType: 'Basic Life Support',
        status: BookingStatus.pending,
        driverName: 'Awaiting assignment',
        driverPhone: '--',
        notes: 'Patient has breathing difficulty and needs immediate assistance.',
        requestedAt: DateTime.now().subtract(const Duration(minutes: 12)),
        etaMinutes: 12,
      ),
      BookingRequest(
        id: 'B-1002',
        userId: 'p002',
        patientName: 'Nadia Sultana',
        patientPhone: '+8801722222222',
        pickupLocation: 'Banasree, Dhaka',
        destination: 'Square Hospital',
        ambulanceType: 'ICU',
        status: BookingStatus.accepted,
        driverName: 'Ali Hasan',
        driverPhone: '+8801765432190',
        notes: 'Monitoring support required after the fall.',
        requestedAt: DateTime.now().subtract(const Duration(minutes: 38)),
        etaMinutes: 7,
      ),
      BookingRequest(
        id: 'B-1003',
        userId: 'p001',
        patientName: 'Aatifaa Jyoti',
        patientPhone: '01602381861',
        pickupLocation: 'Mohakhali',
        destination: 'Apollo Hospitals Dhaka',
        ambulanceType: 'Emergency',
        status: BookingStatus.completed,
        driverName: 'Sabbir Ahmed',
        driverPhone: '+8801754321567',
        notes: 'Completed transfer to emergency care facility.',
        requestedAt: DateTime.now().subtract(const Duration(days: 1)),
        etaMinutes: 15,
      ),
    ]);

    _notifications.addAll([
      AppNotificationItem(
        id: 'n1',
        title: 'Ambulance assigned',
        message: 'Your patient transfer request has been accepted by Ali Hasan.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      AppNotificationItem(
        id: 'n2',
        title: 'Hospital updated',
        message: 'Square Hospital has confirmed emergency service availability.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
    ]);
  }

  Future<void> startDriverLocationSharing() async {
    if (_currentUser?.role != UserRole.driver) {
      _errorMessage = 'Only drivers can share ambulance location.';
      notifyListeners();
      return;
    }

    try {
      final initialPosition = await LocationService.getCurrentPosition();
      if (initialPosition == null) {
        _errorMessage =
            'Location permission or device location is unavailable.';
        notifyListeners();
        return;
      }

      updateDriverLocation(
        initialPosition.latitude,
        initialPosition.longitude,
      );
      await _driverLocationSubscription?.cancel();
      _driverLocationSubscription = LocationService.positionStream().listen(
        (position) => updateDriverLocation(
          position.latitude,
          position.longitude,
        ),
        onError: (Object error) {
          _errorMessage = 'Live location sharing stopped: $error';
          _isSharingDriverLocation = false;
          notifyListeners();
        },
      );
      _isSharingDriverLocation = true;
      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Could not start live location sharing: $error';
      notifyListeners();
    }
  }

  void stopDriverLocationSharing() {
    unawaited(_driverLocationSubscription?.cancel());
    _driverLocationSubscription = null;
    _isSharingDriverLocation = false;
    notifyListeners();
  }

  final List<UserProfile> _users = [];
  final List<Ambulance> _ambulances = [];
  final List<Hospital> _hospitals = [];
  final List<BookingRequest> _bookings = [];
  final List<AppNotificationItem> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  UserProfile? _currentUser;
  StreamSubscription<List<BookingRequest>>? _bookingSubscription;
  StreamSubscription<List<Hospital>>? _hospitalSubscription;
  StreamSubscription<List<Ambulance>>? _ambulanceSubscription;
  StreamSubscription<List<UserProfile>>? _usersSubscription;
  StreamSubscription<RemoteMessage>? _remoteMessageSubscription;
  StreamSubscription<Position>? _driverLocationSubscription;
  bool _isSharingDriverLocation = false;

  UserProfile? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isDemoMode => !FirebaseService.isConfigured;
  bool get isSharingDriverLocation => _isSharingDriverLocation;
  String? get errorMessage => _errorMessage;
  List<UserProfile> get users => List.unmodifiable(_users);
  List<Ambulance> get ambulances => List.unmodifiable(_ambulances);
  List<Hospital> get hospitals => List.unmodifiable(_hospitals);
  List<BookingRequest> get bookings => List.unmodifiable(_bookings);
  List<AppNotificationItem> get notifications => List.unmodifiable(_notifications);

  List<BookingRequest> get activeBookings {
    return _bookings
        .where((booking) => booking.isActive)
        .toList();
  }

  List<BookingRequest> get patientBookings {
    if (_currentUser == null) {
      return const [];
    }

    final bookings = _bookings
        .where((booking) => booking.userId == _currentUser!.id)
        .toList();
    bookings.sort((first, second) => second.requestedAt.compareTo(first.requestedAt));
    return bookings;
  }

  List<BookingRequest> get driverBookings {
    final driverName = _currentUser?.name;
    final driverId = _currentUser?.id;
    return _bookings
        .where(
          (booking) =>
              booking.status == BookingStatus.pending ||
              (driverId != null && booking.driverId == driverId) ||
              (driverName != null && booking.driverName == driverName),
        )
        .toList();
  }

  List<BookingRequest> get driverActiveBookings => driverBookings
      .where(
        (booking) =>
            (booking.driverId == _currentUser?.id ||
                booking.driverName == _currentUser?.name) &&
            booking.isActive,
      )
      .toList();

  List<BookingRequest> get driverTripHistory => driverBookings
      .where(
        (booking) =>
            (booking.driverId == _currentUser?.id ||
                booking.driverName == _currentUser?.name) &&
            (booking.status == BookingStatus.completed ||
                booking.status == BookingStatus.cancelled ||
                booking.status == BookingStatus.rejected),
      )
      .toList();

  String? get error => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> resetPassword(String email) async {
    if (email.trim().isEmpty) {
      _errorMessage = 'Please enter a valid email address.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      if (FirebaseService.isConfigured) {
        await FirebaseService.auth.sendPasswordResetEmail(email: email.trim());
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 350));
        if (!_users.any(
          (user) => user.email.toLowerCase() == email.trim().toLowerCase(),
        )) {
          throw StateError('No demo account uses that email address.');
        }
      }
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message ?? 'Password reset could not be sent.';
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Bad state: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(
    String email,
    String password,
    UserRole role,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final normalized = email.trim();
      if (normalized.isEmpty || password.length < 6) {
        throw ArgumentError('Use a valid email and password (minimum 6 characters).');
      }

      if (FirebaseService.isConfigured) {
        final credential = await FirebaseService.auth.signInWithEmailAndPassword(
          email: normalized,
          password: password,
        );
        final firebaseUser = credential.user;
        if (firebaseUser == null) {
          throw StateError('Firebase sign-in did not return a user.');
        }
        final profile = await FirestoreService.getUserProfile(firebaseUser.uid);
        if (profile == null) {
          await FirebaseService.auth.signOut();
          throw StateError('Account profile is missing. Contact an administrator.');
        }
        if (profile.role != role) {
          await FirebaseService.auth.signOut();
          throw StateError('Choose the ${profile.roleLabel} role for this account.');
        }
        _currentUser = profile;
        _startCloudStreams(profile);
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        final match = _users.firstWhere(
          (user) =>
              user.email.toLowerCase() == normalized.toLowerCase() &&
              user.role == role,
          orElse: () => throw StateError('Invalid credentials for selected role.'),
        );
        if (match.password != password) {
          throw StateError('Incorrect password.');
        }
        _currentUser = match;
      }
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message ?? 'Sign-in failed.';
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Bad state: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
    String name,
    String email,
    String phone,
    String address,
    String password,
    UserRole role,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (name.trim().isEmpty || email.trim().isEmpty || phone.trim().isEmpty || password.trim().length < 6) {
        throw ArgumentError('All profile fields are required and password must be at least 6 characters.');
      }
      if (FirebaseService.isConfigured && role == UserRole.admin) {
        throw StateError(
          'Administrator accounts must be provisioned by a trusted administrator.',
        );
      }

      late final UserProfile newUser;
      if (FirebaseService.isConfigured) {
        final credential = await FirebaseService.auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final firebaseUser = credential.user;
        if (firebaseUser == null) {
          throw StateError('Firebase registration did not return a user.');
        }
        await firebaseUser.updateDisplayName(name.trim());
        newUser = UserProfile(
          id: firebaseUser.uid,
          name: name.trim(),
          email: email.trim(),
          phone: phone.trim(),
          address: address.trim(),
          password: '',
          role: role,
        );
        await FirestoreService.saveUserProfile(newUser);
      } else {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        final exists = _users.any(
          (user) => user.email.toLowerCase() == email.trim().toLowerCase(),
        );
        if (exists) {
          throw StateError('An account with this email already exists.');
        }
        newUser = UserProfile(
          id: 'u_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
          name: name.trim(),
          email: email.trim(),
          phone: phone.trim(),
          address: address.trim(),
          password: password,
          role: role,
        );
      }

      _users.add(newUser);
      _currentUser = newUser;
      if (FirebaseService.isConfigured) {
        _startCloudStreams(newUser);
      }
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message ?? 'Registration failed.';
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Bad state: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _cancelCloudStreams();
    stopDriverLocationSharing();
    if (FirebaseService.isConfigured) {
      unawaited(_signOutFromFirebase());
    }
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _startCloudStreams(UserProfile user) {
    _cancelCloudStreams();
    _remoteMessageSubscription = MessagingService.foregroundMessages.listen(
      (message) {
        final title =
            message.notification?.title ?? message.data['title']?.toString();
        final body =
            message.notification?.body ?? message.data['body']?.toString();
        _addNotification(
          title?.isNotEmpty == true ? title! : 'Quick Ambulance alert',
          body?.isNotEmpty == true ? body! : 'You have a new update.',
        );
        notifyListeners();
      },
      onError: (Object error) {
        _errorMessage = 'Push notification listener failed: $error';
        notifyListeners();
      },
    );
    _bookingSubscription = FirestoreService.bookingsStream(user).listen(
      (bookings) {
        _bookings
          ..clear()
          ..addAll(bookings);
        notifyListeners();
      },
      onError: (Object error) {
        _errorMessage = 'Could not load bookings from Firestore: $error';
        notifyListeners();
      },
    );
    _hospitalSubscription = FirestoreService.hospitalsStream().listen(
      (hospitals) {
        if (hospitals.isNotEmpty) {
          _hospitals
            ..clear()
            ..addAll(hospitals);
          notifyListeners();
        }
      },
      onError: (Object error) {
        _errorMessage = 'Could not load hospitals from Firestore: $error';
        notifyListeners();
      },
    );
    _ambulanceSubscription = FirestoreService.ambulancesStream().listen(
      (ambulances) {
        _ambulances
          ..clear()
          ..addAll(ambulances);
        notifyListeners();
      },
      onError: (Object error) {
        _errorMessage = 'Could not load ambulances from Firestore: $error';
        notifyListeners();
      },
    );
    if (user.role == UserRole.admin) {
      _usersSubscription = FirestoreService.usersStream().listen(
        (users) {
          _users
            ..clear()
            ..addAll(users);
          notifyListeners();
        },
        onError: (Object error) {
          _errorMessage = 'Could not load users from Firestore: $error';
          notifyListeners();
        },
      );
    }
  }

  void _cancelCloudStreams() {
    unawaited(_bookingSubscription?.cancel());
    unawaited(_hospitalSubscription?.cancel());
    unawaited(_ambulanceSubscription?.cancel());
    unawaited(_usersSubscription?.cancel());
    unawaited(_remoteMessageSubscription?.cancel());
    _bookingSubscription = null;
    _hospitalSubscription = null;
    _ambulanceSubscription = null;
    _usersSubscription = null;
    _remoteMessageSubscription = null;
  }

  @override
  void dispose() {
    _cancelCloudStreams();
    unawaited(_driverLocationSubscription?.cancel());
    super.dispose();
  }

  Future<void> _signOutFromFirebase() async {
    try {
      await FirebaseService.auth.signOut();
    } catch (error) {
      _errorMessage = 'Could not sign out from Firebase: $error';
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    if (_currentUser == null) {
      return;
    }

    final updatedUser = UserProfile(
      id: _currentUser!.id,
      name: name.trim(),
      email: _currentUser!.email,
      phone: phone.trim(),
      address: address.trim(),
      password: _currentUser!.password,
      role: _currentUser!.role,
      ambulanceType: _currentUser!.ambulanceType,
      age: _currentUser!.age,
    );

    final index = _users.indexWhere((user) => user.id == _currentUser!.id);
    if (index != -1) {
      _users[index] = updatedUser;
    }
    if (_currentUser!.role == UserRole.driver) {
      for (var ambulanceIndex = 0;
          ambulanceIndex < _ambulances.length;
          ambulanceIndex++) {
        final ambulance = _ambulances[ambulanceIndex];
        if (ambulance.driverId == _currentUser!.id ||
            ambulance.driverName == _currentUser!.name) {
          _ambulances[ambulanceIndex] = ambulance.copyWith(
            driverId: _currentUser!.id,
            driverName: updatedUser.name,
          );
          if (FirebaseService.isConfigured) {
            unawaited(_persistAmbulance(_ambulances[ambulanceIndex]));
          }
        }
      }
      for (var bookingIndex = 0;
          bookingIndex < _bookings.length;
          bookingIndex++) {
        final booking = _bookings[bookingIndex];
        if (booking.driverId == _currentUser!.id) {
          final updatedBooking = booking.copyWith(
            driverName: updatedUser.name,
            driverPhone: updatedUser.phone,
          );
          _bookings[bookingIndex] = updatedBooking;
          _persistBooking(updatedBooking);
        }
      }
    }
    _currentUser = updatedUser;
    notifyListeners();
    if (FirebaseService.isConfigured) {
      unawaited(_persistUser(updatedUser));
    }
  }

  Future<void> _persistUser(UserProfile user) async {
    try {
      await FirestoreService.saveUserProfile(user);
    } catch (error) {
      _errorMessage = 'Profile updated locally but could not sync: $error';
      notifyListeners();
    }
  }

  void addNotification(String title, String message) {
    _addNotification(title, message);
    notifyListeners();
  }

  void _addNotification(String title, String message) {
    _notifications.insert(
      0,
      AppNotificationItem(
        id: 'n_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        message: message,
        createdAt: DateTime.now(),
      ),
    );
  }

  void markNotificationRead(String id) {
    final index = _notifications.indexWhere((notification) => notification.id == id);
    if (index == -1) {
      return;
    }

    final notification = _notifications[index];
    _notifications[index] = AppNotificationItem(
      id: notification.id,
      title: notification.title,
      message: notification.message,
      createdAt: notification.createdAt,
      isRead: true,
    );
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  List<Hospital> searchHospitals(String query) {
    if (query.trim().isEmpty) {
      return hospitals;
    }
    final normalized = query.trim().toLowerCase();
    return hospitals
        .where(
          (hospital) =>
              hospital.name.toLowerCase().contains(normalized) ||
              hospital.address.toLowerCase().contains(normalized) ||
              hospital.specialties.join(' ').toLowerCase().contains(normalized),
        )
        .toList();
  }

  bool submitBooking({
    required String patientName,
    required String pickupLocation,
    required String destination,
    required String ambulanceType,
    required String notes,
  }) {
    if (_currentUser == null || _currentUser!.role != UserRole.patient) {
      _errorMessage = 'Please sign in as a patient to place a booking.';
      notifyListeners();
      return false;
    }
    if (patientName.trim().isEmpty ||
        pickupLocation.trim().isEmpty ||
        destination.trim().isEmpty ||
        ambulanceType.trim().isEmpty) {
      _errorMessage = 'Patient, pickup, destination, and ambulance type are required.';
      notifyListeners();
      return false;
    }

    final booking = BookingRequest(
      id: 'B-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000)}',
      userId: _currentUser!.id,
      patientName: patientName.trim(),
      patientPhone: _currentUser!.phone,
      pickupLocation: pickupLocation.trim(),
      destination: destination.trim(),
      ambulanceType: ambulanceType.trim(),
      status: BookingStatus.pending,
      driverName: 'Awaiting assignment',
      driverPhone: '--',
      notes: notes.trim(),
      requestedAt: DateTime.now(),
      etaMinutes: 15,
    );

    _bookings.insert(0, booking);
    _errorMessage = null;
    _addNotification(
      'Booking requested',
      'Ambulance request sent to nearby drivers for ${booking.destination}.',
    );
    _persistBooking(booking);
    notifyListeners();
    return true;
  }

  void acceptBooking(String bookingId) {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1 || _currentUser?.role != UserRole.driver) {
      return;
    }

    final booking = _bookings[index];
    if (booking.status != BookingStatus.pending) {
      _errorMessage = 'This request is no longer available.';
      notifyListeners();
      return;
    }
    final driver = _currentUser!;
    final ambulanceIndex = _ambulances.indexWhere(
      (item) =>
          (item.driverId == driver.id || item.driverName == driver.name) &&
          item.status == AmbulanceStatus.available &&
          (item.type == booking.ambulanceType ||
              driver.ambulanceType == booking.ambulanceType),
    );
    if (ambulanceIndex == -1) {
      _errorMessage = 'No available ambulance of the requested type is assigned to you.';
      notifyListeners();
      return;
    }
    final ambulance = _ambulances[ambulanceIndex];

    final updatedBooking = booking.copyWith(
      status: BookingStatus.accepted,
      driverName: driver.name,
      driverPhone: driver.phone,
      driverId: driver.id,
      etaMinutes: 8,
    );
    _bookings[index] = updatedBooking;
    _ambulances[ambulanceIndex] = _copyAmbulance(
      ambulance,
      status: AmbulanceStatus.busy,
    );
    if (FirebaseService.isConfigured) {
      unawaited(_persistAmbulance(_ambulances[ambulanceIndex]));
    }
    _persistBooking(updatedBooking);
    _addNotification('Ambulance assigned', '${driver.name} accepted your request.');
    _errorMessage = null;
    notifyListeners();
  }

  void rejectBooking(String bookingId) {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1 || _currentUser?.role != UserRole.driver) {
      return;
    }

    final booking = _bookings[index];
    if (booking.status != BookingStatus.pending) {
      _errorMessage = 'Only pending requests can be rejected.';
      notifyListeners();
      return;
    }
    final updatedBooking = booking.copyWith(
      status: BookingStatus.rejected,
      driverName: _currentUser!.name,
      driverPhone: _currentUser!.phone,
      driverId: _currentUser!.id,
      etaMinutes: 0,
    );
    _bookings[index] = updatedBooking;
    _persistBooking(updatedBooking);
    _addNotification(
      'Booking update',
      'The request for ${booking.patientName} was rejected by a driver.',
    );
    notifyListeners();
  }

  void cancelBooking(String bookingId) {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1) {
      return;
    }

    final booking = _bookings[index];
    if (_currentUser == null ||
        (_currentUser!.role != UserRole.admin &&
            (_currentUser!.role != UserRole.patient ||
                booking.userId != _currentUser!.id)) ||
        !booking.isActive) {
      _errorMessage = 'This booking cannot be cancelled by the current account.';
      notifyListeners();
      return;
    }
    final updatedBooking = booking.copyWith(
      status: BookingStatus.cancelled,
      etaMinutes: 0,
    );
    _bookings[index] = updatedBooking;
    _releaseAmbulanceFor(updatedBooking);
    _persistBooking(updatedBooking);
    _addNotification(
      'Booking cancelled',
      'The booking for ${booking.destination} has been cancelled.',
    );
    notifyListeners();
  }

  void completeBooking(String bookingId) {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1) {
      return;
    }

    updateBookingStatus(bookingId, BookingStatus.completed);
  }

  void updateBookingStatus(String bookingId, BookingStatus status) {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1) {
      return;
    }

    final booking = _bookings[index];
    final user = _currentUser;
    if (user == null ||
        (user.role != UserRole.admin &&
            (user.role != UserRole.driver || booking.driverId != user.id))) {
      _errorMessage = 'Only the assigned driver or an admin can update this trip.';
      notifyListeners();
      return;
    }
    if (user.role == UserRole.driver &&
        !_isValidDriverTransition(booking.status, status)) {
      _errorMessage = 'The trip status cannot skip its required steps.';
      notifyListeners();
      return;
    }
    final updatedBooking = booking.copyWith(
      status: status,
      etaMinutes: status == BookingStatus.completed ? 0 : booking.etaMinutes,
    );
    _bookings[index] = updatedBooking;
    if (status == BookingStatus.completed || status == BookingStatus.cancelled) {
      _releaseAmbulanceFor(updatedBooking);
    }
    _persistBooking(updatedBooking);
    _addNotification(
      'Trip status updated',
      '${booking.patientName} trip is now ${updatedBooking.statusLabel.toLowerCase()}.',
    );
    notifyListeners();
  }

  void toggleAmbulanceAvailability(String ambulanceId) {
    final index = _ambulances.indexWhere((ambulance) => ambulance.id == ambulanceId);
    if (index == -1) {
      return;
    }

    final current = _ambulances[index];
    final user = _currentUser;
    if (user == null ||
        (user.role != UserRole.admin && current.driverName != user.name)) {
      _errorMessage = 'You can only change availability for your assigned ambulance.';
      notifyListeners();
      return;
    }
    if (current.status == AmbulanceStatus.busy) {
      _errorMessage = 'Finish the active trip before changing ambulance availability.';
      notifyListeners();
      return;
    }
    _ambulances[index] = _copyAmbulance(
      current,
      status: current.status == AmbulanceStatus.available
          ? AmbulanceStatus.offline
          : AmbulanceStatus.available,
    );
    if (FirebaseService.isConfigured) {
      unawaited(_persistAmbulance(_ambulances[index]));
    }
    notifyListeners();
  }

  void toggleCurrentDriverAvailability() {
    final driver = _currentUser;
    if (driver == null || driver.role != UserRole.driver) {
      return;
    }

    final index = _ambulances.indexWhere(
      (ambulance) =>
          ambulance.driverId == driver.id || ambulance.driverName == driver.name,
    );
    if (index == -1) {
      _errorMessage = 'No ambulance is assigned to this driver profile.';
      notifyListeners();
      return;
    }
    final wasAvailable = _ambulances[index].status == AmbulanceStatus.available;
    toggleAmbulanceAvailability(_ambulances[index].id);
    if (wasAvailable) {
      stopDriverLocationSharing();
    }
  }

  void updateDriverLocation(double latitude, double longitude) {
    final driver = _currentUser;
    if (driver == null || driver.role != UserRole.driver) {
      _errorMessage = 'Only drivers can update ambulance location.';
      notifyListeners();
      return;
    }

    final location = '$latitude, $longitude';
    final ambulanceIndex = _ambulances.indexWhere(
      (ambulance) =>
          ambulance.driverId == driver.id || ambulance.driverName == driver.name,
    );
    if (ambulanceIndex >= 0) {
      _ambulances[ambulanceIndex] = _ambulances[ambulanceIndex].copyWith(
        currentLocation: location,
      );
      if (FirebaseService.isConfigured) {
        unawaited(_persistAmbulance(_ambulances[ambulanceIndex]));
      }
    }

    for (var index = 0; index < _bookings.length; index++) {
      final booking = _bookings[index];
      if (booking.driverId != driver.id || !booking.isActive) {
        continue;
      }
      final updatedBooking = booking.copyWith(
        driverLatitude: latitude,
        driverLongitude: longitude,
      );
      _bookings[index] = updatedBooking;
      _persistBooking(updatedBooking);
    }
    notifyListeners();
  }

  void addAmbulance(Ambulance ambulance) {
    if (_currentUser?.role != UserRole.admin) {
      _errorMessage = 'Only administrators can add ambulances.';
      notifyListeners();
      return;
    }
    if (_ambulances.any((item) => item.id == ambulance.id)) {
      _errorMessage = 'An ambulance with this ID already exists.';
      notifyListeners();
      return;
    }
    _ambulances.add(ambulance);
    if (FirebaseService.isConfigured) {
      unawaited(_persistAmbulance(ambulance));
    }
    notifyListeners();
  }

  void removeAmbulance(String ambulanceId) {
    if (_currentUser?.role != UserRole.admin) {
      _errorMessage = 'Only administrators can remove ambulances.';
      notifyListeners();
      return;
    }
    final ambulance = _ambulances.where((item) => item.id == ambulanceId).firstOrNull;
    if (ambulance == null) {
      return;
    }
    if (ambulance.status == AmbulanceStatus.busy) {
      _errorMessage = 'Complete the ambulance trip before removing this vehicle.';
      notifyListeners();
      return;
    }
    _ambulances.removeWhere((item) => item.id == ambulanceId);
    if (FirebaseService.isConfigured) {
      unawaited(() async {
        try {
          await FirestoreService.deleteAmbulance(ambulanceId);
        } catch (error) {
          _errorMessage = 'Ambulance removed locally but could not sync: $error';
          notifyListeners();
        }
      }());
    }
    notifyListeners();
  }

  void addHospital(Hospital hospital) {
    if (_currentUser?.role != UserRole.admin) {
      _errorMessage = 'Only administrators can add hospitals.';
      notifyListeners();
      return;
    }
    if (_hospitals.any((item) => item.id == hospital.id)) {
      _errorMessage = 'A hospital with this ID already exists.';
      notifyListeners();
      return;
    }
    _hospitals.add(hospital);
    if (FirebaseService.isConfigured) {
      unawaited(_persistHospital(hospital));
    }
    notifyListeners();
  }

  void removeHospital(String hospitalId) {
    if (_currentUser?.role != UserRole.admin) {
      _errorMessage = 'Only administrators can remove hospitals.';
      notifyListeners();
      return;
    }
    _hospitals.removeWhere((item) => item.id == hospitalId);
    if (FirebaseService.isConfigured) {
      unawaited(() async {
        try {
          await FirestoreService.deleteHospital(hospitalId);
        } catch (error) {
          _errorMessage = 'Hospital removed locally but could not sync: $error';
          notifyListeners();
        }
      }());
    }
    notifyListeners();
  }

  Future<void> _persistAmbulance(Ambulance ambulance) async {
    try {
      await FirestoreService.saveAmbulance(ambulance);
    } catch (error) {
      _errorMessage = 'Ambulance saved locally but could not sync: $error';
      notifyListeners();
    }
  }

  Future<void> _persistHospital(Hospital hospital) async {
    try {
      await FirestoreService.saveHospital(hospital);
    } catch (error) {
      _errorMessage = 'Hospital saved locally but could not sync: $error';
      notifyListeners();
    }
  }

  void _releaseAmbulanceFor(BookingRequest booking) {
    if (booking.driverName.isEmpty || booking.driverName == 'Awaiting assignment') {
      return;
    }
    final index = _ambulances.indexWhere(
      (ambulance) =>
          (booking.driverId != null &&
              ambulance.driverId == booking.driverId) ||
          ambulance.driverName == booking.driverName,
    );
    if (index >= 0) {
      _ambulances[index] = _copyAmbulance(
        _ambulances[index],
        status: AmbulanceStatus.available,
      );
      if (FirebaseService.isConfigured &&
          (_currentUser?.role == UserRole.driver ||
              _currentUser?.role == UserRole.admin)) {
        unawaited(_persistAmbulance(_ambulances[index]));
      }
    }
  }

  bool _isValidDriverTransition(
    BookingStatus current,
    BookingStatus next,
  ) {
    return switch ((current, next)) {
      (BookingStatus.accepted, BookingStatus.driverOnWay) ||
      (BookingStatus.driverOnWay, BookingStatus.arrived) ||
      (BookingStatus.arrived, BookingStatus.patientPicked) ||
      (BookingStatus.patientPicked, BookingStatus.goingToHospital) ||
      (BookingStatus.goingToHospital, BookingStatus.completed) =>
        true,
      _ => false,
    };
  }

  Ambulance _copyAmbulance(
    Ambulance ambulance, {
    required AmbulanceStatus status,
  }) {
    return ambulance.copyWith(status: status);
  }

  void _persistBooking(BookingRequest booking) {
    if (!FirebaseService.isConfigured) {
      return;
    }
    unawaited(() async {
      try {
        await FirestoreService.saveBooking(booking);
      } catch (error) {
        _errorMessage = 'Booking saved locally but could not sync: $error';
        notifyListeners();
      }
    }());
  }

  int get totalUsers => _users.length;
  int get totalDrivers => _users.where((user) => user.role == UserRole.driver).length;
  int get totalAmbulances => _ambulances.length;
  int get totalActiveBookings => activeBookings.length;
  int get totalCompletedBookings =>
      _bookings.where((booking) => booking.status == BookingStatus.completed).length;
  List<Ambulance> get nearbyAmbulances =>
      _ambulances.where((ambulance) => ambulance.status == AmbulanceStatus.available).toList();
}
