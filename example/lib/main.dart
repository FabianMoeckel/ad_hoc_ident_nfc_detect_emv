import 'dart:async';

import 'package:ad_hoc_ident/ad_hoc_ident.dart';
import 'package:ad_hoc_ident_nfc/ad_hoc_ident_nfc.dart';
import 'package:ad_hoc_ident_nfc_detect_emv/ad_hoc_ident_nfc_detect_emv.dart';
import 'package:ad_hoc_ident_nfc_scanner_nfc_manager/ad_hoc_ident_nfc_scanner_nfc_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final NfcScanner _nfcScanner;

  Stream<AdHocIdentity?> get _identityStream => _nfcScanner.stream;
  String? _error;

  @override
  void initState() {
    super.initState();

    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String? error;
    try {
      _nfcScanner = NfcManagerNfcScanner(
        detector: NfcDetectorEmv(),
        encrypter: AdHocIdentityEncrypter.fromDelegate(
          // Use a proper encrypter in production code
          // Some implementations are provided in ad_hoc_ident_util_crypto
          (identity) async => identity,
        ),
      );
      final available = await _nfcScanner.isAvailable();
      if (available) {
        _nfcScanner.start();
      } else {
        _error = 'Nfc is unavailable. '
            'Open your phones NFC settings and retry with the buttons above.';
      }
    } on PlatformException catch (e) {
      error = 'Failed to start NFC service: $e';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _error = error;
    });
  }

  @override
  void dispose() {
    _nfcScanner.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: [
            IconButton.outlined(
                onPressed: _nfcScanner.restart,
                icon: const Icon(Icons.restart_alt)),
          ],
        ),
        body: Center(
          child: error != null
              ? Text(error)
              : StreamBuilder(
                  stream: _identityStream,
                  builder: (context, snapshot) => snapshot.hasData
                      ? Text(snapshot.data!.identifier)
                      : snapshot.connectionState == ConnectionState.waiting
                          ? const Text('Please scan a NFC tag.')
                          : snapshot.hasError
                              ? Text(snapshot.error!.toString())
                              : const Text(
                                  'No identity detected for this NFC tag.'),
                ),
        ),
      ),
    );
  }
}
