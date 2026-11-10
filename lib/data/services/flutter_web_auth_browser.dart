import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:spotify_helper/core/errors/app_failure.dart';
import 'package:spotify_helper/data/services/auth_browser.dart';
import 'package:url_launcher/url_launcher.dart';

class FlutterWebAuthBrowser implements AuthBrowser {
  const FlutterWebAuthBrowser();

  @override
  Future<Uri> authenticate({
    required Uri authorizationUrl,
    required String callbackUrlScheme,
  }) async {
    if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
      return _authenticateAndroid(
        authorizationUrl: authorizationUrl,
        callbackUrlScheme: callbackUrlScheme,
      );
    }

    final result = await FlutterWebAuth2.authenticate(
      url: authorizationUrl.toString(),
      callbackUrlScheme: callbackUrlScheme,
    );
    return Uri.parse(result);
  }

  Future<Uri> _authenticateAndroid({
    required Uri authorizationUrl,
    required String callbackUrlScheme,
  }) async {
    final completer = Completer<Uri>();
    final subscription = AppLinks().uriLinkStream.listen((uri) {
      if (uri.scheme == callbackUrlScheme && !completer.isCompleted) {
        completer.complete(uri);
      }
    });

    try {
      final launched = await launchUrl(
        authorizationUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw const AuthFailure();
      }

      return await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => throw const AuthCancelledFailure(),
      );
    } finally {
      await subscription.cancel();
    }
  }
}
