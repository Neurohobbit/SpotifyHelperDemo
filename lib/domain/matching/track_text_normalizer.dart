/// Turns titles and artist names into comparable keys.
abstract final class TrackTextNormalizer {
  static final _quotes = RegExp(r"['’`]");
  static final _punctuation = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);
  static final _versionSuffixes = RegExp(
    r'\b(remastered|remaster|radio edit|live|deluxe|explicit|bonus track|album version|single version)\b',
  );
  static final _years = RegExp(r'\b(19|20)\d{2}\b');
  static final _spaces = RegExp(r'\s+');

  static String normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll(_quotes, '')
        .replaceAll(_punctuation, ' ')
        .replaceAll(_versionSuffixes, ' ')
        .replaceAll(_years, ' ')
        .replaceAll(_spaces, ' ')
        .trim();
  }

  /// "The Offspring", "offspring" and "Off-Spring" share one key.
  static String artistKey(String value) {
    var text = normalize(value);
    if (text.startsWith('the ')) {
      text = text.substring(4);
    }
    return text.replaceAll(' ', '');
  }

  static bool sameTitle(String left, String right) {
    final a = normalize(left);
    final b = normalize(right);
    return a.isNotEmpty && a.replaceAll(' ', '') == b.replaceAll(' ', '');
  }
}
