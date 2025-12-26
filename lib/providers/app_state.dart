import 'package:flutter/material.dart';
import '../services/nfc_service.dart';
import '../services/payment_service.dart';

class AppState extends ChangeNotifier {
  final NfcService _nfcService = NfcService();
  final PaymentService _paymentService = PaymentService();

  String? fanUid;
  String? meterNumber;
  double? amount;
  double? kwh;
  String? generatedToken;
  bool isWriting = false;

  void setFanUid(String uid) {
    fanUid = uid;
    notifyListeners();
  }

  void setPaymentDetails(String meter, double amt) {
    meterNumber = meter;
    amount = amt;
    // Sample calculation: 1 ETB = 0.5 kWh
    kwh = amt * 0.5;
    notifyListeners();
  }

  void setGeneratedToken(String token) {
    generatedToken = token;
    notifyListeners();
  }

  Future<String?> scanForUid() async {
    return await _nfcService.readTagUID();
  }

  Future<bool> writeToken(String token) async {
    isWriting = true;
    notifyListeners();
    final result = await _nfcService.writeTokenToTag(token);
    isWriting = false;
    notifyListeners();
    return result;
  }
}
