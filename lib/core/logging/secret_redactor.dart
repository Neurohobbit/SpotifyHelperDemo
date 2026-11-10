abstract final class SecretRedactor {
  static const redacted = '***';

  static const _sensitiveKeys = {
    'authorization',
    'api_key',
    'access_token',
    'refresh_token',
    'client_secret',
    'openai_api_key',
    'token',
  };

  static Map<String, Object?> redactContext(Map<String, Object?> context) {
    return {
      for (final entry in context.entries)
        entry.key: _sensitiveKeys.contains(entry.key.toLowerCase())
            ? redacted
            : entry.value,
    };
  }
}
