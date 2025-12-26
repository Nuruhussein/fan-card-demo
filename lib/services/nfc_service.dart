import 'package:flutter/foundation.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'dart:typed_data';
import 'dart:async';

class NfcService {
  // Check if NFC is available
  Future<bool> isAvailable() async {
    return await NfcManager.instance.isAvailable();
  }

  Future<String?> readTagUID() async {
    final completer = Completer<String?>();
    
    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          final data = tag.data;
          debugPrint('NFC Tag Discovered: $data');

          final identifier = data['nfca']?['identifier'] ?? 
                             data['mifareultralight']?['identifier'] ?? 
                             data['isodep']?['identifier'] ??
                             data['nfcf']?['identifier'] ??
                             data['nfcv']?['identifier'] ??
                             data['mifareclassic']?['identifier'];

          String? uid;
          if (identifier != null && identifier is Uint8List) {
            uid = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join(':').toUpperCase();
          }
          
          await NfcManager.instance.stopSession();
          if (!completer.isCompleted) completer.complete(uid);
        },
        onError: (e) async {
          debugPrint('NFC Session Error: $e');
          if (!completer.isCompleted) completer.complete(null);
        },
      );

      // Timeout after 20 seconds
      Future.delayed(const Duration(seconds: 20)).then((_) {
        if (!completer.isCompleted) completer.complete(null);
      });

    } catch (e) {
      debugPrint('Error starting NFC session: $e');
      if (!completer.isCompleted) completer.complete(null);
    }
    
    return completer.future;
  }

  // Write token to tag as NDEF record
  Future<bool> writeTokenToTag(String token) async {
    bool success = false;
    try {
      await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
        var ndef = Ndef.from(tag);
        if (ndef == null || !ndef.isWritable) {
          await NfcManager.instance.stopSession(errorMessage: 'Tag is not writable');
          return;
        }

        NdefMessage message = NdefMessage([
          NdefRecord.createText('TOKEN:$token'),
        ]);

        try {
          await ndef.write(message);
          success = true;
          await NfcManager.instance.stopSession();
        } catch (e) {
          await NfcManager.instance.stopSession(errorMessage: 'Write failed');
        }
      });

      int count = 0;
      while (!success && count < 100) {
        await Future.delayed(Duration(milliseconds: 100));
        count++;
      }
    } catch (e) {
      debugPrint('Error writing to NFC: $e');
      await NfcManager.instance.stopSession();
    }
    return success;
  }
}
