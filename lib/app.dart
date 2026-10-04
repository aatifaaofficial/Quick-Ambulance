import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'providers/app_state.dart';
import 'screens/auth/splash_screen.dart';

class QuickAmbulanceApp extends StatelessWidget {
  const QuickAmbulanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Quick Ambulance',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
        },
        home: const SplashScreen(),
      ),
    );
  }
}
