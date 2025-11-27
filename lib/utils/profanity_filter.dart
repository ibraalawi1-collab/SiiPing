class ProfanityFilter {
  static final List<String> _bannedWords = [
    'badword1',
    'badword2',
    'badword3',
    // TODO: Add comprehensive list of banned words
  ];

  static bool hasProfanity(String text) {
    final lowerText = text.toLowerCase();
    for (final word in _bannedWords) {
      if (lowerText.contains(word.toLowerCase())) {
        return true;
      }
    }
    return false;
  }
}
