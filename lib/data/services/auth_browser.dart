abstract class AuthBrowser {
  Future<Uri> authenticate({
    required Uri authorizationUrl,
    required String callbackUrlScheme,
  });
}
