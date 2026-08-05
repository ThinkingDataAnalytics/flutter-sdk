/// Validation mode for [ThinkingAnalyticsAPI.track] property checks.
enum TDPropertyValidationMode {
  /// No validation (default, preserves existing behavior).
  off,

  /// Log validation errors in debug builds; still sends the event.
  warn,

  /// Throw [ArgumentError] when validation fails.
  strict,
}

class TDPropertyValidationResult {
  TDPropertyValidationResult(this.errors);

  final List<String> errors;

  bool get isValid => errors.isEmpty;

  @override
  String toString() => errors.join('; ');
}

/// Validates event names and property payloads before they are sent to native SDK.
class TDPropertyValidator {
  TDPropertyValidator._();

  static const int maxEventNameLength = 50;
  static const int maxPropertyKeyLength = 50;
  static const int maxPropertyCount = 100;
  static const int maxListLength = 100;
  static const int maxNestedDepth = 3;

  static final RegExp _identifierPattern =
      RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$');
  static final RegExp _presetKeyPattern =
      RegExp(r'^#[a-zA-Z][a-zA-Z0-9_]+$');

  static TDPropertyValidationResult validateTrack(
    String eventName,
    Map<String, dynamic> properties,
  ) {
    final errors = <String>[];
    _validateEventName(eventName, errors);
    _validatePropertyMap(properties, errors);
    return TDPropertyValidationResult(errors);
  }

  static void _validateEventName(String eventName, List<String> errors) {
    if (eventName.isEmpty) {
      errors.add('eventName must not be empty');
      return;
    }
    if (eventName.length > maxEventNameLength) {
      errors.add(
          'eventName length must be <= $maxEventNameLength, got ${eventName.length}');
    }
    if (!_identifierPattern.hasMatch(eventName)) {
      errors.add(
          'eventName must start with a letter and contain only letters, digits, and underscores');
    }
  }

  static void _validatePropertyMap(
      Map<String, dynamic> properties, List<String> errors) {
    if (properties.length > maxPropertyCount) {
      errors.add(
          'properties count must be <= $maxPropertyCount, got ${properties.length}');
    }

    properties.forEach((key, value) {
      _validatePropertyKey(key, errors);
      _validatePropertyValue(key, value, errors);
    });
  }

  static void _validatePropertyKey(String key, List<String> errors) {
    if (key.isEmpty) {
      errors.add('property key must not be empty');
      return;
    }
    if (key.length > maxPropertyKeyLength) {
      errors.add(
          'property key "$key" length must be <= $maxPropertyKeyLength, got ${key.length}');
    }

    if (key.startsWith('#')) {
      if (!_presetKeyPattern.hasMatch(key)) {
        errors.add('preset property key "$key" has invalid format');
      }
      return;
    }

    if (!_identifierPattern.hasMatch(key)) {
      errors.add(
          'property key "$key" must start with a letter and contain only letters, digits, and underscores');
    }
  }

  static void _validatePropertyValue(
    String key,
    dynamic value,
    List<String> errors, [
    int depth = 0,
  ]) {
    if (value == null) {
      errors.add('property "$key" value must not be null');
      return;
    }

    if (value is String || value is num || value is bool || value is DateTime) {
      return;
    }

    if (value is List) {
      if (value.length > maxListLength) {
        errors.add(
            'property "$key" list length must be <= $maxListLength, got ${value.length}');
      }
      for (var i = 0; i < value.length; i++) {
        _validatePropertyValue('$key[$i]', value[i], errors, depth);
      }
      return;
    }

    if (value is Map) {
      if (depth >= maxNestedDepth) {
        errors.add('property "$key" nested map depth exceeds $maxNestedDepth');
        return;
      }
      value.forEach((nestedKey, nestedValue) {
        if (nestedKey is! String) {
          errors.add('property "$key" nested map keys must be strings');
          return;
        }
        _validatePropertyKey(nestedKey, errors);
        _validatePropertyValue('$key.$nestedKey', nestedValue, errors, depth + 1);
      });
      return;
    }

    errors.add(
        'property "$key" has unsupported type ${value.runtimeType}; allowed: String, num, bool, DateTime, List, Map');
  }
}
