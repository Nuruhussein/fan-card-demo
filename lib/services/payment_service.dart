import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class PaymentService {
  final String publicKey = 'CHAPUBK_TEST-93GMERW7fzSUCE10kJpwqBQ0zxYW8TBq';
  final String secretKey = 'CHASECK_TEST-oQ0sTIiigVQIU71WSvnctFkiUyIVIajU';

  Future<bool> verifyPayment(String txRef) async {
    // In a real app, you'd check with Chapa API if the txRef is successful
    // For this demo/setup, we might mock success or use direct verification if supported
    return true; 
  }
}
