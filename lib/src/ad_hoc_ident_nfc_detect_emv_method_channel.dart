import 'package:ad_hoc_ident/ad_hoc_ident.dart';
import 'package:ad_hoc_ident_nfc/ad_hoc_ident_nfc.dart';
import 'package:ad_hoc_ident_nfc_detect_emv/ad_hoc_ident_nfc_detect_emv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

const String _methodChannelName =
    'fabianmoeckel.github.com/adhocident.nfc.detect.emv';
const String _methodDetect = 'detect';
const String _methodTransceive = 'transceive';
const String _methodGetAt = 'getAt';
const String _handleArgKey = 'handle';
const String _transceiveDataArgKey = 'data';

class MethodChannelAdHocIdentNfcDetectEmv
    extends AdHocIdentNfcDetectEmvPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel(_methodChannelName);

  final Map<String, NfcTag> _currentTags = {};

  MethodChannelAdHocIdentNfcDetectEmv() {
    methodChannel.setMethodCallHandler(_handleMethodCall);
  }

  @override
  Future<AdHocIdentity?> detect(NfcTag input) async {
    _currentTags[input.handle] = input;
    try {
      final mapResult =
          await methodChannel.invokeMapMethod(_methodDetect, input.handle);
      _currentTags.remove(input.handle);
      final identity = _toIdentity(mapResult);
      return identity;
    } on PlatformException catch (error) {
      final emvError =
          EmvException.fromErrorCodeStringOrNull(error.code, error);
      if (emvError == null) {
        rethrow;
      }
      throw emvError;
    }
  }

  Future _handleMethodCall(MethodCall call) async {
    final handle = call.arguments[_handleArgKey];
    if (handle == null || handle is! String) {
      return null;
    }

    final tag = _currentTags[handle];
    if (tag == null) {
      return null;
    }
    switch (call.method) {
      case _methodTransceive:
        final data = call.arguments[_transceiveDataArgKey];
        if (data == null || data is! Uint8List) {
          return null;
        }
        final result = await tag.transceive(data);
        return result;
      case _methodGetAt:
        final result = await tag.getAt();
        return result;
    }
  }

  AdHocIdentity? _toIdentity(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return null;
    }
    final identifierString = map['identifier'];
    if (identifierString == null || identifierString is! String) {
      return null;
    }
    final identity =
        AdHocIdentity(type: 'nfc.emv', identifier: identifierString);
    return identity;
  }
}
