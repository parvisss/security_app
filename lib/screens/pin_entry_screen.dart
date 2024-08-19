// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:security_app/screens/todo_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinEntryPage extends StatelessWidget {
  final String? storedPin;

  const PinEntryPage({super.key, required this.storedPin});

  @override
  Widget build(BuildContext context) {
    final TextEditingController pinController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter PIN'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Pinput(
            length: 4,
            controller: pinController,
            onCompleted: (pin) async {
              if (pin == storedPin) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', true);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const TodoScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Incorrect PIN')),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
