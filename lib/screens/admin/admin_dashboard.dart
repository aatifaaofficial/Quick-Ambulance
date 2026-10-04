import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/ambulance.dart';
import '../../models/user_profile.dart';
import '../../providers/app_state.dart';
import '../auth/auth_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => AdminDashboardScreenState();
}

class AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const OverviewPage(),
      const ManageUsersPage(),
      const FleetPage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
          NavigationDestination(icon: Icon(Icons.group_rounded), label: 'Users'),
          NavigationDestination(icon: Icon(Icons.local_taxi_rounded), label: 'Fleet'),
        ],
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
        Row(
          children: [
            Expanded(child: AdminStatCard(title: 'Users', value: appState.totalUsers.toString())),
            const SizedBox(width: 12),
            Expanded(child: AdminStatCard(title: 'Drivers', value: appState.totalDrivers.toString())),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: AdminStatCard(title: 'Ambulances', value: appState.totalAmbulances.toString())),
            const SizedBox(width: 12),
            Expanded(child: AdminStatCard(title: 'Active', value: appState.totalActiveBookings.toString())),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Live bookings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...appState.activeBookings.take(3).map(
                  (booking) => ListTile(
                    title: Text(booking.patientName),
                    subtitle: Text(booking.destination),
                    trailing: Text(booking.statusLabel),
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

class ManageUsersPage extends StatelessWidget {
  const ManageUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: appState.users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final user = appState.users[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: user.role == UserRole.admin ? AppColors.medicalBlue : AppColors.emergencyRed,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(user.name),
            subtitle: Text('${user.roleLabel} • ${user.email}'),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        );
      },
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
        ...appState.ambulances.map(
          (ambulance) => Card(
            child: ListTile(
              title: Text('${ambulance.type} (${ambulance.plateNumber})'),
              subtitle: Text('${ambulance.driverName} • ${ambulance.currentLocation}'),
              trailing: Text(
                ambulance.statusLabel,
                style: TextStyle(
                  color: ambulance.status == AmbulanceStatus.available ? AppColors.successGreen : AppColors.warningOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({required this.title, required this.value, super.key});

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
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
