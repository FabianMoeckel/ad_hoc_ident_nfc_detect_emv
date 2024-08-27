package com.github.fabianmoeckel.adhocident.nfc.ad_hoc_ident_nfc_detect_emv;

import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.github.devnied.emvnfccard.exception.CommunicationException;
import com.github.devnied.emvnfccard.model.EmvCard;
import com.github.devnied.emvnfccard.parser.EmvTemplate;
import com.github.devnied.emvnfccard.parser.IProvider;

import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.StandardMethodCodec;

/**
 * AdHocIdentNfcDetectEmvPlugin
 */
public class AdHocIdentNfcDetectEmvPlugin implements FlutterPlugin, MethodCallHandler {

    private static final EmvTemplate.Config emvConfig =
            EmvTemplate.Config().setContactLess(true) // Enable contact less reading (default: true)
                    .setReadAllAids(false) // Read all aids in card (default: true)
                    .setReadTransactions(false) // Read all transactions (default: true)
                    .setReadCplc(false) // Read and extract CPCLC data (default: false)
                    .setRemoveDefaultParsers(false) // Remove default parsers for GeldKarte and EmvCard (default: false)
                    .setReadAt(false) // Read and extract ATR/ATS and description
            ;

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel channel;
    private final Handler handler = new Handler(Looper.getMainLooper());

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        final BinaryMessenger messenger = flutterPluginBinding.getBinaryMessenger();
        BinaryMessenger.TaskQueue taskQueue =
                messenger.makeBackgroundTaskQueue();
        channel = new MethodChannel(messenger,
                "fabianmoeckel.github.com/adhocident.nfc.detect.emv",
                StandardMethodCodec.INSTANCE,
                taskQueue);
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        if (call.method.equals("detect")) {
            final String tagHandle = (String) call.arguments;
            detect(tagHandle, result);
        } else {
            result.notImplemented();
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    public void detect(@NonNull String tagHandle, @NonNull MethodChannel.Result result) {
        try {
            IProvider provider = new MethodChannelProvider(handler, channel, tagHandle);
            EmvTemplate parser = EmvTemplate.Builder().setProvider(provider).setConfig(emvConfig).build();
            EmvCard card = parser.readEmvCard();
            final String cardNumber = card.getCardNumber();
            if (cardNumber != null) {
                final AdHocIdentity identity = new AdHocIdentity("nfc.emv", cardNumber);
                final Map<String, String> identityMap = identity.toMap();
                handler.post(() -> result.success(identityMap));
                return;
            }
        } catch (CommunicationException e) {
            handler.post(() -> result.error(EmvErrorCode.tagLost.toErrorCode(),
                    e.getMessage(),
                    e));
            return;
        } catch (Exception e) {
            handler.post(() -> result.error(EmvErrorCode.unknown.toErrorCode(),
                    e.getMessage(),
                    e));
            return;
        }
        handler.post(() -> result.success(null));
    }
}