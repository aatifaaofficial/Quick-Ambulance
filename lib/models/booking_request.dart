enum BookingStatus {
  pending,
  accepted,
  driver_on_way,
  arrived,
  patient_picked,
  going_to_hospital,
  completed,
  cancelled,
  rejected,
}

class BookingRequest {
  final String id;
  final String userId;
  final String patientName;
  final String pickupLocation;
  final String destination;
  final String ambulanceType;
  final BookingStatus status;
  final String driverName;
  final String driverPhone;
  final String notes;
  final DateTime requestedAt;
  final int etaMinutes;

  const BookingRequest({
    required this.id,
    required this.userId,
    required this.patientName,
    required this.pickupLocation,
    required this.destination,
    required this.ambulanceType,
    required this.status,
    required this.driverName,
    required this.driverPhone,
    required this.notes,
    required this.requestedAt,
    required this.etaMinutes,
  });

  bool get isActive => switch (status) {
        BookingStatus.pending || BookingStatus.accepted || BookingStatus.driver_on_way || BookingStatus.arrived || BookingStatus.patient_picked || BookingStatus.going_to_hospital => true,
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
      case BookingStatus.driver_on_way:
        return 'Driver on Way';
      case BookingStatus.arrived:
        return 'Arrived';
      case BookingStatus.patient_picked:
        return 'Patient Picked';
      case BookingStatus.going_to_hospital:
        return 'Going to Hospital';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.rejected:
        return 'Rejected';
    }
  }
}
