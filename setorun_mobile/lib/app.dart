import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/student/dashboard_screen.dart';
import 'screens/teacher/teacher_dashboard_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.teal),
              ),
            );
          case AuthStatus.authenticated:
            final user = auth.user!;
            if (user.isTeacher) {
              return const TeacherDashboardScreen();
            }
            return const DashboardScreen();
          case AuthStatus.unauthenticated:
            return const LoginScreen();
        }
      },
    );
  }
}
