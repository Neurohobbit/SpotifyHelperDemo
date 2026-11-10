import 'package:spotify_helper/domain/models/auth_session.dart';

abstract class TokenStorage {
  Future<void> save(AuthSession session);

  Future<AuthSession?> read();

  Future<void> clear();
}
