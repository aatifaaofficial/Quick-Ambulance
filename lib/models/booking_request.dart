enum BookingStatus {
  pending,
  accepted,
  driverOnWay,
  arrived,
  patientPicked,
  goingToHospital,
  completed,
  cancelled,
  rejected,
}

class BookingRequest {
  final String id;
  final String userId;
  final String patientName;
  final String patientPhone;
  final String pickupLocation;
  final String destination;
  final String ambulanceType;
  final BookingStatus status;
  final String driverName;
  final String driverPhone;
  final String notes;
  final DateTime requestedAt;
  final int etaMinutes;
  final String? driverId;
  final double? driverLatitude;
  final double? driverLongitude;

  const BookingRequest({
    required this.id,
    required this.userId,
    required this.patientName,
    this.patientPhone = '',
    required this.pickupLocation,
    required this.destination,
    required this.ambulanceType,
    required this.status,
    required this.driverName,
    required this.driverPhone,
    required this.notes,
    required this.requestedAt,
    required this.etaMinutes,
    this.driverId,
    this.driverLatitude,
    this.driverLongitude,
  });

  factory BookingRequest.fromMap(
    Map<String, dynamic> data, {
    required String id,
  }) {
    final statusKey = data['status'] as String? ?? 'pending';
    final status = switch (statusKey) {
      'driver_on_way' => BookingStatus.driverOnWay,
      'patient_picked' => BookingStatus.patientPicked,
      'going_to_hospital' => BookingStatus.goingToHospital,
      _ => BookingStatus.values.where((value) => value.name == statusKey).firstOrNull,
    };
    if (status == null) {
      throw FormatException('Unknown booking status: $statusKey');
    }

    final requestedAtValue = data['requestedAt'];
    final requestedAt = switch (requestedAtValue) {
      DateTime value => value,
      _ => DateTime.tryParse(requestedAtValue?.toString() ?? ''),
    };
    if (requestedAt == null) {
      throw const FormatException('Booking requestedAt is missing or invalid.');
    }

    return BookingRequest(
      id: id,
      userId: data['userId'] as String? ?? '',
      patientName: data['patientName'] as String? ?? '',
      patientPhone: data['patientPhone'] as String? ?? '',
      pickupLocation: data['pickupLocation'] as String? ?? '',
      destination: data['destination'] as String? ?? '',
      ambulanceType: data['ambulanceType'] as String? ?? '',
      status: status,
      driverName: data['driverName'] as String? ?? 'Awaiting assignment',
      driverPhone: data['driverPhone'] as String? ?? '--',
      notes: data['notes'] as String? ?? '',
      requestedAt: requestedAt,
      etaMinutes: (data['etaMinutes'] as num?)?.toInt() ?? 0,
      driverId: data['driverId'] as String?,
      driverLatitude: (data['driverLatitude'] as num?)?.toDouble(),
      driverLongitude: (data['driverLongitude'] as num?)?.toDouble(),
    );
  }

  BookingRequest copyWith({
    BookingStatus? status,
    String? driverName,
    String? driverPhone,
    String? driverId,
    int? etaMinutes,
    double? driverLatitude,
    double? driverLongitude,
  }) {
    return BookingRequest(
      id: id,
      userId: userId,
      patientName: patientName,
      patientPhone: patientPhone,
      pickupLocation: pickupLocation,
      destination: destination,
      ambulanceType: ambulanceType,
      status: status ?? this.status,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverId: driverId ?? this.driverId,
      notes: notes,
      requestedAt: requestedAt,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      driverLatitude: driverLatitude ?? this.driverLatitude,
      driverLongitude: driverLongitude ?? this.driverLongitude,
    );
  }

  bool get isActive => switch (status) {
        BookingStatus.pending ||
        BookingStatus.accepted ||
        BookingStatus.driverOnWay ||
        BookingStatus.arrived ||
        BookingStatus.patientPicked ||
        BookingStatus.goingToHospital =>
          true,
        _ => false,
      };

  bool get isTerminal => switch (status) {
        BookingStatus.completed || BookingStatus.cancelled || BookingStatus.rejected => true,
        _ => false,
      };

  String get statusLabel {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.driverOnWay:
        return 'Driver on Way';
      case BookingStatus.arrived:
        return 'Arrived';
      case BookingStatus.patientPicked:
        return 'Patient Picked';
      case BookingStatus.goingToHospital:
        return 'Going to Hospital';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.rejected:
        return 'Rejected';
    }
  }

  String get statusKey {
    return switch (status) {
      BookingStatus.driverOnWay => 'driver_on_way',
      BookingStatus.patientPicked => 'patient_picked',
      BookingStatus.goingToHospital => 'going_to_hospital',
      _ => status.name,
    };
  }
}
