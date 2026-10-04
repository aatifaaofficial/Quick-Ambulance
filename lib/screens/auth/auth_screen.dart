import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../models/user_profile.dart';
import '../../providers/app_state.dart';
import '../../widgets/primary_button.dart';
import '../admin/admin_dashboard.dart';
import '../driver/driver_dashboard.dart';
import '../patient/patient_dashboard.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController(
    text: 'patient@example.com',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '123456',
  );
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool isLogin = true;
  UserRole selectedRole = UserRole.patient;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final appState = context.read<AppState>();
    if (isLogin) {
      await appState.signIn(
        _emailController.text,
        _passwordController.text,
        selectedRole,
      );
    } else {
      await appState.register(
        _nameController.text,
        _emailController.text,
        _phoneController.text,
        _addressController.text,
        _passwordController.text,
        selectedRole,
      );
    }

    if (!mounted) {
      return;
    }

    if (appState.isLoggedIn) {
      final target = switch (selectedRole) {
        UserRole.patient => const PatientDashboardScreen(),
        UserRole.driver => const DriverDashboardScreen(),
        UserRole.admin => const AdminDashboardScreen(),
      };
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => target),
      );
      return;
    }

    final message = appState.errorMessage ?? 'Something went wrong';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.emergencyRed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.emergencyRed.withAlpha(26),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.local_hospital_rounded,
                              size: 36,
                              color: AppColors.emergencyRed,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Center(
                          child: Text(
                            'Quick Ambulance',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'Fast Response. Safe Journey. Better Emergency Care.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SegmentedButton<UserRole>(
                          selected: {selectedRole},
                          onSelectionChanged: (value) {
                            setState(() {
                              selectedRole = value.first;
                            });
                          },
                          segments: const [
                            ButtonSegment<UserRole>(
                              value: UserRole.patient,
                              label: Text('Patient'),
                            ),
                            ButtonSegment<UserRole>(
                              value: UserRole.driver,
                              label: Text('Driver'),
                            ),
                            ButtonSegment<UserRole>(
                              value: UserRole.admin,
                              label: Text('Admin'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: ChoiceChip(
                                label: const Text('Login'),
                                selected: isLogin,
                                onSelected: (_) => setState(() => isLogin = true),
                                selectedColor: AppColors.emergencyRed.withAlpha(25),
                                labelStyle: TextStyle(
                                  color: isLogin ? AppColors.emergencyRed : AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ChoiceChip(
                                label: const Text('Register'),
                                selected: !isLogin,
                                onSelected: (_) => setState(() => isLogin = false),
                                selectedColor: AppColors.emergencyRed.withAlpha(25),
                                labelStyle: TextStyle(
                                  color: !isLogin ? AppColors.emergencyRed : AppColors.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (!isLogin)
                          Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                validator: (value) =>
                                    value == null || value.trim().isEmpty ? 'Full name is required' : null,
                                decoration: const InputDecoration(
                                  labelText: 'Full name',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                validator: (value) =>
                                    value == null || value.trim().isEmpty ? 'Phone number is required' : null,
                                decoration: const InputDecoration(
                                  labelText: 'Phone',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _addressController,
                                validator: (value) =>
                                    value == null || value.trim().isEmpty ? 'Address is required' : null,
                                decoration: const InputDecoration(
                                  labelText: 'Address',
                                  prefixIcon: Icon(Icons.location_on_outlined),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Minimum 6 characters';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                        ),
                        if (isLogin)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(builder: (_) => const ForgotPasswordScreen()),
                                );
                              },
                              child: const Text('Forgot password?'),
                            ),
                          ),
                        const SizedBox(height: 18),
                        Consumer<AppState>(
                          builder: (context, appState, child) {
                            return PrimaryButton(
                              label: isLogin ? 'Login' : 'Create account',
                              isLoading: appState.isLoading,
                              onPressed: _submit,
                              icon: isLogin ? Icons.login_rounded : Icons.person_add_alt_1,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Demo accounts: patient@example.com, driver@example.com, admin@quickambulance.com | password: 123456',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
