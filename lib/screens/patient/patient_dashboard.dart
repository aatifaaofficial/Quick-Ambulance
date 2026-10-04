import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../models/booking_request.dart';
import '../../models/hospital.dart';
import '../../providers/app_state.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_chip.dart';
import '../auth/auth_screen.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => PatientDashboardScreenState();
}

class PatientDashboardScreenState extends State<PatientDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      PatientOverviewPage(),
      PatientTripsPage(),
      HospitalSearchPage(),
      PatientProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AppState>().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history_rounded), label: 'Trips'),
          NavigationDestination(icon: Icon(Icons.local_hospital_rounded), label: 'Hospitals'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class PatientOverviewPage extends StatelessWidget {
  const PatientOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final bookings = appState.patientBookings;
        final currentBooking = bookings.isNotEmpty ? bookings.first : null;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.emergencyRed, Color(0xFFFB7185)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Emergency Response',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Need urgent ambulance support?',
                    style: TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: 'Book Ambulance',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(builder: (_) => const BookingRequestScreen()),
                            );
                          },
                          icon: Icons.add_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (currentBooking != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Current Booking',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          StatusChip(
                            label: currentBooking.statusLabel,
                            color: currentBooking.status == BookingStatus.completed
                                ? AppColors.successGreen
                                : currentBooking.status == BookingStatus.pending
                                    ? AppColors.warningOrange
                                    : AppColors.medicalBlue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Pickup: ${currentBooking.pickupLocation}'),
                      Text('Destination: ${currentBooking.destination}'),
                      Text('Ambulance: ${currentBooking.ambulanceType}'),
                      Text('Driver: ${currentBooking.driverName}'),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        label: 'Track Trip',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => TripTrackingScreen(booking: currentBooking),
                            ),
                          );
                        },
                        icon: Icons.map_rounded,
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: const [
                      Icon(Icons.pending_actions_outlined, size: 36, color: AppColors.textSecondary),
                      SizedBox(height: 8),
                      Text('No active booking yet', style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: 6),
                      Text('Create a booking request to begin a trip.', textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Quick actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                QuickActionCard(
                  icon: Icons.local_hospital_rounded,
                  label: 'Hospitals',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const HospitalSearchPage()),
                    );
                  },
                ),
                QuickActionCard(
                  icon: Icons.history_rounded,
                  label: 'History',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const PatientTripsPage()),
                    );
                  },
                ),
                QuickActionCard(
                  icon: Icons.phone_rounded,
                  label: 'Call Driver',
                  onTap: () async {
                    final bookings = appState.patientBookings;
                    final booking = bookings.isNotEmpty ? bookings.first : null;
                    final phone = booking?.driverPhone ?? '';
                    if (phone.isEmpty || phone == '--') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No active driver contact available yet.')),
                      );
                      return;
                    }

                    final uri = Uri(scheme: 'tel', path: phone);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
                QuickActionCard(
                  icon: Icons.notifications_rounded,
                  label: 'Alerts',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const NotificationsScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class PatientTripsPage extends StatelessWidget {
  const PatientTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final trips = appState.patientBookings;
        if (trips.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('No trip history yet. Book an ambulance to get started.'),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: trips.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final booking = trips[index];
            return Card(
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => BookingDetailsScreen(booking: booking)),
                  );
                },
                title: Text(booking.destination),
                subtitle: Text(
                  '${DateFormat('MMM d, yyyy').format(booking.requestedAt)} • ${booking.ambulanceType}',
                ),
                trailing: StatusChip(
                  label: booking.statusLabel,
                  color: booking.status == BookingStatus.completed
                      ? AppColors.successGreen
                      : booking.status == BookingStatus.pending || booking.status == BookingStatus.rejected
                          ? AppColors.warningOrange
                          : AppColors.medicalBlue,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class HospitalSearchPage extends StatefulWidget {
  const HospitalSearchPage({super.key});

  @override
  State<HospitalSearchPage> createState() => HospitalSearchPageState();
}

class HospitalSearchPageState extends State<HospitalSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final hospitals = appState.searchHospitals(_searchController.text);
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search hospital or specialty',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 16),
            ...hospitals.map(
              (hospital) => Card(
                child: ListTile(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => HospitalDetailScreen(hospital: hospital)),
                    );
                  },
                  title: Text(hospital.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(hospital.address),
                      const SizedBox(height: 6),
                      Text('${hospital.emergencyLevel} • ${hospital.specialties.join(', ')}'),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.warningOrange),
                      Text(hospital.rating.toStringAsFixed(1)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class PatientProfilePage extends StatelessWidget {
  const PatientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final user = appState.currentUser;
        if (user == null) {
          return const Center(child: Text('Not signed in'));
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.emergencyRed,
                      child: Icon(Icons.person_rounded, size: 32, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(user.email, style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 18),
                    ListTile(
                      leading: const Icon(Icons.phone),
                      title: const Text('Phone'),
                      subtitle: Text(user.phone),
                    ),
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: const Text('Address'),
                      subtitle: Text(user.address),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class HospitalDetailScreen extends StatelessWidget {
  const HospitalDetailScreen({required this.hospital, super.key});

  final Hospital hospital;

  @override
  Widget build(BuildContext context) {
    final details = hospital;
    return Scaffold(
      appBar: AppBar(title: Text(details.name)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(details.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.warningOrange),
                      const SizedBox(width: 4),
                      Text(details.rating.toStringAsFixed(1)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(details.address),
                  const SizedBox(height: 8),
                  Text('Emergency level: ${details.emergencyLevel}'),
                  const SizedBox(height: 8),
                  Text('Phone: ${details.phone}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Specialties', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: details.specialties
                        .map(
                          (specialty) => Chip(
                            label: Text(specialty),
                            backgroundColor: AppColors.medicalBlue.withAlpha(25),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final notifications = appState.notifications;

        return Scaffold(
          appBar: AppBar(title: const Text('Notifications')),
          body: notifications.isEmpty
              ? const Center(child: Text('No notifications yet.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Card(
                      child: ListTile(
                        title: Text(notification.title),
                        subtitle: Text(notification.message),
                        trailing: Text(
                          DateFormat('MMM d').format(notification.createdAt),
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

class BookingRequestScreen extends StatefulWidget {
  const BookingRequestScreen({super.key});

  @override
  State<BookingRequestScreen> createState() => BookingRequestScreenState();
}

class BookingRequestScreenState extends State<BookingRequestScreen> {
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _pickupController = TextEditingController(text: 'Uttara Sector 7');
  final TextEditingController _notesController = TextEditingController();
  String? _selectedDestination;
  String? _selectedAmbulanceType;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final hospitals = appState.hospitals;
    final ambulanceTypes = ['Basic Life Support', 'ICU', 'Emergency', 'Maternal Care'];

    final user = appState.currentUser;
    if (user != null) {
      _patientNameController.text = _patientNameController.text.isEmpty ? user.name : _patientNameController.text;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Book Ambulance')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _patientNameController,
            decoration: const InputDecoration(labelText: 'Patient name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _pickupController,
            decoration: const InputDecoration(labelText: 'Pickup location'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedDestination,
            items: hospitals
                .map(
                  (hospital) => DropdownMenuItem<String>(
                    value: hospital.name,
                    child: Text(hospital.name),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedDestination = value),
            decoration: const InputDecoration(labelText: 'Destination hospital'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _selectedAmbulanceType,
            items: ambulanceTypes
                .map(
                  (type) => DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => _selectedAmbulanceType = value),
            decoration: const InputDecoration(labelText: 'Ambulance type'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Medical notes'),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Confirm Booking',
            onPressed: () {
              if (_selectedDestination == null || _selectedAmbulanceType == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Select destination and ambulance type')),
                );
                return;
              }

              appState.submitBooking(
                patientName: _patientNameController.text,
                pickupLocation: _pickupController.text,
                destination: _selectedDestination!,
                ambulanceType: _selectedAmbulanceType!,
                notes: _notesController.text,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ambulance requested successfully')),
              );
              Navigator.of(context).pop();
            },
            icon: Icons.check_rounded,
          ),
        ],
      ),
    );
  }
}

class BookingDetailsScreen extends StatelessWidget {
  const BookingDetailsScreen({required this.booking, super.key});

  final BookingRequest booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Trip summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      StatusChip(
                        label: booking.statusLabel,
                        color: booking.status == BookingStatus.completed
                            ? AppColors.successGreen
                            : AppColors.medicalBlue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Patient: ${booking.patientName}'),
                  const SizedBox(height: 6),
                  Text('Pickup: ${booking.pickupLocation}'),
                  const SizedBox(height: 6),
                  Text('Destination: ${booking.destination}'),
                  const SizedBox(height: 6),
                  Text('Ambulance: ${booking.ambulanceType}'),
                  const SizedBox(height: 6),
                  Text('Driver: ${booking.driverName}'),
                  const SizedBox(height: 6),
                  Text('ETA: ${booking.etaMinutes} minutes'),
                  const SizedBox(height: 6),
                  Text('Notes: ${booking.notes.isEmpty ? 'No notes' : booking.notes}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (booking.driverPhone.isNotEmpty && booking.driverPhone != '--')
            PrimaryButton(
              label: 'Call driver',
              onPressed: () async {
                final uri = Uri(scheme: 'tel', path: booking.driverPhone);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              icon: Icons.call_rounded,
            ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Track trip',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => TripTrackingScreen(booking: booking)),
              );
            },
            icon: Icons.map_rounded,
          ),
        ],
      ),
    );
  }
}

class TripTrackingScreen extends StatelessWidget {
  const TripTrackingScreen({required this.booking, super.key});

  final BookingRequest booking;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Tracking')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: AppColors.medicalBlue.withAlpha(32),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_rounded, size: 40, color: AppColors.medicalBlue),
                  SizedBox(height: 12),
                  Text('Live map preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  Text('Pickup route and ambulance location will appear here when connected to location services.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: ListTile(
              title: Text(booking.driverName),
              subtitle: Text(booking.driverPhone),
              trailing: const Icon(Icons.call_rounded, color: AppColors.successGreen),
              onTap: () async {
                final uri = Uri(scheme: 'tel', path: booking.driverPhone);
                if (booking.driverPhone.isNotEmpty && booking.driverPhone != '--' && await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pickup: ${booking.pickupLocation}'),
                  const SizedBox(height: 8),
                  Text('Destination: ${booking.destination}'),
                  const SizedBox(height: 8),
                  Text('ETA: ${booking.etaMinutes} min'),
                  const SizedBox(height: 8),
                  Text('Status: ${booking.statusLabel}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({required this.icon, required this.label, required this.onTap, super.key});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.medicalBlue, size: 28),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
