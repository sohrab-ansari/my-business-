import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../dashboards/owner/owner_dashboard.dart';
import '../viewmodels/auth_viewmidel.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    return StreamBuilder<User?>(
      stream: authVM.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const OwnerDashboardScreen();
        }
        return  LoginScreen();
      },
    );
  }
}