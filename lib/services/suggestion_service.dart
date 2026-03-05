import 'dart:async';
import '../data/word_repository.dart';

/// Service for providing intelligent word suggestions
class SuggestionService {
  final WordRepository _repository;
  Timer? _debounceTimer;

  SuggestionService(this._repository);

  /// Get suggestions based on current input
  /// Returns a list of suggested words/phrases
  Future<List<String>> getSuggestions({
    required String input,
    required String language,
    int maxSuggestions = 20,
  }) async {
    if (input.trim().isEmpty) return [];

    final suggestions = <String>{};

    try {
      // Only get words that start with the input (prefix matches)
      final prefixMatches = await _getPrefixMatches(input, language);
      suggestions.addAll(prefixMatches);
    } catch (e) {
      print('Error getting suggestions: $e');
    }

    // Remove the exact input and sort by relevance
    suggestions.remove(input.trim());
    final sortedSuggestions = _sortByRelevance(suggestions.toList(), input);

    return sortedSuggestions.take(maxSuggestions).toList();
  }

  /// Get words that start with the input
  Future<List<String>> _getPrefixMatches(String input, String language) async {
    try {
      final allWords = await _repository.getAllWordsForLanguage(language);
      final normalizedInput = input.trim().toLowerCase();

      return allWords
          .where((word) => word.toLowerCase().startsWith(normalizedInput))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get words with fuzzy matching (spelling corrections)
  Future<List<String>> _getFuzzyMatches(String input, String language) async {
    try {
      final allWords = await _repository.getAllWordsForLanguage(language);
      final normalizedInput = input.trim().toLowerCase();

      return allWords
          .where((word) {
            final normalizedWord = word.toLowerCase();
            // Simple fuzzy matching: allow 1-2 character differences
            return _levenshteinDistance(normalizedWord, normalizedInput) <= 2 &&
                normalizedWord.length >= normalizedInput.length;
          })
          .take(5)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get frequently used words
  Future<List<String>> _getFrequentWords(String input, String language) async {
    try {
      // Get recent searches and favorites as they indicate frequently used words
      final recentWords = await _repository.getRecentSearches();
      final favorites = await _repository.getAllFavorites();

      final frequentWords = <String>{};
      final normalizedInput = input.trim().toLowerCase();

      // Add words from recent searches
      for (final recent in recentWords) {
        if (recent['source_language'] == language) {
          final word = recent['source_word'] as String;
          if (word.toLowerCase().contains(normalizedInput)) {
            frequentWords.add(word);
          }
        }
      }

      // Add words from favorites
      for (final fav in favorites) {
        if (fav['language'] == language) {
          final word = fav['word'] as String;
          if (word.toLowerCase().contains(normalizedInput)) {
            frequentWords.add(word);
          }
        }
      }

      return frequentWords.take(3).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get common phrases containing the input
  Future<List<String>> _getCommonPhrases(String input, String language) async {
    try {
      // Get multi-word phrases from the database
      final allWords = await _repository.getAllWordsForLanguage(language);
      final normalizedInput = input.trim().toLowerCase();

      return allWords
          .where(
            (word) =>
                word.contains(' ') && // Multi-word phrases
                word.toLowerCase().contains(normalizedInput),
          )
          .take(3)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get contextual predictions based on recent usage
  Future<List<String>> _getContextualPredictions(
    String input,
    String language,
  ) async {
    try {
      final recentSearches = await _repository.getRecentSearches();
      final normalizedInput = input.trim().toLowerCase();

      // Get words that were searched after similar words
      final predictions = <String>{};
      for (final recent in recentSearches) {
        if (recent['source_language'] == language) {
          final word = recent['source_word'] as String;
          if (word.toLowerCase().startsWith(normalizedInput)) {
            predictions.add(word);
          }
        }
      }

      return predictions.take(3).toList();
    } catch (e) {
      return [];
    }
  }

  /// Sort suggestions by relevance to input
  List<String> _sortByRelevance(List<String> suggestions, String input) {
    final normalizedInput = input.trim().toLowerCase();

    suggestions.sort((a, b) {
      final aLower = a.toLowerCase();
      final bLower = b.toLowerCase();

      // Exact prefix matches come first
      final aStartsWith = aLower.startsWith(normalizedInput);
      final bStartsWith = bLower.startsWith(normalizedInput);

      if (aStartsWith && !bStartsWith) return -1;
      if (!aStartsWith && bStartsWith) return 1;

      // Then sort alphabetically (case-insensitive) like Google Translate
      return aLower.compareTo(bLower);
    });

    return suggestions;
  }

  /// Calculate Levenshtein distance for fuzzy matching
  int _levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final len1 = s1.length;
    final len2 = s2.length;
    final matrix = List.generate(len1 + 1, (i) => List.filled(len2 + 1, 0));

    for (var i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= len1; i++) {
      for (var j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[len1][len2];
  }

  /// Debounce suggestions to avoid excessive calls
  void debouncedGetSuggestions({
    required String input,
    required String language,
    required Function(List<String>) onSuggestions,
    Duration delay = const Duration(milliseconds: 300),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () async {
      final suggestions = await getSuggestions(
        input: input,
        language: language,
      );
      onSuggestions(suggestions);
    });
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}
