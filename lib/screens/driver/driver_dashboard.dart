import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_colors.dart';
import '../../models/ambulance.dart';
import '../../models/booking_request.dart';
import '../../providers/app_state.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/app_error_banner.dart';
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
      const DriverActiveTripsPage(),
      const DriverHistoryPage(),
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
      body: Column(
        children: [
          const AppErrorBanner(),
          Expanded(
            child: IndexedStack(index: _selectedIndex, children: pages),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.assignment_rounded), label: 'Requests'),
          NavigationDestination(icon: Icon(Icons.route_rounded), label: 'Active'),
          NavigationDestination(icon: Icon(Icons.history_rounded), label: 'History'),
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
    final driver = appState.currentUser;
    final ambulance = appState.ambulances
        .where(
          (item) =>
              item.driverId == driver?.id ||
              item.driverName == driver?.name,
        )
        .firstOrNull;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Availability',
                value: ambulance?.statusLabel ?? 'Unassigned',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'Active trips',
                value: appState.driverActiveBookings.length.toString(),
              ),
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
                const Text('My ambulance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 14),
                if (ambulance == null)
                  const ListTile(
                    leading: Icon(Icons.warning_amber_rounded),
                    title: Text('No ambulance is assigned to this driver profile.'),
                  )
                else
                  ListTile(
                    title: Text('${ambulance.type} • ${ambulance.plateNumber}'),
                    subtitle: Text(
                      '${ambulance.currentLocation}${ambulance.distanceKm == null ? '' : ' · ${ambulance.distanceKm!.toStringAsFixed(1)} km away'}',
                    ),
                    trailing: Switch(
                      value: ambulance.status == AmbulanceStatus.available,
                      onChanged: ambulance.status == AmbulanceStatus.busy &&
                              appState.driverActiveBookings.isNotEmpty
                          ? null
                          : (_) => appState.toggleCurrentDriverAvailability(),
                    ),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    if (appState.isSharingDriverLocation) {
                      appState.stopDriverLocationSharing();
                    } else {
                      await appState.startDriverLocationSharing();
                    }
                    if (context.mounted && appState.errorMessage == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            appState.isSharingDriverLocation
                                ? 'Live location sharing started.'
                                : 'Live location sharing stopped.',
                          ),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    appState.isSharingDriverLocation
                        ? Icons.location_disabled_rounded
                        : Icons.my_location_rounded,
                  ),
                  label: Text(
                    appState.isSharingDriverLocation
                        ? 'Stop sharing live location'
                        : 'Share live location',
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
    final pendingBookings = appState.driverBookings
        .where((booking) => booking.status == BookingStatus.pending)
        .toList();

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
                Text('Patient phone: ${booking.patientPhone.isEmpty ? 'Not provided' : booking.patientPhone}'),
                if (booking.notes.isNotEmpty) Text('Medical notes: ${booking.notes}'),
                const SizedBox(height: 12),
                if (booking.patientPhone.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final uri = Uri(scheme: 'tel', path: booking.patientPhone);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    icon: const Icon(Icons.call_rounded),
                    label: const Text('Call patient'),
                  ),
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

class DriverActiveTripsPage extends StatelessWidget {
  const DriverActiveTripsPage({super.key});

  BookingStatus _nextStatus(BookingStatus status) {
    return switch (status) {
      BookingStatus.accepted => BookingStatus.driverOnWay,
      BookingStatus.driverOnWay => BookingStatus.arrived,
      BookingStatus.arrived => BookingStatus.patientPicked,
      BookingStatus.patientPicked => BookingStatus.goingToHospital,
      BookingStatus.goingToHospital => BookingStatus.completed,
      _ => status,
    };
  }

  String _nextAction(BookingStatus status) {
    return switch (status) {
      BookingStatus.accepted => 'Start driving to pickup',
      BookingStatus.driverOnWay => 'Mark arrived',
      BookingStatus.arrived => 'Confirm patient picked up',
      BookingStatus.patientPicked => 'Start hospital transfer',
      BookingStatus.goingToHospital => 'Complete trip',
      _ => 'Update trip',
    };
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final trips = appState.driverActiveBookings;
    if (trips.isEmpty) {
      return const Center(child: Text('No active trips assigned.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: trips.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = trips[index];
        final nextStatus = _nextStatus(booking.status);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(booking.patientName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    StatusChip(label: booking.statusLabel, color: AppColors.medicalBlue),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Patient phone: ${booking.patientPhone.isEmpty ? 'Not provided' : booking.patientPhone}'),
                Text('Pickup: ${booking.pickupLocation}'),
                Text('Hospital: ${booking.destination}'),
                if (booking.notes.isNotEmpty) Text('Notes: ${booking.notes}'),
                const SizedBox(height: 12),
                if (booking.patientPhone.isNotEmpty)
                  OutlinedButton.icon(
                    onPressed: () async {
                      final uri = Uri(scheme: 'tel', path: booking.patientPhone);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    icon: const Icon(Icons.call_rounded),
                    label: const Text('Call patient'),
                  ),
                PrimaryButton(
                  label: _nextAction(booking.status),
                  onPressed: () => appState.updateBookingStatus(booking.id, nextStatus),
                  icon: nextStatus == BookingStatus.completed
                      ? Icons.task_alt_rounded
                      : Icons.arrow_forward_rounded,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DriverHistoryPage extends StatelessWidget {
  const DriverHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<AppState>().driverTripHistory;
    if (history.isEmpty) {
      return const Center(child: Text('Completed trips will appear here.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: history.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final booking = history[index];
        return Card(
          child: ListTile(
            title: Text(booking.patientName),
            subtitle: Text('${booking.pickupLocation} → ${booking.destination}'),
            trailing: StatusChip(
              label: booking.statusLabel,
              color: booking.status == BookingStatus.completed
                  ? AppColors.successGreen
                  : AppColors.warningOrange,
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
                OutlinedButton.icon(
                  onPressed: () => _editDriverProfile(context, user.name, user.phone, user.address),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit profile'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _editDriverProfile(
  BuildContext context,
  String name,
  String phone,
  String address,
) async {
  final nameController = TextEditingController(text: name);
  final phoneController = TextEditingController(text: phone);
  final addressController = TextEditingController(text: address);
  final formKey = GlobalKey<FormState>();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit driver profile'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _driverProfileField(nameController, 'Full name'),
            _driverProfileField(phoneController, 'Phone number'),
            _driverProfileField(addressController, 'Address'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context, true);
            }
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    await context.read<AppState>().updateProfile(
      name: nameController.text,
      phone: phoneController.text,
      address: addressController.text,
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Driver profile updated.')),
      );
    }
  }
  nameController.dispose();
  phoneController.dispose();
  addressController.dispose();
}

Widget _driverProfileField(TextEditingController controller, String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: controller,
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Required' : null,
      decoration: InputDecoration(labelText: label),
    ),
  );
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
