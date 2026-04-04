import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/dashboard/dashboard_screen.dart';
import 'presentation/auth/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://tlcfjcuudswmgqfpcmzr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRsY2ZqY3V1ZHN3bWdxZnBjbXpyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQzNjIxNTcsImV4cCI6MjA4OTkzODE1N30.TLxkUebisW04DPBUT9x4MYheKIEdEaXoPtAgNcm6Xbo',
  );

  runApp(
    const ProviderScope(
      child: TrueLiabilityApp(),
    ),
  );
}

class TrueLiabilityApp extends StatelessWidget {
  const TrueLiabilityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'True Liability',
      theme: AppTheme.darkTheme,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      return const LoginScreen();
    }
    return const DashboardScreen();
  }
}
