import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/app_state.dart';
import 'demo_result_screen.dart';

class WriteTokenScreen extends StatelessWidget {
  const WriteTokenScreen({super.key});

  void _handleWrite(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final token = appState.generatedToken;

    if (token != null) {
      final success = await appState.writeToken(token);
      if (success && context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DemoResultScreen()),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to write token. Try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWriting = Provider.of<AppState>(context).isWriting;
    final token = Provider.of<AppState>(context).generatedToken;
    final kwh = Provider.of<AppState>(context).kwh;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.check_circle,
                size: 80,
                color: Color(0xFF10B981), // Emerald 500
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Received',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Token ready for card writing',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const Spacer(),
              // Token Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'RECHARGE TOKEN',
                        style: TextStyle(
                          color: Color(0xFF818CF8),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        token ?? '---- ---- ---- ----',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bolt, color: Colors.amber, size: 32),
                          const SizedBox(width: 12),
                          Text(
                            '${kwh?.toStringAsFixed(2) ?? "0.00"} kWh',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Action Section
              Padding(
                padding: const EdgeInsets.all(32),
                child:
                    isWriting
                        ? Column(
                          children: [
                            const SpinKitRipple(
                              color: Color(0xFF818CF8),
                              size: 100,
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'UPDATING CARD...',
                              style: TextStyle(
                                color: Color(0xFF818CF8),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        )
                        : SizedBox(
                          width: double.infinity,
                          height: 65,
                          child: ElevatedButton.icon(
                            onPressed: () => _handleWrite(context),
                            icon: const Icon(Icons.nfc, size: 28),
                            label: const Text('WRITE TO CARD'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1E1B4B),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
