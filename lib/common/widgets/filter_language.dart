import 'package:badword_guard/badword_guard.dart';

class TextFilter {
  static final _filter = LanguageChecker();

  static String cleanText(String input) {
    return _filter.filterBadWords(input); // Replaces bad words with asterisks
  }
}
