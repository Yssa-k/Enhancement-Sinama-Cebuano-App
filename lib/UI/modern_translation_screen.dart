import 'dart:async';
import 'package:flutter/material.dart';
import '../data/word_repository.dart';
import '../services/speech_service.dart';
import '../services/suggestion_service.dart';
import '../theme/app_theme.dart';

/// Modern redesigned Translation Screen with improved UX
/// Features: Pill-shaped input fields, central swap icon, voice input, language selectors
class ModernTranslationScreen extends StatefulWidget {
  final String? initialWord;
  final String? initialTranslation;
  final String? initialFromLanguage;
  final String? initialToLanguage;

  const ModernTranslationScreen({
    super.key,
    this.initialWord,
    this.initialTranslation,
    this.initialFromLanguage,
    this.initialToLanguage,
  });

  @override
  State<ModernTranslationScreen> createState() =>
      _ModernTranslationScreenState();
}

class _ModernTranslationScreenState extends State<ModernTranslationScreen> {
  final TextEditingController _leftController = TextEditingController();
  final TextEditingController _rightController = TextEditingController();
  final WordRepository _repository = WordRepository();
  final SpeechService _speechService = SpeechService();
  late final SuggestionService _suggestionService;
  final FocusNode _leftFocusNode = FocusNode();

  // Explicit state variables for FROM and TO languages
  String _fromLanguage = 'SINAMA';
  String _toLanguage = 'CEBUANO';
  bool _isTranslating = false;
  bool _isListening = false;
  bool _showFromLanguageMenu = false;
  bool _showToLanguageMenu = false;
  bool _isInputFavorite = false;
  bool _isOutputFavorite = false;
  String _lastTranslatedWord = ''; // Track last translated word

  // Suggestion state
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  final List<String> _otherLanguages = ['CEBUANO', 'ENGLISH', 'TAGALOG'];

  // Helper getters for controller mapping - SINAMA is always input source
  bool get _isSinamaInFrom => _fromLanguage == 'SINAMA';
  TextEditingController get _inputController =>
      _isSinamaInFrom ? _leftController : _rightController;
  TextEditingController get _outputController =>
      _isSinamaInFrom ? _rightController : _leftController;

  // Getters for language based on position
  String get _leftLanguage => _fromLanguage;
  String get _rightLanguage => _toLanguage;

  @override
  void initState() {
    super.initState();
    _suggestionService = SuggestionService(_repository);
    _speechService.initializeTts();

    // Initialize with favorite/history data if provided
    if (widget.initialWord != null) {
      // Set languages first before setting controller text
      if (widget.initialFromLanguage != null) {
        _fromLanguage = widget.initialFromLanguage!;
      }
      if (widget.initialToLanguage != null) {
        _toLanguage = widget.initialToLanguage!;
      }

      // Now set controller texts based on language configuration
      // After languages are set, _inputController and _outputController point to correct controllers
      _inputController.text = widget.initialWord!;

      if (widget.initialTranslation != null) {
        _outputController.text = widget.initialTranslation!;
        _lastTranslatedWord = widget.initialWord!;
        // Check favorite states for initial data
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            _checkFavoriteStates();
          }
        });
      }
      // Trigger translation after a short delay to ensure UI is ready
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && widget.initialTranslation == null) {
          _translateText();
        }
      });
    }

    // Add listeners to both controllers to reset favorite state when user types different word
    _leftController.addListener(_onTextChanged);
    _rightController.addListener(_onTextChanged);

    // Add listener for input suggestions to both controllers
    _leftController.addListener(_onInputChanged);
    _rightController.addListener(_onInputChanged);

    // Hide suggestions when focus is lost
    _leftFocusNode.addListener(() {
      if (!_leftFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) {
            setState(() => _showSuggestions = false);
          }
        });
      }
    });
  }

  void _onTextChanged() {
    // Get the current source controller based on position
    final sourceController = _inputController;
    final currentText = sourceController.text.trim();

    // Reset favorite if user changes the text after a translation
    if (currentText != _lastTranslatedWord && _lastTranslatedWord.isNotEmpty) {
      setState(() {
        _isInputFavorite = false;
        _isOutputFavorite = false;
      });
    }

    // Reset if empty - clear translation output and close suggestions
    if (currentText.isEmpty) {
      setState(() {
        _isInputFavorite = false;
        _isOutputFavorite = false;
        _lastTranslatedWord = '';
        _outputController.clear();
        _suggestions = [];
        _showSuggestions = false;
      });
    }
  }

  void _onInputChanged() {
    // Get text from the active input controller
    final text = _inputController.text.trim();

    if (text.isEmpty) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    // Use debounced suggestions for performance
    _suggestionService.debouncedGetSuggestions(
      input: text,
      language: _fromLanguage,
      onSuggestions: (suggestions) {
        if (mounted &&
            _leftFocusNode.hasFocus &&
            _inputController.text.trim().isNotEmpty) {
          setState(() {
            _suggestions = suggestions;
            _showSuggestions = suggestions.isNotEmpty;
          });
        }
      },
    );
  }

  void _selectSuggestion(String suggestion) {
    setState(() {
      _inputController.text = suggestion;
      _showSuggestions = false;
    });
    // Unfocus to prevent suggestions from reappearing
    _leftFocusNode.unfocus();
  }

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    _leftFocusNode.dispose();
    _speechService.stopSpeaking();
    _suggestionService.dispose();
    super.dispose();
  }

  Future<void> _translateText() async {
    // Get the source controller based on current position
    final sourceController = _inputController;
    final targetController = _outputController;

    if (sourceController.text.isEmpty) return;

    setState(() => _isTranslating = true);

    try {
      final translations = await _repository.getTranslations(
        sourceController.text,
        _fromLanguage,
        _toLanguage,
      );

      if (mounted) {
        setState(() {
          targetController.text = translations.isNotEmpty
              ? translations.first
              : 'No translation found';
          _isTranslating = false;
          _lastTranslatedWord = sourceController.text
              .trim(); // Track translated word
        });

        // Save to recent and check favorite states
        if (translations.isNotEmpty) {
          await _repository.addRecentSearch(
            sourceWord: sourceController.text,
            sourceLanguage: _fromLanguage,
            targetWord: translations.first,
            targetLanguage: _toLanguage,
          );

          // Check if the translated words are already favorited
          await _checkFavoriteStates();
        } else {
          // No translation found, reset favorite state
          setState(() {
            _isInputFavorite = false;
            _isOutputFavorite = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTranslating = false;
          _isInputFavorite = false;
          _isOutputFavorite = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Translation error: $e')));
      }
    }
  }

  Future<void> _swapLanguages() async {
    print('SWAP BEFORE: FROM=$_fromLanguage, TO=$_toLanguage');

    // Save current input and output text BEFORE swapping languages
    final tempInputText = _inputController.text;
    final tempOutputText = _outputController.text;

    setState(() {
      // Swap FROM and TO languages
      final tempLang = _fromLanguage;
      _fromLanguage = _toLanguage;
      _toLanguage = tempLang;

      // Now swap text contents - the input becomes output and vice versa
      // After language swap, _inputController and _outputController point to different controllers
      _inputController.text = tempOutputText;
      _outputController.text = tempInputText;

      // Close any open language menus
      _showFromLanguageMenu = false;
      _showToLanguageMenu = false;

      // Reset last translated word
      _lastTranslatedWord = '';
    });
    print('SWAP AFTER: FROM=$_fromLanguage, TO=$_toLanguage');

    // Check favorite states after swapping
    await _checkFavoriteStates();

    // Trigger translation if there's text in the source field
    if (_inputController.text.isNotEmpty) {
      _translateText();
    }
  }

  /// Check if current input and output words are favorited
  Future<void> _checkFavoriteStates() async {
    if (_inputController.text.isNotEmpty && _outputController.text.isNotEmpty) {
      final isInputFav = await _repository.isFavorite(
        _inputController.text.trim(),
        _fromLanguage,
      );
      final isOutputFav = await _repository.isFavorite(
        _outputController.text.trim(),
        _toLanguage,
      );

      if (mounted) {
        setState(() {
          _isInputFavorite = isInputFav;
          _isOutputFavorite = isOutputFav;
        });
      }
    }
  }

  Future<void> _toggleInputFavorite() async {
    if (_inputController.text.isEmpty || _outputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please translate a word first')),
      );
      return;
    }

    try {
      if (_isInputFavorite) {
        await _repository.removeFavorite(_inputController.text, _fromLanguage);
        if (mounted) {
          setState(() => _isInputFavorite = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from favorites')),
          );
        }
      } else {
        await _repository.addFavorite(
          word: _inputController.text,
          language: _fromLanguage,
          translation: _outputController.text,
          translationLanguage: _toLanguage,
        );
        if (mounted) {
          setState(() => _isInputFavorite = true);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Added to favorites')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _toggleOutputFavorite() async {
    if (_inputController.text.isEmpty || _outputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please translate a word first')),
      );
      return;
    }

    try {
      if (_isOutputFavorite) {
        await _repository.removeFavorite(_outputController.text, _toLanguage);
        if (mounted) {
          setState(() => _isOutputFavorite = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from favorites')),
          );
        }
      } else {
        await _repository.addFavorite(
          word: _outputController.text,
          language: _toLanguage,
          translation: _inputController.text,
          translationLanguage: _fromLanguage,
        );
        if (mounted) {
          setState(() => _isOutputFavorite = true);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Added to favorites')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _startListening() async {
    final available = await _speechService.isAvailable();
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available')),
        );
      }
      return;
    }

    // Get the source controller based on current position
    final sourceController = _inputController;

    setState(() => _isListening = true);
    await _speechService.startListening(
      language: _fromLanguage,
      onResult: (result) {
        if (mounted) {
          setState(() {
            sourceController.text = result;
            _isListening = false;
          });
          _translateText();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Debug: Print current state
    print(
      'BUILD - FROM: $_fromLanguage (isFixed: ${_fromLanguage == 'SINAMA'})',
    );
    print('BUILD - TO: $_toLanguage (isFixed: ${_toLanguage == 'SINAMA'})');

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundWarmOffWhite,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.primaryForestGreen,
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.white,
              size: 32,
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
          title: const Text(
            'Translate',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Language selectors (vertical layout)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // FROM label
                      const Text(
                        'From',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textCharcoalGray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Top language selector (FROM)
                      _buildLanguageSelector(
                        key: ValueKey('from_${_fromLanguage}_to_$_toLanguage'),
                        language: _fromLanguage,
                        onTap: _fromLanguage == 'SINAMA'
                            ? null
                            : () {
                                setState(() {
                                  _showFromLanguageMenu =
                                      !_showFromLanguageMenu;
                                  _showToLanguageMenu = false;
                                });
                              },
                        showMenu: _showFromLanguageMenu,
                        onSelectLanguage: (lang) {
                          setState(() {
                            _fromLanguage = lang;
                            _showFromLanguageMenu = false;
                            _leftController.clear();
                            _rightController.clear();
                            _isInputFavorite = false;
                            _isOutputFavorite = false;
                            _lastTranslatedWord = '';
                          });
                        },
                        isFixed: _fromLanguage == 'SINAMA',
                      ),
                      const SizedBox(height: 8),
                      // Auto-detect text
                      const Text(
                        'Auto-detect',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      // Swap button (centered)
                      Center(
                        child: AnimatedRotation(
                          turns: _fromLanguage == 'SINAMA' ? 0 : 0.5,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.accentMutedGold,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentMutedGold.withOpacity(
                                    0.4,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _swapLanguages,
                                customBorder: const CircleBorder(),
                                child: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(
                                    Icons.swap_vert,
                                    color: AppColors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // TO label
                      const Text(
                        'To',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textCharcoalGray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Bottom language selector (TO)
                      _buildLanguageSelector(
                        key: ValueKey('to_${_toLanguage}_from_$_fromLanguage'),
                        language: _toLanguage,
                        onTap: _toLanguage == 'SINAMA'
                            ? null
                            : () {
                                setState(() {
                                  _showToLanguageMenu = !_showToLanguageMenu;
                                  _showFromLanguageMenu = false;
                                });
                              },
                        showMenu: _showToLanguageMenu,
                        onSelectLanguage: (lang) {
                          setState(() {
                            _toLanguage = lang;
                            _showToLanguageMenu = false;
                            _leftController.clear();
                            _rightController.clear();
                            _isInputFavorite = false;
                            _isOutputFavorite = false;
                            _lastTranslatedWord = '';
                          });
                        },
                        isFixed: _toLanguage == 'SINAMA',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Input fields
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // FROM input field with suggestions
                      Stack(
                        children: [
                          Column(
                            children: [
                              // FROM input field (always has input features)
                              _buildInputField(
                                controller: _inputController,
                                focusNode: _leftFocusNode,
                                hintText:
                                    'Type ${_fromLanguage.toLowerCase()}...',
                                maxLines: 3,
                                prefixIcon: IconButton(
                                  icon: Icon(
                                    _isInputFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: _isInputFavorite
                                        ? AppColors.accentMutedGold
                                        : Colors.grey.shade400,
                                  ),
                                  onPressed: _toggleInputFavorite,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isListening ? Icons.mic : Icons.mic_none,
                                    color: _isListening
                                        ? AppColors.accentMutedGold
                                        : Colors.grey.shade600,
                                  ),
                                  onPressed: _startListening,
                                ),
                              ),
                              // Suggestions dropdown
                              if (_showSuggestions && _suggestions.isNotEmpty)
                                _buildSuggestionsDropdown(),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // TO output field (always read-only with translation)
                      _buildInputField(
                        controller: _outputController,
                        readOnly: true,
                        hintText: 'Translation appears here...',
                        maxLines: 3,
                        prefixIcon: IconButton(
                          icon: Icon(
                            _isOutputFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isOutputFavorite
                                ? AppColors.accentMutedGold
                                : Colors.grey.shade400,
                          ),
                          onPressed: _toggleOutputFavorite,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.volume_up,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: _outputController.text.isNotEmpty
                              ? () async {
                                  await _speechService.speak(
                                    _outputController.text,
                                    language: _toLanguage,
                                  );
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Translate button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildModernButton(
                    label: 'Translate',
                    onPressed: _translateText,
                    isLoading: _isTranslating,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector({
    Key? key,
    required String language,
    required VoidCallback? onTap,
    required bool showMenu,
    required Function(String) onSelectLanguage,
    bool isFixed = false,
  }) {
    print(
      '_buildLanguageSelector: language=$language, isFixed=$isFixed, showMenu=$showMenu',
    );
    return Column(
      key: key,
      children: [
        GestureDetector(
          onTap: isFixed ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(
                color: showMenu
                    ? AppColors.primaryForestGreen
                    : AppColors.secondarySageGreen,
                width: showMenu ? 2 : 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  language,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryForestGreen,
                  ),
                ),
                if (!isFixed)
                  Icon(
                    showMenu ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.primaryForestGreen,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
        if (showMenu && !isFixed)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _otherLanguages
                  .where((lang) => lang != language)
                  .map(
                    (lang) => GestureDetector(
                      onTap: () => onSelectLanguage(lang),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Text(
                          lang,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textCharcoalGray,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    String? hintText,
    FocusNode? focusNode,
    bool readOnly = false,
    int maxLines = 1,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: AppColors.primaryForestGreen,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 16,
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
        style: const TextStyle(
          fontSize: 15,
          color: AppColors.textCharcoalGray,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildModernButton({
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryForestGreen.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryForestGreen,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    )
                  : Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsDropdown() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Suggestions header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryForestGreen.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: AppColors.primaryForestGreen,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Suggestions',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryForestGreen,
                      ),
                    ),
                  ],
                ),
              ),
              // Suggestions list - constrained height for scrolling
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 300, // Limit height to make it scrollable
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _suggestions.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                    indent: 16,
                    endIndent: 16,
                  ),
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return InkWell(
                      onTap: () => _selectSuggestion(suggestion),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.history,
                              size: 18,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textCharcoalGray,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
