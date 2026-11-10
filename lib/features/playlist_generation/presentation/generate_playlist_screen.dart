import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_helper/core/config/app_constants.dart';
import 'package:spotify_helper/features/authentication/application/auth_controller.dart';
import 'package:spotify_helper/features/playlist_generation/application/playlist_generation_controller.dart';
import 'package:spotify_helper/features/playlist_generation/application/playlist_generation_state.dart';

class GeneratePlaylistScreen extends ConsumerStatefulWidget {
  const GeneratePlaylistScreen({super.key});

  @override
  ConsumerState<GeneratePlaylistScreen> createState() =>
      _GeneratePlaylistScreenState();
}

class _GeneratePlaylistScreenState
    extends ConsumerState<GeneratePlaylistScreen> {
  final _promptController = TextEditingController();

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _generate() {
    FocusScope.of(context).unfocus();
    ref
        .read(playlistGenerationControllerProvider.notifier)
        .generate(_promptController.text);
  }

  @override
  Widget build(BuildContext context) {
    final generation = ref.watch(playlistGenerationControllerProvider);
    final busy = generation.isBusy;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.myVibePlaylistName),
        actions: [
          IconButton(
            tooltip: 'Log out',
            icon: const Icon(Icons.logout),
            onPressed: busy
                ? null
                : () => ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              controller: _promptController,
              enabled: !busy,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'What do you want to listen to?',
                hintText: 'Sad punk rock music from the 90s',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: busy ? null : _generate,
              child: const Text('Generate'),
            ),
            const SizedBox(height: 24),
            ..._status(generation, theme),
            for (final track in generation.tracks)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.music_note),
                title: Text(track.name),
                subtitle: Text(track.artistLabel),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _status(PlaylistGenerationState generation, ThemeData theme) {
    return switch (generation.status) {
      GenerationStatus.idle => const [],
      GenerationStatus.findingTracks => _progress('Finding tracks…'),
      GenerationStatus.savingPlaylist =>
        _progress('Saving to ${AppConstants.myVibePlaylistName}…'),
      GenerationStatus.done => [
          Text(
            'Saved ${generation.tracks.length} tracks to '
            '${AppConstants.myVibePlaylistName}',
            style: theme.textTheme.titleMedium,
          ),
        ],
      GenerationStatus.error => [
          Text(
            generation.failure?.message ?? 'Something went wrong.',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ],
    };
  }

  List<Widget> _progress(String label) {
    return [
      const Center(child: CircularProgressIndicator()),
      const SizedBox(height: 12),
      Text(label, textAlign: TextAlign.center),
    ];
  }
}
