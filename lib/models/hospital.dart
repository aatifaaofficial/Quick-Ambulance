class Hospital {
  final String id;
  final String name;
  final String address;
  final String emergencyLevel;
  final double rating;
  final String phone;
  final List<String> specialties;

  const Hospital({
    required this.id,
    required this.name,
    required this.address,
    required this.emergencyLevel,
    required this.rating,
    required this.phone,
    required this.specialties,
  });
}
