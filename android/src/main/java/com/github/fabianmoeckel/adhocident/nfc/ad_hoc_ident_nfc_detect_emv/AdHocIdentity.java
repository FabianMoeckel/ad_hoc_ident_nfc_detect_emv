package com.github.fabianmoeckel.adhocident.nfc.ad_hoc_ident_nfc_detect_emv;

import java.util.HashMap;
import java.util.Map;

public class AdHocIdentity {
    final String type;
    final String identifier;

    public AdHocIdentity(String type, String identifier) {
        this.type = type;
        this.identifier = identifier;
    }

    public Map<String, String> toMap() {
        final Map<String, String> map = new HashMap<>();
        map.put("type", type);
        map.put("identifier", identifier);
        return map;
    }
}
