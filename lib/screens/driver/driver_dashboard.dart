import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/ambulance.dart';
import '../../models/booking_request.dart';
import '../../providers/app_state.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_chip.dart';
import '../auth/auth_screen.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => DriverDashboardScreenState();
}

class DriverDashboardScreenState extends State<DriverDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const DriverOverviewPage(),
      const DriverRequestsPage(),
      const DriverProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
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
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.assignment_rounded), label: 'Requests'),
          NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class DriverOverviewPage extends StatelessWidget {
  const DriverOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(title: 'Available', value: appState.ambulances.where((item) => item.status == AmbulanceStatus.available).length.toString()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(title: 'Today', value: appState.activeBookings.length.toString()),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Fleet status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                ...appState.ambulances.map(
                  (ambulance) => ListTile(
                    title: Text('${ambulance.type} • ${ambulance.plateNumber}'),
                    subtitle: Text(ambulance.currentLocation),
                    trailing: Switch(
                      value: ambulance.status == AmbulanceStatus.available,
                      onChanged: (_) => appState.toggleAmbulanceAvailability(ambulance.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DriverRequestsPage extends StatelessWidget {
  const DriverRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final pendingBookings = appState.bookings.where((booking) => booking.status == BookingStatus.pending).toList();

    if (pendingBookings.isEmpty) {
      return const Center(child: Text('No new ambulance requests.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: pendingBookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = pendingBookings[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(booking.patientName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    StatusChip(label: booking.statusLabel, color: AppColors.warningOrange),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Pickup: ${booking.pickupLocation}'),
                Text('Destination: ${booking.destination}'),
                Text('Ambulance: ${booking.ambulanceType}'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => appState.rejectBooking(booking.id),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Accept',
                        onPressed: () => appState.acceptBooking(booking.id),
                        icon: Icons.check_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DriverProfilePage extends StatelessWidget {
  const DriverProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().currentUser;
    if (user == null) {
      return const Center(child: Text('No profile available'));
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
                  backgroundColor: AppColors.medicalBlue,
                  child: Icon(Icons.local_taxi_rounded, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                Text(user.email, style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                ListTile(leading: const Icon(Icons.phone), title: Text(user.phone)),
                ListTile(leading: const Icon(Icons.location_on), title: Text(user.address)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  const StatCard({required this.title, required this.value, super.key});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
