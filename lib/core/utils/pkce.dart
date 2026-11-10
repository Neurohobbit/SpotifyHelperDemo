import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Proof Key for Code Exchange (RFC 7636) helpers for Spotify login.
abstract final class Pkce {
  static String verifier() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return _base64UrlNoPadding(bytes);
  }

  static String challenge(String verifier) {
    return _base64UrlNoPadding(sha256.convert(utf8.encode(verifier)).bytes);
  }

  static String _base64UrlNoPadding(List<int> bytes) {
    return base64UrlEncode(bytes).replaceAll('=', '');
  }
}
