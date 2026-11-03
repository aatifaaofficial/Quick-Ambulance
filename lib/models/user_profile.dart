enum UserRole { patient, driver, admin }

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String password;
  final UserRole role;
  final String? ambulanceType;
  final int? age;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.password,
    required this.role,
    this.ambulanceType,
    this.age,
  });

  factory UserProfile.fromMap(Map<String, dynamic> data, {required String id}) {
    final roleName = data['role'] as String?;
    final role = UserRole.values.where((value) => value.name == roleName);
    if (role.isEmpty) {
      throw FormatException('Unknown user role: $roleName');
    }

    return UserProfile(
      id: id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      address: data['address'] as String? ?? '',
      password: '',
      role: role.first,
      ambulanceType: data['ambulanceType'] as String?,
      age: (data['age'] as num?)?.toInt(),
    );
  }

  String get roleLabel {
    switch (role) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.driver:
        return 'Ambulance Driver';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  static UserProfile demoPatient() {
    return const UserProfile(
      id: 'p001',
      name: 'Aatifaa Jyoti',
      email: 'patient@example.com',
      phone: '01602381861',
      address: 'Uttara Sector 7, Dhaka',
      password: '123456',
      role: UserRole.patient,
      age: 22,
    );
  }

  static UserProfile demoDriver() {
    return const UserProfile(
      id: 'd001',
      name: 'Rahim Ahmed',
      email: 'driver@example.com',
      phone: '+8801711111111',
      address: 'Uttara, Dhaka',
      password: '123456',
      role: UserRole.driver,
      ambulanceType: 'Basic Life Support',
    );
  }

  static UserProfile demoAdmin() {
    return const UserProfile(
      id: 'a001',
      name: 'Dr. Sabrina Karim',
      email: 'admin@quickambulance.com',
      phone: '+8801888888888',
      address: 'Head Office, Dhaka',
      password: '123456',
      role: UserRole.admin,
    );
  }
}
