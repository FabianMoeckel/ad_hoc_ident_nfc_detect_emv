package com.github.fabianmoeckel.adhocident.nfc.ad_hoc_ident_nfc_detect_emv;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.CancellationException;
import java.util.concurrent.TimeUnit;

import io.flutter.plugin.common.MethodChannel;

public class BlockingQueueResult<TSuccessResult> implements MethodChannel.Result {
    // needed as blocking queues do not accept null values on add()
    final static Object nullDummy = new Object();
    final private ArrayBlockingQueue<Object> resultQueue = new ArrayBlockingQueue<>(1);
    final private Class<TSuccessResult> successClass;
    final private String calledMethod;

    public BlockingQueueResult(Class<TSuccessResult> successClass, String calledMethod) {
        this.successClass = successClass;
        this.calledMethod = calledMethod;
    }

    @Override
    public void success(@Nullable Object result) {
        resultQueue.add(result != null ? result : nullDummy);
    }

    @Override
    public void error(@NonNull String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {
        resultQueue.add(new Exception(errorMessage));
    }

    @Override
    public void notImplemented() {
        resultQueue.add(new UnsupportedOperationException(
                "The method '" + calledMethod + "' was not available on the method channel."));
    }

    public TSuccessResult getOrThrowBlocking(long timeoutMs) throws Exception {
        final Object resultValue = resultQueue.poll(timeoutMs, TimeUnit.MILLISECONDS);
        if (resultValue == null) {
            throw new CancellationException("The result timed out.");
        }

        if (resultValue == nullDummy) {
            return null;
        }

        if (successClass.isInstance(resultValue)) {
            return successClass.cast(resultValue);
        }

        throw (Exception) resultValue;
    }
}
