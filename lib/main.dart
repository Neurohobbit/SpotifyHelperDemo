import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_helper/app.dart';

void main() {
  runApp(const ProviderScope(child: SpotifyHelperApp()));
}
