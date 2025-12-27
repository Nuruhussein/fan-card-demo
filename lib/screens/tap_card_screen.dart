import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/app_state.dart';
import 'payment_input_screen.dart';

class TapCardScreen extends StatefulWidget {
  const TapCardScreen({super.key});

  @override
  State<TapCardScreen> createState() => _TapCardScreenState();
}

class _TapCardScreenState extends State<TapCardScreen> {
  bool _isScanning = false;

  void _startScan(BuildContext context) async {
    setState(() {
      _isScanning = true;
    });

    final appState = Provider.of<AppState>(context, listen: false);
    final uid = await appState.scanForUid();

    if (!context.mounted) return;

    if (uid != null) {
      appState.setFanUid(uid);
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaymentInputScreen()),
        );
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to read card. Please try again.'),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B), Color(0xFF0F172A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              // Logo/Icon Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(color: Colors.white10),
                ),
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => const Icon(
                          Icons.flash_on,
                          size: 80,
                          color: Colors.indigoAccent,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Fana Energy Express',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Instant Electricity Recharge',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // Scan Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      if (_isScanning)
                        const SpinKitRipple(color: Color(0xFF818CF8), size: 100)
                      else
                        const Icon(
                          Icons.nfc_outlined,
                          size: 80,
                          color: Colors.white24,
                        ),
                      const SizedBox(height: 32),
                      const Text(
                        'Ready to Scan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Hold your card near the phone',
                        style: TextStyle(color: Colors.white38),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isScanning ? null : () => _startScan(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.2,
                            ),
                          ),
                          child: const Text('SEARCH FOR CARD'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
