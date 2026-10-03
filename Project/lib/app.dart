import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/splash/splash_screen.dart';

class RaktaSetuApp extends StatelessWidget {
  const RaktaSetuApp({super.key});

  static const String title = 'RaktaSetu';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case RegisterScreen.routeName:
            return MaterialPageRoute(
              builder: (_) => const RegisterScreen(),
              settings: settings,
            );
          case ForgotPasswordScreen.routeName:
            return MaterialPageRoute(
              builder: (_) => const ForgotPasswordScreen(),
              settings: settings,
            );
          default:
            return null;
        }
      },
    );
  }
}
