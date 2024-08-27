import 'package:ad_hoc_ident/ad_hoc_ident.dart';
import 'package:ad_hoc_ident_nfc/ad_hoc_ident_nfc.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ad_hoc_ident_nfc_detect_emv_method_channel.dart';

abstract class AdHocIdentNfcDetectEmvPlatform extends PlatformInterface
    implements AdHocIdentityDetector<NfcTag> {
  /// Constructs a AdHocIdentNfcDetectEmvPlatform.
  AdHocIdentNfcDetectEmvPlatform() : super(token: _token);

  static final Object _token = Object();

  static AdHocIdentNfcDetectEmvPlatform _instance =
      MethodChannelAdHocIdentNfcDetectEmv();

  /// The default instance of [AdHocIdentNfcDetectEmvPlatform] to use.
  ///
  /// Defaults to [MethodChannelAdHocIdentNfcDetectEmv].
  static AdHocIdentNfcDetectEmvPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AdHocIdentNfcDetectEmvPlatform] when
  /// they register themselves.
  static set instance(AdHocIdentNfcDetectEmvPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  @override
  Future<AdHocIdentity?> detect(NfcTag input) => throw UnimplementedError(
      'detect(NfcTag input) has not been implemented.');
}
