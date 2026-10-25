import 'package:flutter/material.dart';
import '../../../core/security/security_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../emergency/screens/emergency_screen.dart';
import '../../home/screens/home_screen.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _hasPin = false;
  bool _isChecking = true;
  String _statusMessage = 'Enter PIN or use Fingerprint';

  @override
  void initState() {
    super.initState();
    _checkSecurityStatus();
  }

  Future<void> _checkSecurityStatus() async {
    final hasPin = await SecurityService.instance.hasPinSet();
    setState(() {
      _hasPin = hasPin;
      _isChecking = false;
    });

    // Auto-prompt biometrics if supported
    _authenticateWithBiometrics();
  }

  Future<void> _authenticateWithBiometrics() async {
    final success = await SecurityService.instance.authenticateWithBiometrics();
    if (success && mounted) {
      _unlockApp();
    }
  }

  Future<void> _handlePinSubmit() async {
    final entered = _pinController.text;
    if (!_hasPin) {
      // First run: setup PIN
      if (entered.length < 4) {
        setState(() => _statusMessage = 'PIN must be at least 4 digits');
        return;
      }
      await SecurityService.instance.setPin(entered);
      _unlockApp();
    } else {
      final valid = await SecurityService.instance.verifyPin(entered);
      if (valid) {
        _unlockApp();
      } else {
        setState(() {
          _statusMessage = 'Incorrect PIN. Try again.';
          _pinController.clear();
        });
      }
    }
  }

  void _unlockApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _openEmergencyQuickAccess() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const EmergencyScreen(isQuickAccess: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Bar with Quick-Access Emergency Button (U-9 Option B)
              Align(
                alignment: Alignment.topRight,
                child: TextButton.icon(
                  onPressed: _openEmergencyQuickAccess,
                  icon: const Icon(Icons.emergency, color: AppTheme.accentRose, size: 20),
                  label: const Text(
                    'EMERGENCY / 緊急',
                    style: TextStyle(
                      color: AppTheme.accentRose,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.accentRose.withOpacity(0.12),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),

              // Center: App Branding & Unlock Form
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 1.5),
                    ),
                    child: const Icon(Icons.shield_outlined, color: AppTheme.primary, size: 40),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'AIBO',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 2),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'AI Buddy & Organiser • Japan',
                    style: TextStyle(fontSize: 13, color: Colors.white54),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    !_hasPin ? 'Create Master Security PIN' : _statusMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: _statusMessage.contains('Incorrect') ? AppTheme.accentRose : Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 220,
                    child: TextField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: '••••',
                        counterText: '',
                      ),
                      onSubmitted: (_) => _handlePinSubmit(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _handlePinSubmit,
                    child: Text(!_hasPin ? 'Set PIN & Enter' : 'Unlock AIBO'),
                  ),
                  const SizedBox(height: 12),
                  IconButton(
                    onPressed: _authenticateWithBiometrics,
                    icon: const Icon(Icons.fingerprint, size: 38, color: AppTheme.accentTeal),
                    tooltip: 'Unlock with Biometrics',
                  ),
                ],
              ),

              // Bottom Notice
              const Text(
                '100% Offline • AES-256 Encrypted on Device',
                style: TextStyle(fontSize: 11, color: Colors.white30, letterSpacing: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
