import 'dart:convert';
import 'dart:typed_data';

import 'package:ad_hoc_ident/src/ad_hoc_identity.dart';
import 'package:ad_hoc_ident_nfc/src/nfc_tag.dart';
import 'package:ad_hoc_ident_nfc_detect_emv/ad_hoc_ident_nfc_detect_emv.dart';
import 'package:ad_hoc_ident_nfc_detect_emv/src/ad_hoc_ident_nfc_detect_emv_method_channel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockAdHocIdentNfcDetectEmvPlatform
    with MockPlatformInterfaceMixin
    implements AdHocIdentNfcDetectEmvPlatform {
  final AdHocIdentity testIdentity;

  MockAdHocIdentNfcDetectEmvPlatform(this.testIdentity);

  @override
  Future<AdHocIdentity?> detect(NfcTag input) async {
    return testIdentity;
  }
}

class MockNfcTag implements NfcTag {
  @override
  Future<Uint8List?> getAt() {
    // TODO: implement getAt
    throw UnimplementedError();
  }

  @override
  String get handle => 'mock handle';

  @override
  Future<Uint8List?> get identifier async =>
      Uint8List.fromList(utf8.encode('mock identifier').toList());

  @override
  get raw => Object();

  @override
  Future<Uint8List?> transceive(Uint8List data) {
    // TODO: implement transceive
    throw UnimplementedError();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final AdHocIdentNfcDetectEmvPlatform initialPlatform =
      AdHocIdentNfcDetectEmvPlatform.instance;

  test('$MethodChannelAdHocIdentNfcDetectEmv is the default instance', () {
    expect(
        initialPlatform, isInstanceOf<MethodChannelAdHocIdentNfcDetectEmv>());
  });

  test('detect emv identity', () async {
    const testIdentity =
        AdHocIdentity(type: 'test', identifier: 'testIdentifier');
    NfcDetectorEmv adHocIdentNfcDetectEmvPlugin = NfcDetectorEmv();
    MockAdHocIdentNfcDetectEmvPlatform fakePlatform =
        MockAdHocIdentNfcDetectEmvPlatform(testIdentity);
    AdHocIdentNfcDetectEmvPlatform.instance = fakePlatform;

    expect(
        await adHocIdentNfcDetectEmvPlugin.detect(MockNfcTag()), testIdentity);
  });
}
