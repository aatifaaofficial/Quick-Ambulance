import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/ambulance.dart';
import '../../models/booking_request.dart';
import '../../models/hospital.dart';
import '../../models/user_profile.dart';
import '../../providers/app_state.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/app_error_banner.dart';
import '../auth/auth_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    OverviewPage(),
    ManageUsersPage(),
    FleetPage(),
    HospitalManagementPage(),
    BookingManagementPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final destinations = const [
      NavigationDestination(
        icon: Icon(Icons.dashboard_rounded),
        label: 'Overview',
      ),
      NavigationDestination(icon: Icon(Icons.group_rounded), label: 'People'),
      NavigationDestination(
        icon: Icon(Icons.local_taxi_rounded),
        label: 'Fleet',
      ),
      NavigationDestination(
        icon: Icon(Icons.local_hospital_rounded),
        label: 'Hospitals',
      ),
      NavigationDestination(
        icon: Icon(Icons.assignment_rounded),
        label: 'Bookings',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Log out',
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
            child: IndexedStack(index: _selectedIndex, children: _pages),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: destinations,
      ),
    );
  }
}

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            AdminStatCard(title: 'Users', value: '${appState.totalUsers}'),
            AdminStatCard(title: 'Drivers', value: '${appState.totalDrivers}'),
            AdminStatCard(
              title: 'Ambulances',
              value: '${appState.totalAmbulances}',
            ),
            AdminStatCard(
              title: 'Hospitals',
              value: '${appState.hospitals.length}',
            ),
            AdminStatCard(
              title: 'Active bookings',
              value: '${appState.totalActiveBookings}',
            ),
            AdminStatCard(
              title: 'Completed trips',
              value: '${appState.totalCompletedBookings}',
            ),
          ],
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active booking monitoring',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (appState.activeBookings.isEmpty)
                  const Text('There are no active bookings right now.')
                else
                  ...appState.activeBookings.map(
                    (booking) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(booking.patientName),
                      subtitle: Text(
                        '${booking.pickupLocation} → ${booking.destination}',
                      ),
                      trailing: StatusChip(
                        label: booking.statusLabel,
                        color: AppColors.medicalBlue,
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

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    final users = context.watch<AppState>().users.where(
      (user) => _selectedRole == null || user.role == _selectedRole,
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Wrap(
            spacing: 8,
            children: [
              _roleChip('All', null),
              _roleChip('Patients', UserRole.patient),
              _roleChip('Drivers', UserRole.driver),
              _roleChip('Admins', UserRole.admin),
            ],
          ),
        ),
        Expanded(
          child: users.isEmpty
              ? const Center(child: Text('No users in this category.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: users.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final user = users.elementAt(index);
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user.role == UserRole.admin
                              ? AppColors.medicalBlue
                              : AppColors.emergencyRed,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(user.name),
                        subtitle: Text(
                          '${user.roleLabel} • ${user.email}\n${user.phone}\n${user.address}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(user.name),
                            content: Text(
                              '${user.roleLabel}\n${user.email}\n${user.phone}\n${user.address}',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _roleChip(String label, UserRole? role) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedRole == role,
      onSelected: (_) => setState(() => _selectedRole = role),
    );
  }
}

class FleetPage extends StatelessWidget {
  const FleetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => _showAddAmbulanceDialog(context, appState),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add ambulance'),
          ),
        ),
        if (appState.ambulances.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No ambulances have been registered.'),
          ),
        ...appState.ambulances.map(
          (ambulance) => Card(
            child: ListTile(
              leading: const Icon(Icons.local_taxi_rounded),
              title: Text('${ambulance.type} (${ambulance.plateNumber})'),
              subtitle: Text(
                '${ambulance.driverName} • ${ambulance.currentLocation}',
              ),
              trailing: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    ambulance.statusLabel,
                    style: TextStyle(
                      color: ambulance.status == AmbulanceStatus.available
                          ? AppColors.successGreen
                          : AppColors.warningOrange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Toggle availability',
                    onPressed: ambulance.status == AmbulanceStatus.busy
                        ? null
                        : () => appState.toggleAmbulanceAvailability(
                            ambulance.id,
                          ),
                    icon: const Icon(Icons.sync_alt_rounded),
                  ),
                  IconButton(
                    tooltip: 'Remove ambulance',
                    onPressed: () =>
                        appState.removeAmbulance(ambulance.id),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HospitalManagementPage extends StatelessWidget {
  const HospitalManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => _showAddHospitalDialog(context, appState),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add hospital'),
          ),
        ),
        if (appState.hospitals.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No hospitals have been registered.'),
          ),
        ...appState.hospitals.map(
          (hospital) => Card(
            child: ListTile(
              leading: const Icon(Icons.local_hospital_rounded),
              title: Text(hospital.name),
              subtitle: Text('${hospital.address} • ${hospital.phone}'),
              trailing: IconButton(
                tooltip: 'Remove hospital',
                onPressed: () => appState.removeHospital(hospital.id),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BookingManagementPage extends StatelessWidget {
  const BookingManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final bookings = appState.bookings;
    if (bookings.isEmpty) {
      return const Center(child: Text('No bookings have been created.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          child: ListTile(
            title: Text('${booking.patientName} · ${booking.destination}'),
            subtitle: Text(
              'Pickup: ${booking.pickupLocation}\nDriver: ${booking.driverName}',
            ),
            isThreeLine: true,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StatusChip(
                  label: booking.statusLabel,
                  color: booking.isActive
                      ? AppColors.medicalBlue
                      : AppColors.textSecondary,
                ),
                DropdownButton<BookingStatus>(
                  value: booking.status,
                  underline: const SizedBox.shrink(),
                  items: BookingStatus.values
                      .map(
                        (status) => DropdownMenuItem<BookingStatus>(
                          value: status,
                          child: Text(statusLabelForAdmin(status)),
                        ),
                      )
                      .toList(),
                  onChanged: (status) {
                    if (status != null) {
                      appState.updateBookingStatus(booking.id, status);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

String statusLabelForAdmin(BookingStatus status) {
  return switch (status) {
    BookingStatus.pending => 'Pending',
    BookingStatus.accepted => 'Accepted',
    BookingStatus.driverOnWay => 'Driver on Way',
    BookingStatus.arrived => 'Arrived',
    BookingStatus.patientPicked => 'Patient Picked',
    BookingStatus.goingToHospital => 'Going to Hospital',
    BookingStatus.completed => 'Completed',
    BookingStatus.cancelled => 'Cancelled',
    BookingStatus.rejected => 'Rejected',
  };
}

Future<void> _showAddAmbulanceDialog(
  BuildContext context,
  AppState appState,
) async {
  final id = TextEditingController();
  final type = TextEditingController(text: 'Basic Life Support');
  final plate = TextEditingController();
  final driver = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add ambulance'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _adminField(id, 'Ambulance ID'),
              _adminField(type, 'Ambulance type'),
              _adminField(plate, 'Plate number'),
              _adminField(driver, 'Assigned driver'),
            ],
          ),
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
          child: const Text('Add'),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    appState.addAmbulance(
      Ambulance(
        id: id.text.trim(),
        type: type.text.trim(),
        plateNumber: plate.text.trim(),
        driverName: driver.text.trim(),
        currentLocation: 'Not updated',
        status: AmbulanceStatus.offline,
        capacity: 2,
        driverId: appState.users
            .where(
              (user) =>
                  user.role == UserRole.driver &&
                  user.name.toLowerCase() == driver.text.trim().toLowerCase(),
            )
            .firstOrNull
            ?.id,
      ),
    );
  }
  id.dispose();
  type.dispose();
  plate.dispose();
  driver.dispose();
}

Future<void> _showAddHospitalDialog(
  BuildContext context,
  AppState appState,
) async {
  final id = TextEditingController();
  final name = TextEditingController();
  final address = TextEditingController();
  final phone = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add hospital'),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _adminField(id, 'Hospital ID'),
              _adminField(name, 'Hospital name'),
              _adminField(address, 'Address'),
              _adminField(phone, 'Phone', keyboardType: TextInputType.phone),
            ],
          ),
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
          child: const Text('Add'),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    appState.addHospital(
      Hospital(
        id: id.text.trim(),
        name: name.text.trim(),
        address: address.text.trim(),
        emergencyLevel: 'Level 1',
        rating: 0,
        phone: phone.text.trim(),
        specialties: const ['Emergency'],
      ),
    );
  }
  id.dispose();
  name.dispose();
  address.dispose();
  phone.dispose();
}

Widget _adminField(
  TextEditingController controller,
  String label, {
  TextInputType? keyboardType,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Required' : null,
      decoration: InputDecoration(labelText: label),
    ),
  );
}

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({required this.title, required this.value, super.key});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
