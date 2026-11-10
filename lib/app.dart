import 'package:flutter/material.dart';
import 'package:spotify_helper/features/authentication/presentation/auth_gate.dart';

class SpotifyHelperApp extends StatelessWidget {
  const SpotifyHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Helper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1DB954),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
