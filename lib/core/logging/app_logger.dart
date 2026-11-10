import 'package:logger/logger.dart';
import 'package:spotify_helper/core/logging/secret_redactor.dart';

class AppLogger {
  AppLogger({Logger? logger})
      : _logger = logger ??
            Logger(
              printer: PrettyPrinter(
                methodCount: 0,
                dateTimeFormat: DateTimeFormat.none,
                noBoxingByDefault: true,
              ),
            );

  final Logger _logger;

  void info(String message, {Map<String, Object?>? context}) {
    _logger.i(_compose(message, context));
  }

  void warning(String message, {Map<String, Object?>? context}) {
    _logger.w(_compose(message, context));
  }

  String _compose(String message, Map<String, Object?>? context) {
    if (context == null || context.isEmpty) {
      return message;
    }
    return '$message ${SecretRedactor.redactContext(context)}';
  }
}
