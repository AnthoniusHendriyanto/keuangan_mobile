import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/dashboard/dashboard_screen.dart';

void main() {
  runApp(const TrueLiabilityApp());
}

class TrueLiabilityApp extends StatelessWidget {
  const TrueLiabilityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'True Liability',
      theme: AppTheme.darkTheme,
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
