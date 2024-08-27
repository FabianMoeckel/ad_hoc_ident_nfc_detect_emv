import 'package:ad_hoc_ident/ad_hoc_ident.dart';
import 'package:ad_hoc_ident_nfc/ad_hoc_ident_nfc.dart';

import 'ad_hoc_ident_nfc_detect_emv_platform_interface.dart';

class NfcDetectorEmv implements AdHocIdentityDetector<NfcTag> {
  @override
  Future<AdHocIdentity?> detect(NfcTag input) =>
      AdHocIdentNfcDetectEmvPlatform.instance.detect(input);
}
