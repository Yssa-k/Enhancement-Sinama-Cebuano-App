import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'sinama_data.dart';
import 'cebuano_data.dart';
import 'tagalog_data.dart';
import 'english_data.dart';
import 'translation_mappings.dart';

class WordDatabase {
  static final WordDatabase instance = WordDatabase._init();
  static Database? _database;

  WordDatabase._init();

  Future<Database> get database async {
    if (_database != null) {
      // Verify the database is still valid
      try {
        await _database!.rawQuery('SELECT 1');
        return _database!;
      } catch (e) {
        print('Database connection lost, reinitializing...');
        _database = null;
      }
    }
    _database = await _initDB('words.db');
    // Check if database needs seeding (tables might be empty)
    await _ensureDatabaseSeeded(_database!);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Retry logic for database initialization
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final db = await openDatabase(
          path,
          version: 5,
          onCreate: _createDB,
          onUpgrade: (db, oldVersion, newVersion) async {
            try {
              if (oldVersion < 4) {
                // Drop existing tables and recreate with new data
                await db.execute('DROP TABLE IF EXISTS sinama_cebuano_translations');
                await db.execute('DROP TABLE IF EXISTS sinama_tagalog_translations');
                await db.execute('DROP TABLE IF EXISTS sinama_english_translations');
                await db.execute('DROP TABLE IF EXISTS sinama_words');
                await db.execute('DROP TABLE IF EXISTS cebuano_words');
                await db.execute('DROP TABLE IF EXISTS tagalog_words');
                await db.execute('DROP TABLE IF EXISTS english_words');
                await _createDB(db, newVersion);
              }
              if (oldVersion < 5) {
                // Add favorites and recent tables
                await db.execute('''
                  CREATE TABLE IF NOT EXISTS favorites(
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    word TEXT NOT NULL,
                    language TEXT NOT NULL,
                    translation TEXT,
                    translation_language TEXT,
                    created_at INTEGER NOT NULL
                  )
                ''');
                await db.execute('''
                  CREATE TABLE IF NOT EXISTS recent_searches(
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    source_word TEXT NOT NULL,
                    source_language TEXT NOT NULL,
                    target_word TEXT NOT NULL,
                    target_language TEXT NOT NULL,
                    created_at INTEGER NOT NULL
                  )
                ''');
                await db.execute('CREATE INDEX IF NOT EXISTS idx_favorites_word ON favorites(word)');
                await db.execute('CREATE INDEX IF NOT EXISTS idx_recent_created ON recent_searches(created_at)');
              }
            } catch (e, stackTrace) {
              print('Error during database upgrade: $e');
              print('Stack trace: $stackTrace');
              rethrow;
            }
          },
        );
        return db;
      } catch (e) {
        print('Error opening database (attempt ${attempt + 1}/3): $e');
        if (attempt == 2) {
          // Last attempt failed
          print('Failed to open database after 3 attempts');
          rethrow;
        }
        // Wait a bit before retrying
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    throw Exception('Failed to initialize database after multiple attempts');
  }

  Future _createDB(Database db, int version) async {
    // Sinama words table
    await db.execute('''
      CREATE TABLE sinama_words(
        id INTEGER PRIMARY KEY,
        word TEXT NOT NULL,
        audio_path TEXT
      )
    ''');

    // Cebuano words table
    await db.execute('''
      CREATE TABLE cebuano_words(
        id INTEGER PRIMARY KEY,
        word TEXT NOT NULL
      )
    ''');

    // Tagalog words table
    await db.execute('''
      CREATE TABLE tagalog_words(
        id INTEGER PRIMARY KEY,
        word TEXT NOT NULL
      )
    ''');

    // English words table
    await db.execute('''
      CREATE TABLE english_words(
        id INTEGER PRIMARY KEY,
        word TEXT NOT NULL
      )
    ''');

    // Translation mappings: Sinama to Cebuano
    await db.execute('''
      CREATE TABLE sinama_cebuano_translations(
        sinama_id INTEGER,
        cebuano_id INTEGER,
        PRIMARY KEY (sinama_id, cebuano_id),
        FOREIGN KEY (sinama_id) REFERENCES sinama_words(id),
        FOREIGN KEY (cebuano_id) REFERENCES cebuano_words(id)
      )
    ''');

    // Translation mappings: Sinama to Tagalog
    await db.execute('''
      CREATE TABLE sinama_tagalog_translations(
        sinama_id INTEGER,
        tagalog_id INTEGER,
        PRIMARY KEY (sinama_id, tagalog_id),
        FOREIGN KEY (sinama_id) REFERENCES sinama_words(id),
        FOREIGN KEY (tagalog_id) REFERENCES tagalog_words(id)
      )
    ''');

    // Translation mappings: Sinama to English
    await db.execute('''
      CREATE TABLE sinama_english_translations(
        sinama_id INTEGER,
        english_id INTEGER,
        PRIMARY KEY (sinama_id, english_id),
        FOREIGN KEY (sinama_id) REFERENCES sinama_words(id),
        FOREIGN KEY (english_id) REFERENCES english_words(id)
      )
    ''');

    // Create indexes for faster searches
    await db.execute('CREATE INDEX idx_sinama_word ON sinama_words(word)');
    await db.execute('CREATE INDEX idx_cebuano_word ON cebuano_words(word)');
    await db.execute('CREATE INDEX idx_tagalog_word ON tagalog_words(word)');
    await db.execute('CREATE INDEX idx_english_word ON english_words(word)');

    // Favorites table
    await db.execute('''
      CREATE TABLE favorites(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        word TEXT NOT NULL,
        language TEXT NOT NULL,
        translation TEXT,
        translation_language TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    // Recent searches table
    await db.execute('''
      CREATE TABLE recent_searches(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source_word TEXT NOT NULL,
        source_language TEXT NOT NULL,
        target_word TEXT NOT NULL,
        target_language TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Create indexes for favorites and recent
    await db.execute('CREATE INDEX idx_favorites_word ON favorites(word)');
    await db.execute('CREATE INDEX idx_recent_created ON recent_searches(created_at)');

    // Seed all language data
    await _seedAllLanguages(db);
  }

  Future<void> _seedAllLanguages(Database db) async {
    // Disable foreign key checks temporarily for faster insertion
    await db.execute('PRAGMA foreign_keys = OFF');
    
    try {
      // Insert Cebuano words
      final cebuanoBatch = db.batch();
      cebuanoSeedMap.forEach((id, word) {
        cebuanoBatch.insert(
          'cebuano_words',
          {'id': id, 'word': word},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
      await cebuanoBatch.commit(noResult: true);
      print('Inserted ${cebuanoSeedMap.length} Cebuano words');

      // Insert Tagalog words
      final tagalogBatch = db.batch();
      tagalogSeedMap.forEach((id, word) {
        tagalogBatch.insert(
          'tagalog_words',
          {'id': id, 'word': word},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
      await tagalogBatch.commit(noResult: true);
      print('Inserted ${tagalogSeedMap.length} Tagalog words');

      // Insert English words
      final englishBatch = db.batch();
      englishSeedMap.forEach((id, word) {
        englishBatch.insert(
          'english_words',
          {'id': id, 'word': word},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
      await englishBatch.commit(noResult: true);
      print('Inserted ${englishSeedMap.length} English words');

      // Insert Sinama words
      final sinamaBatch = db.batch();
      for (final entry in sinamaSeedEntries) {
        sinamaBatch.insert(
          'sinama_words',
          {
            'id': entry.falsiID,
            'word': entry.word,
            'audio_path': entry.vLocation,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await sinamaBatch.commit(noResult: true);
      print('Inserted ${sinamaSeedEntries.length} Sinama words');

      // Insert Sinama to Cebuano translation mappings
      final cebuanoTranslationBatch = db.batch();
      int cebuanoTranslationCount = 0;
      for (final entry in sinamaSeedEntries) {
        for (final cebuanoId in entry.translation.toSet()) {
          if (!cebuanoSeedMap.containsKey(cebuanoId)) continue;
          cebuanoTranslationBatch.insert(
            'sinama_cebuano_translations',
            {
              'sinama_id': entry.falsiID,
              'cebuano_id': cebuanoId,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          cebuanoTranslationCount++;
        }
      }
      await cebuanoTranslationBatch.commit(noResult: true);
      print('Inserted $cebuanoTranslationCount Sinama->Cebuano translation mappings');

      // Insert Sinama to Tagalog translation mappings
      final tagalogTranslationBatch = db.batch();
      int tagalogTranslationCount = 0;
      sinamaTranslationMappings.forEach((sinamaId, translations) {
        if (translations.containsKey('tagalog')) {
          for (final tagalogId in translations['tagalog']!) {
            if (!tagalogSeedMap.containsKey(tagalogId)) continue;
            tagalogTranslationBatch.insert(
              'sinama_tagalog_translations',
              {
                'sinama_id': sinamaId,
                'tagalog_id': tagalogId,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            tagalogTranslationCount++;
          }
        }
      });
      await tagalogTranslationBatch.commit(noResult: true);
      print('Inserted $tagalogTranslationCount Sinama->Tagalog translation mappings');

      // Insert Sinama to English translation mappings
      final englishTranslationBatch = db.batch();
      int englishTranslationCount = 0;
      sinamaTranslationMappings.forEach((sinamaId, translations) {
        if (translations.containsKey('english')) {
          for (final englishId in translations['english']!) {
            if (!englishSeedMap.containsKey(englishId)) continue;
            englishTranslationBatch.insert(
              'sinama_english_translations',
              {
                'sinama_id': sinamaId,
                'english_id': englishId,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            englishTranslationCount++;
          }
        }
      });
      await englishTranslationBatch.commit(noResult: true);
      print('Inserted $englishTranslationCount Sinama->English translation mappings');
    } catch (e, stackTrace) {
      print('Error seeding database: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    } finally {
      // Re-enable foreign key checks
      await db.execute('PRAGMA foreign_keys = ON');
    }
  }

  Future<void> _ensureDatabaseSeeded(Database db) async {
    try {
      // Check if sinama_words table exists and has any data
      try {
        final result = await db.rawQuery('SELECT COUNT(*) as count FROM sinama_words');
        final count = Sqflite.firstIntValue(result) ?? 0;
        
        if (count == 0) {
          print('Database tables are empty. Seeding database...');
          await _seedAllLanguages(db);
          print('Database seeding completed.');
        } else {
          print('Database already contains $count Sinama words. Skipping seed.');
          // Verify other tables also have data
          final cebuanoCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) as count FROM cebuano_words')
          ) ?? 0;
          final tagalogCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) as count FROM tagalog_words')
          ) ?? 0;
          final englishCount = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) as count FROM english_words')
          ) ?? 0;
          
          if (cebuanoCount == 0 || tagalogCount == 0 || englishCount == 0) {
            print('Some tables are empty. Re-seeding database...');
            await _seedAllLanguages(db);
            print('Database re-seeding completed.');
          }
        }
      } catch (tableError) {
        // Table might not exist, try to seed
        print('Error checking table (might not exist): $tableError');
        print('Attempting to seed database...');
        await _seedAllLanguages(db);
        print('Database seeding completed.');
      }
    } catch (e, stackTrace) {
      print('Error checking/seeding database: $e');
      print('Stack trace: $stackTrace');
      // Try to seed anyway if check fails
      try {
        print('Attempting to seed database as fallback...');
        await _seedAllLanguages(db);
        print('Database seeding completed after error recovery.');
      } catch (seedError, seedStackTrace) {
        print('Failed to seed database: $seedError');
        print('Seed error stack trace: $seedStackTrace');
        // If seeding fails, we're in a bad state - close and reset
        _database = null;
        rethrow;
      }
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }

  // Force reset database - delete and recreate (use with caution)
  Future<void> resetDatabase() async {
    try {
      // Close existing database if open
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
      
      // Get database path
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'words.db');
      
      // Delete database file using deleteDatabase
      await deleteDatabase(path);
      print('Database deleted successfully');
      
      // Reinitialize database (this will create new one and seed it)
      _database = await _initDB('words.db');
      await _ensureDatabaseSeeded(_database!);
      print('Database reset and re-seeded successfully');
    } catch (e, stackTrace) {
      print('Error resetting database: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}

