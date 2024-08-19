import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:security_app/screens/todo_screen.dart';

class BiometricCheckPage extends StatelessWidget {
  final LocalAuthentication auth = LocalAuthentication();

  BiometricCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authenticate(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError || !snapshot.data!) {
          return const Scaffold(
            body: Center(child: Text('Biometric Authentication Failed')),
          );
        } else {
          return const TodoScreen();
        }
      },
    );
  }

  Future<bool> _authenticate() async {
    try {
      return await auth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (e) {
      return false;
    }
  }
}
