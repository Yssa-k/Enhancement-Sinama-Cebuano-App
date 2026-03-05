import 'package:flutter/material.dart';

import '../data/word_repository.dart';
import '../services/speech_service.dart';
import '../theme/app_theme.dart';

class WordDetailScreen extends StatefulWidget {
  final String word;
  final String sourceLanguage;
  final String targetLanguage;

  const WordDetailScreen({
    super.key,
    required this.word,
    required this.sourceLanguage,
    required this.targetLanguage,
  });

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  late String _leftLanguage;
  late String _rightLanguage;
  late String _leftWord;
  String _rightWord = '';
  bool _isLoadingTranslation = true;
  bool _isLeftFavorite = false;
  bool _isRightFavorite = false;
  final WordRepository _repository = WordRepository();
  final SpeechService _speechService = SpeechService();

  @override
  void initState() {
    super.initState();
    _leftLanguage = widget.sourceLanguage;
    _rightLanguage = widget.targetLanguage;
    _leftWord = widget.word;
    _loadTranslation();
    _checkFavorites();
    _speechService.initializeTts();
  }

  @override
  void dispose() {
    _speechService.stopSpeaking();
    super.dispose();
  }

  Future<void> _checkFavorites() async {
    final leftFavorite = await _repository.isFavorite(_leftWord, _leftLanguage);
    setState(() {
      _isLeftFavorite = leftFavorite;
    });
  }

  Future<void> _toggleLeftFavorite() async {
    if (_isLeftFavorite) {
      await _repository.removeFavorite(_leftWord, _leftLanguage);
    } else {
      await _repository.addFavorite(
        word: _leftWord,
        language: _leftLanguage,
        translation: _rightWord.isNotEmpty ? _rightWord : null,
        translationLanguage: _rightWord.isNotEmpty ? _rightLanguage : null,
      );
    }
    setState(() {
      _isLeftFavorite = !_isLeftFavorite;
    });
  }

  Future<void> _toggleRightFavorite() async {
    if (_rightWord.isEmpty) return;

    if (_isRightFavorite) {
      await _repository.removeFavorite(_rightWord, _rightLanguage);
    } else {
      await _repository.addFavorite(
        word: _rightWord,
        language: _rightLanguage,
        translation: _leftWord,
        translationLanguage: _leftLanguage,
      );
    }
    setState(() {
      _isRightFavorite = !_isRightFavorite;
    });
  }

  void _swapLanguages() {
    setState(() {
      // Swap the languages
      final tempLang = _leftLanguage;
      _leftLanguage = _rightLanguage;
      _rightLanguage = tempLang;

      // Swap the words
      final tempWord = _leftWord;
      _leftWord = _rightWord.isNotEmpty ? _rightWord : tempWord;
      _rightWord = '';
    });
    _loadTranslation();
  }

  Future<void> _loadTranslation() async {
    setState(() {
      _isLoadingTranslation = true;
    });
    final translations = await _repository.getTranslations(
      _leftWord,
      _leftLanguage,
      _rightLanguage,
    );
    if (!mounted) return;
    setState(() {
      _rightWord = translations.isNotEmpty ? translations.first : '';
      _isLoadingTranslation = false;
    });

    // Check if right word is favorite
    if (_rightWord.isNotEmpty) {
      final rightFavorite = await _repository.isFavorite(
        _rightWord,
        _rightLanguage,
      );
      if (mounted) {
        setState(() {
          _isRightFavorite = rightFavorite;
        });
      }
    }

    // Save to recent searches
    if (_rightWord.isNotEmpty) {
      await _repository.addRecentSearch(
        sourceWord: _leftWord,
        sourceLanguage: _leftLanguage,
        targetWord: _rightWord,
        targetLanguage: _rightLanguage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWarmOffWhite,
      body: Stack(
        children: [
          // Top rounded header
          Container(
            height: 200,
            decoration: const BoxDecoration(
              color: AppColors.primaryForestGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: AppColors.white,
                            size: 26,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          tooltip: 'Back',
                        ),
                        // Logo and app name
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.white.withOpacity(0.95),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.secondarySageGreen,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'S',
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'SINAMA',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Text(
                                  'Translator App',
                                  style: TextStyle(
                                    color: AppColors.white.withOpacity(0.9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.help_outline,
                            color: AppColors.white,
                            size: 26,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          tooltip: 'Help',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Language pills showing translation direction
          Positioned(
            top: 200,
            left: 8,
            right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Source language pill
                Container(
                  width: 130,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: _leftLanguage == 'SINAMA'
                        ? AppColors.secondarySageGreen.withOpacity(0.3)
                        : AppColors.secondarySageGreen,
                    borderRadius: BorderRadius.circular(16),
                    border: _leftLanguage == 'SINAMA'
                        ? Border.all(
                            color: AppColors.secondarySageGreen,
                            width: 2,
                          )
                        : null,
                    boxShadow: _leftLanguage == 'SINAMA'
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                              spreadRadius: 0,
                            ),
                          ],
                  ),
                  child: Text(
                    _leftLanguage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _leftLanguage == 'SINAMA'
                          ? Colors.black87
                          : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Swap icon
                GestureDetector(
                  onTap: _swapLanguages,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryForestGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sync_alt,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Target language pill
                Container(
                  width: 130,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: _rightLanguage == 'SINAMA'
                        ? AppColors.secondarySageGreen.withOpacity(0.3)
                        : AppColors.secondarySageGreen,
                    borderRadius: BorderRadius.circular(16),
                    border: _rightLanguage != 'SINAMA'
                        ? Border.all(
                            color: AppColors.secondarySageGreen,
                            width: 2,
                          )
                        : null,
                    boxShadow: _rightLanguage == 'SINAMA'
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                              spreadRadius: 2,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                              spreadRadius: 0,
                            ),
                          ],
                  ),
                  child: Text(
                    _rightLanguage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _rightLanguage == 'SINAMA'
                          ? Colors.black87
                          : Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Word detail content
          Positioned(
            top: 260,
            left: 8,
            right: 8,
            bottom: 80,
            child: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source word card (left side, under source language)
                  SizedBox(
                    width: 130,
                    child: Column(
                      children: [
                        Container(
                          width: 130,
                          constraints: const BoxConstraints(
                            minHeight: 100,
                            maxHeight: 200,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _leftLanguage == 'SINAMA'
                                ? AppColors.secondarySageGreen.withOpacity(0.3)
                                : AppColors.secondarySageGreen,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.secondarySageGreen,
                              width: 2,
                            ),
                            boxShadow: _leftLanguage == 'SINAMA'
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.10),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                      spreadRadius: 0,
                                    ),
                                  ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: SingleChildScrollView(
                                  child: Text(
                                    _leftWord,
                                    textAlign: TextAlign.center,
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: _leftLanguage == 'SINAMA'
                                          ? Colors.black87
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _speechService.speak(
                                  _leftWord,
                                  language: _leftLanguage,
                                ),
                                child: Icon(
                                  Icons.volume_up,
                                  color: _leftLanguage == 'SINAMA'
                                      ? Colors.black54
                                      : Colors.white,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        IconButton(
                          icon: Icon(
                            _isLeftFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          iconSize: 24,
                          color: _isLeftFavorite
                              ? Colors.red
                              : Colors.red.shade300,
                          onPressed: _toggleLeftFavorite,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Spacer for swap button
                  const SizedBox(width: 42),

                  const SizedBox(width: 8),

                  // Translation card (right side, under target language)
                  SizedBox(
                    width: 130,
                    child: Column(
                      children: [
                        Container(
                          width: 130,
                          constraints: const BoxConstraints(
                            minHeight: 100,
                            maxHeight: 200,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _rightLanguage == 'SINAMA'
                                ? AppColors.secondarySageGreen.withOpacity(0.3)
                                : AppColors.secondarySageGreen,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.secondarySageGreen,
                              width: 2,
                            ),
                            boxShadow: _rightLanguage == 'SINAMA'
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.10),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                      spreadRadius: 0,
                                    ),
                                  ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_isLoadingTranslation)
                                const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              else
                                Flexible(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      _rightWord.isEmpty
                                          ? 'No translation'
                                          : _rightWord,
                                      textAlign: TextAlign.center,
                                      maxLines: 5,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: _rightLanguage == 'SINAMA'
                                            ? Colors.black87
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              if (_rightWord.isNotEmpty)
                                GestureDetector(
                                  onTap: () => _speechService.speak(
                                    _rightWord,
                                    language: _rightLanguage,
                                  ),
                                  child: Icon(
                                    Icons.volume_up,
                                    color: _rightLanguage == 'SINAMA'
                                        ? Colors.black54
                                        : Colors.white,
                                    size: 20,
                                  ),
                                )
                              else
                                Icon(
                                  Icons.volume_up,
                                  color: _rightLanguage == 'SINAMA'
                                      ? Colors.black54
                                      : Colors.white,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        IconButton(
                          icon: Icon(
                            _isRightFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                          iconSize: 24,
                          color: _isRightFavorite
                              ? Colors.red
                              : Colors.red.shade300,
                          onPressed: _rightWord.isEmpty
                              ? null
                              : _toggleRightFavorite,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primaryForestGreen,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Simple translation mapping (you can expand this) - Currently unused
  // ignore: unused_element
  String _getTranslation(String word, String from, String to) {
    // Mock translations - replace with actual translation logic
    final Map<String, Map<String, String>> translations = {
      // Sinama words
      'abbuhan': {
        'CEBUANO': 'abante',
        'TAGALOG': 'abala',
        'ENGLISH': 'abandon',
      },
      'abolengok': {
        'CEBUANO': 'abot',
        'TAGALOG': 'abante',
        'ENGLISH': 'abbreviate',
      },
      'abu': {'CEBUANO': 'abli', 'TAGALOG': 'abot', 'ENGLISH': 'abdomen'},
      'abuhat': {'CEBUANO': 'abog', 'TAGALOG': 'abraso', 'ENGLISH': 'abide'},
      'abuhuk': {
        'CEBUANO': 'abogado',
        'TAGALOG': 'absuwelto',
        'ENGLISH': 'ability',
      },
      'abuntol': {
        'CEBUANO': 'abrir',
        'TAGALOG': 'abogado',
        'ENGLISH': 'abolish',
      },
      // Cebuano words
      'abante': {
        'SINAMA': 'abbuhan',
        'TAGALOG': 'abante',
        'ENGLISH': 'forward',
      },
      'abot': {'SINAMA': 'abolengok', 'TAGALOG': 'abot', 'ENGLISH': 'reach'},
      'abli': {'SINAMA': 'abu', 'TAGALOG': 'bukas', 'ENGLISH': 'open'},
      'abog': {'SINAMA': 'abuhat', 'TAGALOG': 'alikabok', 'ENGLISH': 'dust'},
      'abogado': {
        'SINAMA': 'abuhuk',
        'TAGALOG': 'abogado',
        'ENGLISH': 'lawyer',
      },
      'abrir': {'SINAMA': 'abuntol', 'TAGALOG': 'buksan', 'ENGLISH': 'open'},
      // Tagalog words
      'abala': {'SINAMA': 'abbuhan', 'CEBUANO': 'abante', 'ENGLISH': 'busy'},
      'abraso': {'SINAMA': 'abuhat', 'CEBUANO': 'abog', 'ENGLISH': 'embrace'},
      'absuwelto': {
        'SINAMA': 'abuhuk',
        'CEBUANO': 'abogado',
        'ENGLISH': 'acquitted',
      },
      'bukas': {'SINAMA': 'abu', 'CEBUANO': 'abli', 'ENGLISH': 'open'},
      'alikabok': {'SINAMA': 'abuhat', 'CEBUANO': 'abog', 'ENGLISH': 'dust'},
      'buksan': {'SINAMA': 'abuntol', 'CEBUANO': 'abrir', 'ENGLISH': 'open'},
      // English words
      'abandon': {'SINAMA': 'abbuhan', 'CEBUANO': 'abante', 'TAGALOG': 'abala'},
      'abbreviate': {
        'SINAMA': 'abolengok',
        'CEBUANO': 'abot',
        'TAGALOG': 'abante',
      },
      'abdomen': {'SINAMA': 'abu', 'CEBUANO': 'abli', 'TAGALOG': 'abot'},
      'abide': {'SINAMA': 'abuhat', 'CEBUANO': 'abog', 'TAGALOG': 'abraso'},
      'ability': {
        'SINAMA': 'abuhuk',
        'CEBUANO': 'abogado',
        'TAGALOG': 'absuwelto',
      },
      'abolish': {
        'SINAMA': 'abuntol',
        'CEBUANO': 'abrir',
        'TAGALOG': 'abogado',
      },
    };

    return translations[word.toLowerCase()]?[to] ?? word;
  }
}
