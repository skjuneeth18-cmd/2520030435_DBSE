import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../main/main_shell.dart';

/// Splash screen: logo, app name, tagline, then routes the user to
/// Home (if logged in) or Login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 3), _navigateNext);
  }

  void _navigateNext() {
    if (!mounted) return;
    final loggedIn = AuthService.instance.currentUser != null;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            loggedIn ? const MainShell() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.red,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.water_drop,
                color: AppTheme.red,
                size: 72,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'RaktaSetu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Find Blood Fast. Save Lives.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
