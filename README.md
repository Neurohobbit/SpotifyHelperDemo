# Spotify Helper

Turns a text description of a mood into a playlist: OpenAI suggests songs, and the ones found on Spotify are saved to your "My Vibe" playlist.

## Build environment

- Flutter 3.38.10 (stable), Dart 3.10
- Android: Android SDK, JDK 17 (Android Gradle Plugin 8.9, Gradle 8.12)
- iOS: macOS, Xcode, CocoaPods, iOS 12.0+
- An app in the [Spotify Developer Dashboard](https://developer.spotify.com/dashboard) with the redirect URI `spotifyhelper://auth/callback`
- An OpenAI API key
