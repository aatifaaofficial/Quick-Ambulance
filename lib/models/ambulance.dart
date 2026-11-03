enum AmbulanceStatus { available, busy, offline }

class Ambulance {
  final String id;
  final String type;
  final String plateNumber;
  final String driverName;
  final String currentLocation;
  final AmbulanceStatus status;
  final int capacity;
  final double? distanceKm;
  final String? driverId;

  const Ambulance({
    required this.id,
    required this.type,
    required this.plateNumber,
    required this.driverName,
    required this.currentLocation,
    required this.status,
    required this.capacity,
    this.distanceKm,
    this.driverId,
  });

  factory Ambulance.fromMap(Map<String, dynamic> data, {required String id}) {
    final statusName = data['status'] as String? ?? 'offline';
    final status = AmbulanceStatus.values.where((value) => value.name == statusName);
    if (status.isEmpty) {
      throw FormatException('Unknown ambulance status: $statusName');
    }

    return Ambulance(
      id: id,
      type: data['type'] as String? ?? '',
      plateNumber: data['plateNumber'] as String? ?? '',
      driverName: data['driverName'] as String? ?? '',
      currentLocation: data['currentLocation'] as String? ?? '',
      status: status.first,
      capacity: (data['capacity'] as num?)?.toInt() ?? 1,
      distanceKm: (data['distanceKm'] as num?)?.toDouble(),
      driverId: data['driverId'] as String?,
    );
  }

  Ambulance copyWith({
    String? type,
    String? plateNumber,
    String? driverName,
    String? currentLocation,
    AmbulanceStatus? status,
    int? capacity,
    double? distanceKm,
    String? driverId,
  }) {
    return Ambulance(
      id: id,
      type: type ?? this.type,
      plateNumber: plateNumber ?? this.plateNumber,
      driverName: driverName ?? this.driverName,
      currentLocation: currentLocation ?? this.currentLocation,
      status: status ?? this.status,
      capacity: capacity ?? this.capacity,
      distanceKm: distanceKm ?? this.distanceKm,
      driverId: driverId ?? this.driverId,
    );
  }

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
