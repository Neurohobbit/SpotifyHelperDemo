class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  bool isExpiredOrExpiringSoon({
    DateTime? now,
    Duration skew = const Duration(minutes: 1),
  }) {
    return (now ?? DateTime.now()).add(skew).isAfter(expiresAt);
  }

  factory AuthSession.fromTokenResponse(
    Map<String, dynamic> json, {
    AuthSession? previous,
    DateTime? now,
  }) {
    final accessToken = json['access_token'];
    if (accessToken is! String || accessToken.isEmpty) {
      throw const FormatException('Missing access_token');
    }

    final incomingRefresh = json['refresh_token'];
    final refreshToken = incomingRefresh is String && incomingRefresh.isNotEmpty
        ? incomingRefresh
        : previous?.refreshToken ?? '';
    if (refreshToken.isEmpty) {
      throw const FormatException('Missing refresh_token');
    }

    final expiresIn = json['expires_in'];
    final seconds = expiresIn is int
        ? expiresIn
        : int.tryParse('$expiresIn') ?? 3600;

    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: (now ?? DateTime.now()).add(Duration(seconds: seconds)),
    );
  }
}
