package com.github.fabianmoeckel.adhocident.nfc.ad_hoc_ident_nfc_detect_emv;

public enum EmvErrorCode {
    unknown, tagLost;

    public String toErrorCode() {
        return String.format("EMV_%04d", this.ordinal());
    }
}