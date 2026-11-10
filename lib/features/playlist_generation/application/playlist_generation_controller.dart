import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_helper/core/di/providers.dart';
import 'package:spotify_helper/core/errors/app_failure.dart';
import 'package:spotify_helper/features/authentication/application/auth_controller.dart';
import 'package:spotify_helper/features/playlist_generation/application/playlist_generation_state.dart';

class PlaylistGenerationController
    extends AutoDisposeNotifier<PlaylistGenerationState> {
  @override
  PlaylistGenerationState build() => const PlaylistGenerationState();

  Future<void> generate(String prompt) async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) {
      _fail(const AuthFailure());
      return;
    }

    try {
      final tracks = await ref.read(generatePlaylistUseCaseProvider).execute(
            userPrompt: prompt,
            ownerId: user.id,
            onProgress: (status) =>
                state = PlaylistGenerationState(status: status),
          );
      state = PlaylistGenerationState(
        status: GenerationStatus.done,
        tracks: tracks,
      );
    } on AppFailure catch (failure) {
      _fail(failure);
    } catch (_) {
      _fail(const SpotifyFailure('Something went wrong. Please try again.'));
    }
  }

  void _fail(AppFailure failure) {
    state = PlaylistGenerationState(
      status: GenerationStatus.error,
      failure: failure,
    );
  }
}

final playlistGenerationControllerProvider = AutoDisposeNotifierProvider<
    PlaylistGenerationController, PlaylistGenerationState>(
  PlaylistGenerationController.new,
);
