import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/payment_service.dart';
import 'write_token_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chapasdk/chapasdk.dart';
import 'package:uuid/uuid.dart';

class PaymentInputScreen extends StatefulWidget {
  const PaymentInputScreen({super.key});

  @override
  State<PaymentInputScreen> createState() => _PaymentInputScreenState();
}

class _PaymentInputScreenState extends State<PaymentInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _meterController = TextEditingController();
  final _amountController = TextEditingController();
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;

  void _handlePay() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isProcessing = true);

      final appState = Provider.of<AppState>(context, listen: false);
      final amount = double.parse(_amountController.text);
      final meter = _meterController.text;

      appState.setPaymentDetails(meter, amount);
      final token = _generateMockToken();
      appState.setGeneratedToken(token);

      // Using official chapasdk
      try {
        final txRef = 'TX-${const Uuid().v4()}';

        await Chapa.paymentParameters(
          context: context,
          publicKey: 'CHAPUBK_TEST-93GMERW7fzSUCE10kJpwqBQ0zxYW8TBq',
          amount: amount.toStringAsFixed(
            amount == amount.roundToDouble() ? 0 : 2,
          ),
          currency: 'ETB',
          email: 'fan@example.com',
          firstName: 'Fan',
          lastName: 'User',
          txRef: txRef,
          phone: "0912345678", // Mandatory in this version
          namedRouteFallBack: "/write-token", // Mandatory in this version
          title: 'Electricity Token',
          desc: 'Payment for Meter $meter',
          nativeCheckout: true,
          onPaymentFinished: (message, reference, paidAmount) {
            setState(() => _isProcessing = false);

            if (message == 'paymentSuccessful') {
              // Only push if we are not already at the fallback route
              // Chapa SDK might handle the navigation via namedRouteFallBack
              if (context.mounted &&
                  ModalRoute.of(context)?.settings.name != '/write-token') {
                Navigator.pushReplacementNamed(context, '/write-token');
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Payment Failed: $message')),
              );
            }
          },
        );
      } catch (e) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to initialize payment: $e')),
        );
      }
    }
  }

  void _showPostPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Payment Successful?'),
            content: const Text(
              'Once you complete the payment in the browser, tap confirm to generate your token.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Mock success and token generation
                  final token = _generateMockToken();
                  Provider.of<AppState>(
                    context,
                    listen: false,
                  ).setGeneratedToken(token);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WriteTokenScreen(),
                    ),
                  );
                },
                child: const Text('Confirm & Create Token'),
              ),
            ],
          ),
    );
  }

  String _generateMockToken() {
    // Generates a 20-digit numeric token
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return (random + "4589223177449921").substring(0, 20);
  }

  @override
  Widget build(BuildContext context) {
    final fanUid = Provider.of<AppState>(context).fanUid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Electricity Payment'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade800, Colors.black],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dear Fan UID: $fanUid',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _meterController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Enter Meter Number',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator:
                        (value) =>
                            value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Enter Amount (ETB)',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white24),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      final val = double.tryParse(value);
                      if (val == null) return 'Enter valid number';
                      if (val < 1) return 'Minimum amount is 1 ETB';
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _handlePay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isProcessing
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Pay with Chapa',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
