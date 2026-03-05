import 'package:flutter/material.dart';
import '../data/word_repository.dart';
import 'modern_translation_screen.dart';
import '../theme/app_theme.dart';

/// Modern redesigned Favorites Screen with grid/list layout
/// Features: Filter chips, beautiful cards, empty state, FAB for actions
class ModernFavoritesScreen extends StatefulWidget {
  const ModernFavoritesScreen({Key? key}) : super(key: key);

  @override
  State<ModernFavoritesScreen> createState() => _ModernFavoritesScreenState();
}

class _ModernFavoritesScreenState extends State<ModernFavoritesScreen> {
  final WordRepository _repository = WordRepository();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _favorites = [];
  List<Map<String, dynamic>> _filteredFavorites = [];
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _searchController.addListener(_filterFavorites);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only reload after initial build is complete
    if (_isInitialized) {
      _loadFavorites();
    }
    _isInitialized = true;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final favorites = await _repository.getAllFavorites();
    if (mounted) {
      setState(() {
        _favorites = favorites;
        _filterFavorites();
        _isLoading = false;
      });
    }
  }

  void _filterFavorites() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredFavorites = _favorites;
    } else {
      _filteredFavorites = _favorites
          .where(
            (favorite) =>
                (favorite['word'] as String).toLowerCase().contains(query) ||
                (favorite['translation'] as String? ?? '')
                    .toLowerCase()
                    .contains(query),
          )
          .toList();
    }
    if (mounted) setState(() {});
  }

  Future<void> _deleteFavorite(Map<String, dynamic> favorite) async {
    final word = favorite['word'] as String;
    final language = favorite['language'] as String;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Favorite'),
        content: Text('Remove "$word" from favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repository.removeFavorite(word, language);
      _loadFavorites();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Future<void> _clearAllFavorites() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorites'),
        content: const Text('Are you sure? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repository.clearAllFavorites();
      _loadFavorites();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All favorites cleared'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundWarmOffWhite,
        body: Stack(
          children: [
            // Content
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 190),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryForestGreen,
                    ),
                  ),
                ),
              )
            else if (_favorites.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 190),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secondarySageGreen.withOpacity(
                              0.2,
                            ),
                          ),
                          child: const Icon(
                            Icons.favorite_outline,
                            size: 40,
                            color: AppColors.secondarySageGreen,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No Favorites Yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textCharcoalGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add translations to favorites to access them here',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMutedGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 190),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredFavorites.length,
                        itemBuilder: (context, index) {
                          final favorite = _filteredFavorites[index];
                          final word = favorite['word'] as String;
                          final language = favorite['language'] as String;
                          final translation =
                              favorite['translation'] as String?;
                          final translationLanguage =
                              favorite['translation_language'] as String?;

                          return _buildFavoriteCard(
                            sourceWord: word,
                            sourceLanguage: language,
                            targetWord: translation ?? '',
                            targetLanguage: translationLanguage ?? 'CEBUANO',
                            onDelete: () => _deleteFavorite(favorite),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ModernTranslationScreen(
                                    initialWord: word,
                                    initialTranslation: translation,
                                    initialFromLanguage: language,
                                    initialToLanguage:
                                        translationLanguage ?? 'CEBUANO',
                                  ),
                                ),
                              ).then((_) => _loadFavorites());
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            // Curved header (positioned last so it's on top)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 160,
                decoration: const BoxDecoration(
                  color: AppColors.primaryForestGreen,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.chevron_left,
                                color: AppColors.white,
                                size: 32,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                            ),
                            const Text(
                              'FAVORITES',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Search bar (positioned in front of green header)
            Positioned(
              top: 140,
              left: 16,
              right: 16,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search favorites...',
                  filled: true,
                  fillColor: AppColors.white,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.secondarySageGreen,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: AppColors.secondarySageGreen,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: AppColors.secondarySageGreen,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: AppColors.primaryForestGreen,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCard({
    required String sourceWord,
    required String targetWord,
    required String sourceLanguage,
    required String targetLanguage,
    required VoidCallback onDelete,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.secondarySageGreen.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sourceWord,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textCharcoalGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sourceLanguage,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondarySageGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppColors.accentMutedGold,
                    size: 20,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          targetWord,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textCharcoalGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          targetLanguage,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.secondarySageGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.favorite,
                    color: AppColors.accentMutedGold,
                    size: 18,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.textMutedGray,
                      size: 20,
                    ),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
