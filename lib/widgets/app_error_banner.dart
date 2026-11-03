import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/app_state.dart';

class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final message = appState.errorMessage;
        if (message == null || message.isEmpty) {
          return const SizedBox.shrink();
        }

        return MaterialBanner(
          backgroundColor: AppColors.emergencyRed.withAlpha(18),
          content: Text(message),
          leading: const Icon(
            Icons.error_outline_rounded,
            color: AppColors.emergencyRed,
          ),
          actions: [
            TextButton(
              onPressed: appState.clearError,
              child: const Text('Dismiss'),
            ),
          ],
        );
      },
    );
  }
}
