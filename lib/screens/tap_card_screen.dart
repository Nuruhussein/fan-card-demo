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
          const SnackBar(content: Text('Failed to read card. Please try again.')),
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade900, Colors.black],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.nfc, size: 100, color: Colors.white),
            const SizedBox(height: 40),
            const Text(
              'Welcome Fan!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please tap your NFC card to begin',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 60),
            if (_isScanning)
              const SpinKitRipple(color: Colors.white, size: 80)
            else
              ElevatedButton(
                onPressed: () => _startScan(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple.shade900,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Tap NFC Card', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
