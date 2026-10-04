import '../models/ambulance.dart';
import '../models/hospital.dart';
import '../models/user_profile.dart';

class DemoData {
  static const patient = UserProfile(
    id: 'p001',
    name: 'Aatifaa Jyoti',
    email: 'patient@example.com',
    phone: '01602381861',
    address: 'Uttara Sector 7, Dhaka',
    password: '123456',
    role: UserRole.patient,
  );

  static const ambulance = Ambulance(
    id: 'AMB-102',
    type: 'Basic Life Support',
    plateNumber: 'DHA-102',
    driverName: 'Rahim Ahmed',
    currentLocation: 'Uttara, Dhaka',
    status: AmbulanceStatus.available,
    capacity: 2,
  );

  static const hospital = Hospital(
    id: 'H_CITY',
    name: 'City Hospital',
    address: 'Dhaka',
    emergencyLevel: 'Level 1',
    rating: 4.7,
    phone: '+8801700000000',
    specialties: ['Emergency', 'Trauma', 'Surgery'],
  );
}
