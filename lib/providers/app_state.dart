import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/ambulance.dart';
import '../models/booking_request.dart';
import '../models/hospital.dart';
import '../models/notification_item.dart';
import '../models/user_profile.dart';

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
        id: 'A-201',
        type: 'Basic Life Support',
        plateNumber: 'DHA-201',
        driverName: 'Rahim Uddin',
        currentLocation: 'Uttara, Dhaka',
        status: AmbulanceStatus.available,
        capacity: 2,
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
        patientName: 'Aisha Rahman',
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
        patientName: 'Aisha Rahman',
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

  final List<UserProfile> _users = [];
  final List<Ambulance> _ambulances = [];
  final List<Hospital> _hospitals = [];
  final List<BookingRequest> _bookings = [];
  final List<AppNotificationItem> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  UserProfile? _currentUser;

  UserProfile? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<UserProfile> get users => List.unmodifiable(_users);
  List<Ambulance> get ambulances => List.unmodifiable(_ambulances);
  List<Hospital> get hospitals => List.unmodifiable(_hospitals);
  List<BookingRequest> get bookings => List.unmodifiable(_bookings);
  List<AppNotificationItem> get notifications => List.unmodifiable(_notifications);

  List<BookingRequest> get activeBookings {
    return _bookings
        .where(
          (booking) =>
              booking.status == BookingStatus.pending ||
              booking.status == BookingStatus.accepted ||
              booking.status == BookingStatus.driver_on_way ||
              booking.status == BookingStatus.arrived ||
              booking.status == BookingStatus.patient_picked ||
              booking.status == BookingStatus.going_to_hospital,
        )
        .toList();
  }

  List<BookingRequest> get patientBookings {
    if (_currentUser == null) {
      return const [];
    }

    return _bookings
        .where((booking) => booking.userId == _currentUser!.id)
        .toList();
  }

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
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 350));
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
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
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final normalized = email.trim();
      if (normalized.isEmpty || password.length < 6) {
        throw ArgumentError('Use a valid email and password (minimum 6 characters).');
      }

      final match = _users.firstWhere(
        (user) => user.email.toLowerCase() == normalized.toLowerCase() && user.role == role,
        orElse: () => throw StateError('Invalid credentials for selected role.'),
      );

      if (match.password != password) {
        throw StateError('Incorrect password.');
      }

      _currentUser = match;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '').replaceFirst('Error: ', '');
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
      await Future<void>.delayed(const Duration(milliseconds: 450));

      if (name.trim().isEmpty || email.trim().isEmpty || phone.trim().isEmpty || password.trim().length < 6) {
        throw ArgumentError('All profile fields are required and password must be at least 6 characters.');
      }

      final exists = _users.any((user) => user.email.toLowerCase() == email.trim().toLowerCase());
      if (exists) {
        throw StateError('An account with this email already exists.');
      }

      final newUser = UserProfile(
        id: 'u_${Random().nextInt(9999)}',
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        address: address.trim(),
        password: password,
        role: role,
      );

      _users.add(newUser);
      _currentUser = newUser;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '').replaceFirst('Error: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
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
    );

    final index = _users.indexWhere((user) => user.id == _currentUser!.id);
    if (index != -1) {
      _users[index] = updatedUser;
    }
    _currentUser = updatedUser;
    notifyListeners();
  }

  void addNotification(String title, String message) {
    _notifications.insert(
      0,
      AppNotificationItem(
        id: 'n_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        message: message,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
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

  void submitBooking({
    required String patientName,
    required String pickupLocation,
    required String destination,
    required String ambulanceType,
    required String notes,
  }) {
    if (_currentUser == null) {
      _errorMessage = 'Please sign in as a patient to place a booking.';
      notifyListeners();
      return;
    }

    final booking = BookingRequest(
      id: 'B-${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser!.id,
      patientName: patientName,
      pickupLocation: pickupLocation,
      destination: destination,
      ambulanceType: ambulanceType,
      status: BookingStatus.pending,
      driverName: 'Awaiting assignment',
      driverPhone: '--',
      notes: notes,
      requestedAt: DateTime.now(),
      etaMinutes: 15,
    );

    _bookings.insert(0, booking);
    addNotification('Booking requested', 'Ambulance request sent to nearby drivers for $destination.');
    _errorMessage = null;
    notifyListeners();
  }

  void acceptBooking(String bookingId) {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1) {
      return;
    }

    final booking = _bookings[index];
    final ambulance = _ambulances.firstWhere(
      (item) => item.type == booking.ambulanceType && item.status == AmbulanceStatus.available,
      orElse: () => _ambulances.first,
    );

    _bookings[index] = BookingRequest(
      id: booking.id,
      userId: booking.userId,
      patientName: booking.patientName,
      pickupLocation: booking.pickupLocation,
      destination: booking.destination,
      ambulanceType: booking.ambulanceType,
      status: BookingStatus.accepted,
      driverName: ambulance.driverName,
      driverPhone: '+8801700000000',
      notes: booking.notes,
      requestedAt: booking.requestedAt,
      etaMinutes: 8,
    );

    final ambulanceIndex = _ambulances.indexWhere((item) => item.id == ambulance.id);
    if (ambulanceIndex != -1) {
      _ambulances[ambulanceIndex] = Ambulance(
        id: ambulance.id,
        type: ambulance.type,
        plateNumber: ambulance.plateNumber,
        driverName: ambulance.driverName,
        currentLocation: ambulance.currentLocation,
        status: AmbulanceStatus.busy,
        capacity: ambulance.capacity,
      );
    }

    notifyListeners();
  }

  void rejectBooking(String bookingId) {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1) {
      return;
    }

    _bookings[index] = BookingRequest(
      id: _bookings[index].id,
      userId: _bookings[index].userId,
      patientName: _bookings[index].patientName,
      pickupLocation: _bookings[index].pickupLocation,
      destination: _bookings[index].destination,
      ambulanceType: _bookings[index].ambulanceType,
      status: BookingStatus.rejected,
      driverName: 'Rejected',
      driverPhone: '--',
      notes: _bookings[index].notes,
      requestedAt: _bookings[index].requestedAt,
      etaMinutes: 0,
    );

    addNotification('Booking update', 'A driver rejected the trip request. Another vehicle is being assigned.');
    notifyListeners();
  }

  void cancelBooking(String bookingId) {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1) {
      return;
    }

    final booking = _bookings[index];
    _bookings[index] = BookingRequest(
      id: booking.id,
      userId: booking.userId,
      patientName: booking.patientName,
      pickupLocation: booking.pickupLocation,
      destination: booking.destination,
      ambulanceType: booking.ambulanceType,
      status: BookingStatus.cancelled,
      driverName: booking.driverName,
      driverPhone: booking.driverPhone,
      notes: booking.notes,
      requestedAt: booking.requestedAt,
      etaMinutes: 0,
    );

    addNotification('Booking cancelled', 'The booking for ${booking.destination} has been cancelled.');
    notifyListeners();
  }

  void completeBooking(String bookingId) {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1) {
      return;
    }

    _bookings[index] = BookingRequest(
      id: _bookings[index].id,
      userId: _bookings[index].userId,
      patientName: _bookings[index].patientName,
      pickupLocation: _bookings[index].pickupLocation,
      destination: _bookings[index].destination,
      ambulanceType: _bookings[index].ambulanceType,
      status: BookingStatus.completed,
      driverName: _bookings[index].driverName,
      driverPhone: _bookings[index].driverPhone,
      notes: _bookings[index].notes,
      requestedAt: _bookings[index].requestedAt,
      etaMinutes: 0,
    );

    addNotification('Trip completed', 'The ride to ${_bookings[index].destination} has been completed.');
    notifyListeners();
  }

  void updateBookingStatus(String bookingId, BookingStatus status) {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1) {
      return;
    }

    final booking = _bookings[index];
    _bookings[index] = BookingRequest(
      id: booking.id,
      userId: booking.userId,
      patientName: booking.patientName,
      pickupLocation: booking.pickupLocation,
      destination: booking.destination,
      ambulanceType: booking.ambulanceType,
      status: status,
      driverName: booking.driverName,
      driverPhone: booking.driverPhone,
      notes: booking.notes,
      requestedAt: booking.requestedAt,
      etaMinutes: status == BookingStatus.completed ? 0 : booking.etaMinutes,
    );
    notifyListeners();
  }

  void toggleAmbulanceAvailability(String ambulanceId) {
    final index = _ambulances.indexWhere((ambulance) => ambulance.id == ambulanceId);
    if (index == -1) {
      return;
    }

    final current = _ambulances[index];
    _ambulances[index] = Ambulance(
      id: current.id,
      type: current.type,
      plateNumber: current.plateNumber,
      driverName: current.driverName,
      currentLocation: current.currentLocation,
      status: current.status == AmbulanceStatus.available
          ? AmbulanceStatus.offline
          : AmbulanceStatus.available,
      capacity: current.capacity,
    );

    notifyListeners();
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
