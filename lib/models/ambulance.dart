enum AmbulanceStatus { available, busy, offline }

class Ambulance {
  final String id;
  final String type;
  final String plateNumber;
  final String driverName;
  final String currentLocation;
  final AmbulanceStatus status;
  final int capacity;

  const Ambulance({
    required this.id,
    required this.type,
    required this.plateNumber,
    required this.driverName,
    required this.currentLocation,
    required this.status,
    required this.capacity,
  });

  String get statusLabel {
    switch (status) {
      case AmbulanceStatus.available:
        return 'Available';
      case AmbulanceStatus.busy:
        return 'On Duty';
      case AmbulanceStatus.offline:
        return 'Offline';
    }
  }
}
