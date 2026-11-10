import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_helper/features/authentication/application/auth_controller.dart';
import 'package:spotify_helper/features/authentication/application/auth_state.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final isBusy = auth.status == AuthStatus.authenticating;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Icon(
                Icons.library_music_rounded,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text('Spotify Helper', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text(
                'Connect Spotify to turn a vibe description into your My Vibe playlist.',
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              if (auth.failure != null) ...[
                Text(
                  auth.failure!.message,
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isBusy
                      ? null
                      : () => ref.read(authControllerProvider.notifier).login(),
                  child: Text(isBusy ? 'Connecting…' : 'Connect Spotify'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
