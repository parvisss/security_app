// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:io' show Platform;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isPinEnabled = false;
  bool _isBiometricEnabled = false;
  String? _storedPin;
  final LocalAuthentication auth = LocalAuthentication();

  final TextEditingController _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _storedPin = prefs.getString('userPin');
      _isPinEnabled = _storedPin != null;
      _isBiometricEnabled = prefs.getBool('isBiometricEnabled') ?? false;
    });
  }

  Future<void> _savePin(String pin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPin', pin);
    setState(() {
      _storedPin = pin;
      _isPinEnabled = true;
    });
  }

  Future<void> _removePin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userPin');
    setState(() {
      _storedPin = null;
      _isPinEnabled = false;
    });
  }

  Future<void> _setBiometricEnabled(bool enabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isBiometricEnabled', enabled);
    setState(() {
      _isBiometricEnabled = enabled;
    });
  }

  Future<void> _authenticateBiometric() async {
    try {
      // Check if device supports biometrics
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();
      List<BiometricType> availableBiometrics =
          await auth.getAvailableBiometrics();

      print('Can Check Biometrics: $canCheckBiometrics');
      print('Is Device Supported: $isDeviceSupported');
      print('Available Biometrics: $availableBiometrics');

      if (!canCheckBiometrics ||
          !isDeviceSupported ||
          availableBiometrics.isEmpty) {
        _showSnackBar(
            'Biometric authentication is not available on this device.');
        return;
      }

      // Determine the biometric type to use
      String biometricType = 'Biometric';
      if (availableBiometrics.contains(BiometricType.fingerprint)) {
        biometricType = 'Fingerprint';
      } else if (availableBiometrics.contains(BiometricType.face)) {
        biometricType = Platform.isIOS ? 'Face ID' : 'Face Recognition';
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        biometricType = 'Iris Recognition';
      }

      bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate using $biometricType',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        _showSnackBar('$biometricType authentication successful!');
        await _setBiometricEnabled(true);
      } else {
        _showSnackBar('$biometricType authentication failed or canceled.');
        await _setBiometricEnabled(false);
      }
    } catch (e) {
      _showSnackBar('Error during biometric authentication: $e');
      await _setBiometricEnabled(false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _promptPinSetup() {
    _pinController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set PIN'),
        content: Pinput(
          length: 4,
          controller: _pinController,
          obscureText: true,
          obscuringCharacter: '*',
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _pinController.clear();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (_pinController.text.length == 4) {
                await _savePin(_pinController.text);
                Navigator.of(context).pop();
                _showSnackBar('PIN set successfully.');
              } else {
                _showSnackBar('Please enter a 4-digit PIN.');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmPinRemoval() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove PIN'),
        content: const Text('Are you sure you want to remove your PIN?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _removePin();
              Navigator.of(context).pop();
              _showSnackBar('PIN removed successfully.');
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _confirmBiometricDisable() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable Biometric Authentication'),
        content: const Text(
            'Are you sure you want to disable biometric authentication?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _setBiometricEnabled(false);
              Navigator.of(context).pop();
              _showSnackBar('Biometric authentication disabled.');
            },
            child: const Text('Disable'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable PIN'),
            value: _isPinEnabled,
            onChanged: (value) {
              if (value) {
                _promptPinSetup();
              } else {
                _confirmPinRemoval();
              }
            },
            secondary: const Icon(Icons.lock),
          ),
          SwitchListTile(
            title: const Text('Enable Biometric Authentication'),
            value: _isBiometricEnabled,
            onChanged: (value) {
              if (value) {
                _authenticateBiometric();
              } else {
                _confirmBiometricDisable();
              }
            },
            secondary: const Icon(Icons.fingerprint),
          ),
        ],
      ),
    );
  }
}
