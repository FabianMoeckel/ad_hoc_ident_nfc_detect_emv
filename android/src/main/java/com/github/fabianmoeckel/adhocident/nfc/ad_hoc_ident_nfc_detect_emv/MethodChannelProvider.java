package com.github.fabianmoeckel.adhocident.nfc.ad_hoc_ident_nfc_detect_emv;

import android.os.Handler;

import androidx.annotation.NonNull;

import com.github.devnied.emvnfccard.exception.CommunicationException;
import com.github.devnied.emvnfccard.parser.IProvider;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class MethodChannelProvider implements IProvider {
    private static final String transceiveMethodName = "transceive";
    private static final String getAtMethodName = "getAt";

    private final Handler handler;
    private final MethodChannel methodChannel;
    private final String tagHandle;

    public MethodChannelProvider(
            @NonNull Handler handler,
            @NonNull MethodChannel methodChannel,
            @NonNull String tagHandle) {
        this.handler = handler;
        this.methodChannel = methodChannel;
        this.tagHandle = tagHandle;
    }

    @Override
    public byte[] transceive(byte[] pCommand) throws CommunicationException {
        final Map<String, Object> args = new HashMap<String, Object>() {{
            put("handle", tagHandle);
            put("data", pCommand);
        }};
        final BlockingQueueResult<byte[]> result = new BlockingQueueResult<>(
                byte[].class, transceiveMethodName);

        // send command to emv card
        handler.post(() -> methodChannel.invokeMethod(transceiveMethodName, args, result));

        try {
            final byte[] resultValue = result.getOrThrowBlocking(1000);
            if (resultValue == null) {
                // should never be hit
                throw new CommunicationException(
                        "Unexpected null result during transceive call.");
            }
            return resultValue;
        } catch (Exception ex) {
            throw new CommunicationException(ex.getMessage());
        }
    }

    @Override
    public byte[] getAt() {
        final Map<String, Object> args = new HashMap<String, Object>() {{
            put("handle", tagHandle);
        }};
        final BlockingQueueResult<byte[]> result = new BlockingQueueResult<>(
                byte[].class, getAtMethodName);

        // send command to emv card
        handler.post(() -> methodChannel.invokeMethod("getAt", args, result));

        try {
            // null is a valid return type of the result
            return result.getOrThrowBlocking(1000);
        } catch (Exception ex) {
            // the interface does not expect Exceptions, so we ignore the error
            // the getAt function is not required for the implemented use-case anyways
            return null;
        }
    }
}
