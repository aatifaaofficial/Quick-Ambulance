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

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.password,
    required this.role,
    this.ambulanceType,
  });

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
      name: 'Aisha Rahman',
      email: 'patient@example.com',
      phone: '+8801700000000',
      address: 'Dhaka Medical Road, Dhaka',
      password: '123456',
      role: UserRole.patient,
    );
  }

  static UserProfile demoDriver() {
    return const UserProfile(
      id: 'd001',
      name: 'Rahim Uddin',
      email: 'driver@example.com',
      phone: '+8801711111111',
      address: 'Uttara, Dhaka',
      password: '123456',
      role: UserRole.driver,
      ambulanceType: 'ICU',
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
