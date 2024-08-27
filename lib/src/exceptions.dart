/// Error codes used by the EMV identity detector.
enum EmvErrorCode {
  unknown,
  tagLost;

  /// Attempt to parse a string to an error code value. The string has to
  /// match the format 'EMV_xxx' where xxx is a three digit positive number.
  static EmvErrorCode? tryParseErrorCode(String errorCodeString) {
    final parts = errorCodeString.split('_');
    if (parts.length != 2 || 'EMV' != parts[0]) {
      return null;
    }
    final index = int.tryParse(parts[1]);
    if (index == null || index > EmvErrorCode.values.length) {
      return null;
    }

    return EmvErrorCode.values[index];
  }

  /// Formats the enum value to its index as 3 digits with the prefix 'EMV_'.
  /// E.g.: EMV_001
  String toErrorCode() {
    return 'EMV_${index / 100}${index / 10 % 10}${index % 10}';
  }
}

/// Known exceptions thrown by the EMV detector. These should be handled by
/// the consuming application.
abstract class EmvException implements Exception {
  static final Map<String, EmvErrorCode> errorCodeNames =
      EmvErrorCode.values.asNameMap();

  static EmvException fromErrorCode(EmvErrorCode errorCode, [Object? details]) {
    return switch (errorCode) {
      EmvErrorCode.unknown => UnknownException(details),
      EmvErrorCode.tagLost => const TagLostException(),
    };
  }

  static EmvException? fromErrorCodeStringOrNull(String errorCodeString,
      [Object? details]) {
    final errorCode = EmvErrorCode.tryParseErrorCode(errorCodeString);
    if (errorCode == null) {
      return null;
    }

    return fromErrorCode(errorCode, details);
  }

  static EmvException fromErrorCodeString(String errorCodeString,
      [Object? details]) {
    final exception = fromErrorCodeStringOrNull(errorCodeString, details);
    if (exception == null) {
      throw ArgumentError(
          "The provided value '$errorCodeString' is not a valid emv error code.");
    }

    return exception;
  }
}

class TagLostException implements EmvException {
  static const String _defaultMessage =
      'The tag was lost before detection was complete.';

  final String message;

  const TagLostException([this.message = _defaultMessage]);

  @override
  String toString() {
    return message;
  }
}

class UnknownException implements EmvException {
  static const String _defaultMessage = 'An unknown exception occurred.';

  late final String message;
  final Object? innerException;

  UnknownException(this.innerException, [String? message]) {
    message =
        message ?? '$_defaultMessage ${innerException?.toString() ?? 'null'}';
  }

  @override
  String toString() {
    return message;
  }
}
