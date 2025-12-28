import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/payment_service.dart';
import 'package:chapasdk/chapasdk.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class PaymentInputScreen extends StatefulWidget {
  const PaymentInputScreen({super.key});

  @override
  State<PaymentInputScreen> createState() => _PaymentInputScreenState();
}

class _PaymentInputScreenState extends State<PaymentInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;

  void _handlePay() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isProcessing = true);

      final appState = Provider.of<AppState>(context, listen: false);
      final amount = double.parse(_amountController.text);

      appState.setPaymentDetails(amount);
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
          email: 'nuruhussen943@gmail.com',
          firstName: 'Fan',
          lastName: 'User',
          txRef: txRef,
          phone: "0900123456", // Mandatory in this version
          namedRouteFallBack: "/write-token", // Mandatory in this version
          title: 'Energy Recharge',
          desc: 'Electricity Payment',
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

  String _generateMockToken() {
    // Generates a 20-digit numeric token
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    return (random + "4589223177449921").substring(0, 20);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('RECHARGE'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E1B4B), // Indigo 950
              Color(0xFF0F172A), // Slate 900
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Purchase Energy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter the amount you want to recharge',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFF818CF8),
                                width: 2,
                              ),
                            ),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 20, right: 8),
                              child: Text(
                                'ETB',
                                style: TextStyle(
                                  color: Color(0xFF818CF8),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Required';
                            final val = double.tryParse(value);
                            if (val == null) return 'Enter valid number';
                            if (val < 1) return 'Minimum amount is 1 ETB';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildQuickAmount(500),
                            _buildQuickAmount(1000),
                            _buildQuickAmount(2000),
                            _buildQuickAmount(5000),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _handlePay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981), // Emerald 500
                        foregroundColor: Colors.white,
                        shadowColor: const Color(0xFF10B981).withOpacity(0.4),
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
                      child:
                          _isProcessing
                              ? const SpinKitThreeBounce(
                                color: Colors.white,
                                size: 24,
                              )
                              : const Text('FINISH PAYMENT'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.security,
                          size: 16,
                          color: Colors.white38,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Secured by Chapa',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
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

  Widget _buildQuickAmount(double amt) {
    return InkWell(
      onTap: () => _amountController.text = amt.toStringAsFixed(0),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(
          '${amt.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
