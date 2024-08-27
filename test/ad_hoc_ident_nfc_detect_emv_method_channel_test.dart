import 'package:ad_hoc_ident/ad_hoc_ident.dart';
import 'package:ad_hoc_ident_nfc_detect_emv/src/ad_hoc_ident_nfc_detect_emv_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ad_hoc_ident_nfc_detect_emv_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelAdHocIdentNfcDetectEmv platform =
      MethodChannelAdHocIdentNfcDetectEmv();
  const MethodChannel channel =
      MethodChannel('fabianmoeckel.github.com/adhocident.nfc.detect.emv');
  const testIdentifier = 'testIdentifier';

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return {'identifier': testIdentifier};
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('detect emv identity', () async {
    expect(await platform.detect(MockNfcTag()),
        const AdHocIdentity(type: 'nfc.emv', identifier: testIdentifier));
  });
}
