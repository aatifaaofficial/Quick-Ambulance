class Hospital {
  final String id;
  final String name;
  final String address;
  final String emergencyLevel;
  final double rating;
  final String phone;
  final List<String> specialties;
  final double? distanceKm;

  const Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.emergencyLevel,
    required this.rating,
    required this.phone,
    required this.specialties,
    this.distanceKm,
  });

  factory Hospital.fromMap(Map<String, dynamic> data, {required String id}) {
    return Hospital(
      id: id,
      name: data['name'] as String? ?? '',
      address: data['address'] as String? ?? '',
      emergencyLevel: data['emergencyLevel'] as String? ?? 'Not specified',
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      phone: data['phone'] as String? ?? '',
      specialties: (data['specialties'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      distanceKm: (data['distanceKm'] as num?)?.toDouble(),
    );
  }
}
