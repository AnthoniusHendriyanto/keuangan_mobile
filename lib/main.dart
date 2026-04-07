import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/dashboard/main_screen.dart';
import 'presentation/auth/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/network/api_client.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
  late Future<String?> _tokenFuture;

  @override
  void initState() {
    super.initState();
    _tokenFuture = ApiClient().getToken();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _tokenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        final hasToken = snapshot.data != null && snapshot.data!.isNotEmpty;
        if (!hasToken) {
          return const LoginScreen();
        }
        return const MainScreen();
      },
    );
  }
}
