// ignore: unused_import
import 'package:sqflite/sqflite.dart';
import 'word_database.dart';

class WordRepository {
  final WordDatabase _db = WordDatabase.instance;

  Future<List<String>> _searchWordsByTable(String table, String query) async {
    try {
      final db = await _db.database;
      if (query.isEmpty) {
        return [];
      }
      final searchPattern = '${query.toLowerCase()}%';
      final results = await db.query(
        table,
        where: 'LOWER(word) LIKE ?',
        whereArgs: [searchPattern],
        orderBy: 'word COLLATE NOCASE',
        limit: 100,
      );
      final words = results.map((row) => row['word'] as String).toList();
      print('Search in $table for "$query": found ${words.length} results');
      return words;
    } catch (e, stackTrace) {
      print('Error searching $table for "$query": $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  // Get Sinama words that match a search query
  Future<List<String>> searchSinamaWords(String query) {
    return _searchWordsByTable('sinama_words', query);
  }

  // Get Cebuano words that match a search query
  Future<List<String>> searchCebuanoWords(String query) {
    return _searchWordsByTable('cebuano_words', query);
  }

  // Get Tagalog words that match a search query
  Future<List<String>> searchTagalogWords(String query) {
    return _searchWordsByTable('tagalog_words', query);
  }

  // Get English words that match a search query
  Future<List<String>> searchEnglishWords(String query) {
    return _searchWordsByTable('english_words', query);
  }

  // Get translations for a Sinama word
  Future<Map<String, List<String>>> getSinamaTranslations(
    String sinamaWord,
  ) async {
    try {
      final db = await _db.database;

      // Get Sinama word ID
      final sinamaResult = await db.query(
        'sinama_words',
        where: 'word = ?',
        whereArgs: [sinamaWord],
        limit: 1,
      );

      if (sinamaResult.isEmpty) {
        print('Sinama word "$sinamaWord" not found in database');
        return {'cebuano': [], 'tagalog': [], 'english': []};
      }

      final sinamaId = sinamaResult.first['id'] as int;

      // Get Cebuano translations
      final cebuanoResults = await db.rawQuery(
        '''
        SELECT c.word 
        FROM cebuano_words c
        INNER JOIN sinama_cebuano_translations t ON c.id = t.cebuano_id
        WHERE t.sinama_id = ?
      ''',
        [sinamaId],
      );

      // Get Tagalog translations
      final tagalogResults = await db.rawQuery(
        '''
        SELECT t.word 
        FROM tagalog_words t
        INNER JOIN sinama_tagalog_translations st ON t.id = st.tagalog_id
        WHERE st.sinama_id = ?
      ''',
        [sinamaId],
      );

      // Get English translations
      final englishResults = await db.rawQuery(
        '''
        SELECT e.word 
        FROM english_words e
        INNER JOIN sinama_english_translations se ON e.id = se.english_id
        WHERE se.sinama_id = ?
      ''',
        [sinamaId],
      );

      final result = {
        'cebuano': cebuanoResults.map((row) => row['word'] as String).toList(),
        'tagalog': tagalogResults.map((row) => row['word'] as String).toList(),
        'english': englishResults.map((row) => row['word'] as String).toList(),
      };

      print(
        'Sinama translations for "$sinamaWord": Cebuano=${result['cebuano']!.length}, Tagalog=${result['tagalog']!.length}, English=${result['english']!.length}',
      );
      return result;
    } catch (e, stackTrace) {
      print('Error getting Sinama translations for "$sinamaWord": $e');
      print('Stack trace: $stackTrace');
      return {'cebuano': [], 'tagalog': [], 'english': []};
    }
  }

  // Get translations for a Cebuano word (reverse lookup)
  Future<List<String>> getCebuanoToSinama(String cebuanoWord) async {
    final db = await _db.database;

    // Get Cebuano word ID
    final cebuanoResult = await db.query(
      'cebuano_words',
      where: 'word = ?',
      whereArgs: [cebuanoWord],
      limit: 1,
    );

    if (cebuanoResult.isEmpty) {
      return [];
    }

    final cebuanoId = cebuanoResult.first['id'] as int;

    // Get Sinama translations
    final results = await db.rawQuery(
      '''
      SELECT s.word 
      FROM sinama_words s
      INNER JOIN sinama_cebuano_translations t ON s.id = t.sinama_id
      WHERE t.cebuano_id = ?
    ''',
      [cebuanoId],
    );

    return results.map((row) => row['word'] as String).toList();
  }

  // Get translations for Tagalog word (reverse lookup)
  Future<List<String>> getTagalogToSinama(String tagalogWord) async {
    final db = await _db.database;

    final tagalogResult = await db.query(
      'tagalog_words',
      where: 'word = ?',
      whereArgs: [tagalogWord],
      limit: 1,
    );

    if (tagalogResult.isEmpty) {
      return [];
    }

    final tagalogId = tagalogResult.first['id'] as int;

    final results = await db.rawQuery(
      '''
      SELECT s.word 
      FROM sinama_words s
      INNER JOIN sinama_tagalog_translations t ON s.id = t.sinama_id
      WHERE t.tagalog_id = ?
    ''',
      [tagalogId],
    );

    return results.map((row) => row['word'] as String).toList();
  }

  // Get translations for English word (reverse lookup)
  Future<List<String>> getEnglishToSinama(String englishWord) async {
    final db = await _db.database;

    final englishResult = await db.query(
      'english_words',
      where: 'word = ?',
      whereArgs: [englishWord],
      limit: 1,
    );

    if (englishResult.isEmpty) {
      return [];
    }

    final englishId = englishResult.first['id'] as int;

    final results = await db.rawQuery(
      '''
      SELECT s.word 
      FROM sinama_words s
      INNER JOIN sinama_english_translations t ON s.id = t.sinama_id
      WHERE t.english_id = ?
    ''',
      [englishId],
    );

    return results.map((row) => row['word'] as String).toList();
  }

  // Get translations for Tagalog word to Cebuano (direct lookup using matching IDs)
  Future<List<String>> getTagalogToCebuano(String tagalogWord) async {
    final db = await _db.database;

    final tagalogResult = await db.query(
      'tagalog_words',
      where: 'word = ?',
      whereArgs: [tagalogWord],
      limit: 1,
    );

    if (tagalogResult.isEmpty) {
      return [];
    }

    final tagalogId = tagalogResult.first['id'] as int;

    // Since IDs match, directly get Cebuano word with same ID
    final cebuanoResult = await db.query(
      'cebuano_words',
      where: 'id = ?',
      whereArgs: [tagalogId],
      limit: 1,
    );

    if (cebuanoResult.isEmpty) {
      return [];
    }

    return [cebuanoResult.first['word'] as String];
  }

  // Get translations for Cebuano word to Tagalog (direct lookup using matching IDs)
  Future<List<String>> getCebuanoToTagalog(String cebuanoWord) async {
    final db = await _db.database;

    final cebuanoResult = await db.query(
      'cebuano_words',
      where: 'word = ?',
      whereArgs: [cebuanoWord],
      limit: 1,
    );

    if (cebuanoResult.isEmpty) {
      return [];
    }

    final cebuanoId = cebuanoResult.first['id'] as int;

    // Since IDs match, directly get Tagalog word with same ID
    final tagalogResult = await db.query(
      'tagalog_words',
      where: 'id = ?',
      whereArgs: [cebuanoId],
      limit: 1,
    );

    if (tagalogResult.isEmpty) {
      return [];
    }

    return [tagalogResult.first['word'] as String];
  }

  // Get translations for Tagalog word to English (direct lookup using matching IDs)
  Future<List<String>> getTagalogToEnglish(String tagalogWord) async {
    final db = await _db.database;

    final tagalogResult = await db.query(
      'tagalog_words',
      where: 'word = ?',
      whereArgs: [tagalogWord],
      limit: 1,
    );

    if (tagalogResult.isEmpty) {
      return [];
    }

    final tagalogId = tagalogResult.first['id'] as int;

    // Since IDs match, directly get English word with same ID
    final englishResult = await db.query(
      'english_words',
      where: 'id = ?',
      whereArgs: [tagalogId],
      limit: 1,
    );

    if (englishResult.isEmpty) {
      return [];
    }

    return [englishResult.first['word'] as String];
  }

  // Get translations for English word to Tagalog (direct lookup using matching IDs)
  Future<List<String>> getEnglishToTagalog(String englishWord) async {
    final db = await _db.database;

    final englishResult = await db.query(
      'english_words',
      where: 'word = ?',
      whereArgs: [englishWord],
      limit: 1,
    );

    if (englishResult.isEmpty) {
      return [];
    }

    final englishId = englishResult.first['id'] as int;

    // Since IDs match, directly get Tagalog word with same ID
    final tagalogResult = await db.query(
      'tagalog_words',
      where: 'id = ?',
      whereArgs: [englishId],
      limit: 1,
    );

    if (tagalogResult.isEmpty) {
      return [];
    }

    return [tagalogResult.first['word'] as String];
  }

  // Get translations for Cebuano word to English (direct lookup using matching IDs)
  Future<List<String>> getCebuanoToEnglish(String cebuanoWord) async {
    final db = await _db.database;

    final cebuanoResult = await db.query(
      'cebuano_words',
      where: 'word = ?',
      whereArgs: [cebuanoWord],
      limit: 1,
    );

    if (cebuanoResult.isEmpty) {
      return [];
    }

    final cebuanoId = cebuanoResult.first['id'] as int;

    // Since IDs match, directly get English word with same ID
    final englishResult = await db.query(
      'english_words',
      where: 'id = ?',
      whereArgs: [cebuanoId],
      limit: 1,
    );

    if (englishResult.isEmpty) {
      return [];
    }

    return [englishResult.first['word'] as String];
  }

  // Get translations for English word to Cebuano (direct lookup using matching IDs)
  Future<List<String>> getEnglishToCebuano(String englishWord) async {
    final db = await _db.database;

    final englishResult = await db.query(
      'english_words',
      where: 'word = ?',
      whereArgs: [englishWord],
      limit: 1,
    );

    if (englishResult.isEmpty) {
      return [];
    }

    final englishId = englishResult.first['id'] as int;

    // Since IDs match, directly get Cebuano word with same ID
    final cebuanoResult = await db.query(
      'cebuano_words',
      where: 'id = ?',
      whereArgs: [englishId],
      limit: 1,
    );

    if (cebuanoResult.isEmpty) {
      return [];
    }

    return [cebuanoResult.first['word'] as String];
  }

  // Generic search based on language
  Future<List<String>> searchWords(String language, String query) async {
    switch (language.toUpperCase()) {
      case 'SINAMA':
        return searchSinamaWords(query);
      case 'CEBUANO':
        return searchCebuanoWords(query);
      case 'TAGALOG':
        return searchTagalogWords(query);
      case 'ENGLISH':
        return searchEnglishWords(query);
      default:
        return [];
    }
  }

  // Get translations between two languages (supports all language pairs)
  Future<List<String>> getTranslations(
    String sourceWord,
    String sourceLang,
    String targetLang,
  ) async {
    try {
      final source = sourceLang.toUpperCase();
      final target = targetLang.toUpperCase();

      // If source and target are the same, return empty
      if (source == target) {
        return [];
      }

      List<String> translations = [];

      // Sinama as source
      if (source == 'SINAMA') {
        final translationMap = await getSinamaTranslations(sourceWord);
        switch (target) {
          case 'CEBUANO':
            translations = translationMap['cebuano'] ?? [];
            break;
          case 'TAGALOG':
            translations = translationMap['tagalog'] ?? [];
            break;
          case 'ENGLISH':
            translations = translationMap['english'] ?? [];
            break;
          default:
            translations = [];
        }
      }
      // Cebuano as source
      else if (source == 'CEBUANO') {
        switch (target) {
          case 'SINAMA':
            translations = await getCebuanoToSinama(sourceWord);
            break;
          case 'TAGALOG':
            translations = await getCebuanoToTagalog(sourceWord);
            break;
          case 'ENGLISH':
            translations = await getCebuanoToEnglish(sourceWord);
            break;
          default:
            translations = [];
        }
      }
      // Tagalog as source
      else if (source == 'TAGALOG') {
        switch (target) {
          case 'SINAMA':
            translations = await getTagalogToSinama(sourceWord);
            break;
          case 'CEBUANO':
            translations = await getTagalogToCebuano(sourceWord);
            break;
          case 'ENGLISH':
            translations = await getTagalogToEnglish(sourceWord);
            break;
          default:
            translations = [];
        }
      }
      // English as source
      else if (source == 'ENGLISH') {
        switch (target) {
          case 'SINAMA':
            translations = await getEnglishToSinama(sourceWord);
            break;
          case 'CEBUANO':
            translations = await getEnglishToCebuano(sourceWord);
            break;
          case 'TAGALOG':
            translations = await getEnglishToTagalog(sourceWord);
            break;
          default:
            translations = [];
        }
      }

      print(
        'Translation from $source "$sourceWord" to $target: ${translations.length} results',
      );
      return translations;
    } catch (e, stackTrace) {
      print(
        'Error getting translation from $sourceLang "$sourceWord" to $targetLang: $e',
      );
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  // Favorites methods
  Future<void> addFavorite({
    required String word,
    required String language,
    String? translation,
    String? translationLanguage,
  }) async {
    try {
      final db = await _db.database;

      // Check if already exists
      final existing = await db.query(
        'favorites',
        where: 'word = ? AND language = ?',
        whereArgs: [word, language],
        limit: 1,
      );

      if (existing.isEmpty) {
        await db.insert('favorites', {
          'word': word,
          'language': language,
          'translation': translation,
          'translation_language': translationLanguage,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
        // Verify the insert was successful
        final verify = await db.query(
          'favorites',
          where: 'word = ? AND language = ?',
          whereArgs: [word, language],
          limit: 1,
        );
        if (verify.isEmpty) {
          print(
            'Warning: Favorite was not saved properly for $word ($language)',
          );
        }
      }
    } catch (e, stackTrace) {
      print('Error adding favorite: $e');
      print('Stack trace: $stackTrace');
      rethrow; // Re-throw to ensure caller knows operation failed
    }
  }

  Future<void> removeFavorite(String word, String language) async {
    try {
      final db = await _db.database;
      await db.delete(
        'favorites',
        where: 'word = ? AND language = ?',
        whereArgs: [word, language],
      );
    } catch (e, stackTrace) {
      print('Error removing favorite: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<bool> isFavorite(String word, String language) async {
    final db = await _db.database;
    final result = await db.query(
      'favorites',
      where: 'word = ? AND language = ?',
      whereArgs: [word, language],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getAllFavorites() async {
    final db = await _db.database;
    final results = await db.query('favorites', orderBy: 'created_at DESC');
    return results;
  }

  // Recent searches methods
  Future<void> addRecentSearch({
    required String sourceWord,
    required String sourceLanguage,
    required String targetWord,
    required String targetLanguage,
  }) async {
    try {
      final db = await _db.database;

      // Remove duplicate if exists (to move it to top)
      await db.delete(
        'recent_searches',
        where:
            'source_word = ? AND source_language = ? AND target_word = ? AND target_language = ?',
        whereArgs: [sourceWord, sourceLanguage, targetWord, targetLanguage],
      );

      // Insert new entry
      await db.insert('recent_searches', {
        'source_word': sourceWord,
        'source_language': sourceLanguage,
        'target_word': targetWord,
        'target_language': targetLanguage,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Keep only last 100 recent searches
      final allRecent = await db.query(
        'recent_searches',
        orderBy: 'created_at DESC',
      );

      if (allRecent.length > 100) {
        final idsToDelete = allRecent
            .sublist(100)
            .map((e) => e['id'] as int)
            .toList();
        for (final id in idsToDelete) {
          await db.delete('recent_searches', where: 'id = ?', whereArgs: [id]);
        }
      }
    } catch (e, stackTrace) {
      print('Error adding recent search: $e');
      print('Stack trace: $stackTrace');
      // Don't rethrow for recent searches - it's not critical if it fails
    }
  }

  Future<List<Map<String, dynamic>>> getRecentSearches({int limit = 50}) async {
    final db = await _db.database;
    final results = await db.query(
      'recent_searches',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return results;
  }

  Future<void> clearRecentSearches() async {
    try {
      final db = await _db.database;
      await db.delete('recent_searches');
    } catch (e, stackTrace) {
      print('Error clearing recent searches: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> removeRecentSearch(int id) async {
    try {
      final db = await _db.database;
      await db.delete('recent_searches', where: 'id = ?', whereArgs: [id]);
    } catch (e, stackTrace) {
      print('Error removing recent search: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> clearAllFavorites() async {
    try {
      final db = await _db.database;
      await db.delete('favorites');
    } catch (e, stackTrace) {
      print('Error clearing all favorites: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Get all words for a specific language (for suggestions)
  Future<List<String>> getAllWordsForLanguage(String language) async {
    try {
      final db = await _db.database;
      String tableName;

      switch (language.toUpperCase()) {
        case 'SINAMA':
          tableName = 'sinama_words';
          break;
        case 'CEBUANO':
          tableName = 'cebuano_words';
          break;
        case 'ENGLISH':
          tableName = 'english_words';
          break;
        case 'TAGALOG':
          tableName = 'tagalog_words';
          break;
        default:
          return [];
      }

      final results = await db.query(
        tableName,
        columns: ['word'],
        orderBy: 'word COLLATE NOCASE',
        limit: 10000, // Increased limit to show more suggestions
      );

      return results.map((row) => row['word'] as String).toList();
    } catch (e) {
      print('Error getting all words for $language: $e');
      return [];
    }
  }
}
