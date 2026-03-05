import 'package:flutter/material.dart';
import '../data/word_repository.dart';
import 'modern_translation_screen.dart';
import '../theme/app_theme.dart';

/// Modern redesigned History/Recent Screen
/// Features: Beautiful card list, search bar, empty state, clear history
class ModernHistoryScreen extends StatefulWidget {
  const ModernHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ModernHistoryScreen> createState() => _ModernHistoryScreenState();
}

class _ModernHistoryScreenState extends State<ModernHistoryScreen> {
  final WordRepository _repository = WordRepository();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _recentSearches = [];
  List<Map<String, dynamic>> _filteredSearches = [];
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _searchController.addListener(_filterSearches);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only reload after initial build is complete
    if (_isInitialized) {
      _loadRecentSearches();
    }
    _isInitialized = true;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    setState(() => _isLoading = true);
    final recent = await _repository.getRecentSearches();
    if (mounted) {
      setState(() {
        _recentSearches = recent;
        _filterSearches();
        _isLoading = false;
      });
    }
  }

  void _filterSearches() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredSearches = _recentSearches;
    } else {
      _filteredSearches = _recentSearches
          .where(
            (search) =>
                (search['source_word'] as String).toLowerCase().contains(
                  query,
                ) ||
                (search['target_word'] as String).toLowerCase().contains(query),
          )
          .toList();
    }
    if (mounted) setState(() {});
  }

  Future<void> _deleteRecentSearch(Map<String, dynamic> recent) async {
    final id = recent['id'] as int;
    final sourceWord = recent['source_word'] as String;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete History'),
        content: Text('Remove "$sourceWord" from history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repository.removeRecentSearch(id);
      _loadRecentSearches();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from history'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  Future<void> _clearRecentSearches() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
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
      await _repository.clearRecentSearches();
      _loadRecentSearches();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('History cleared'),
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
            else if (_recentSearches.isEmpty)
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
                            Icons.history,
                            size: 40,
                            color: AppColors.secondarySageGreen,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No History Yet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textCharcoalGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your translation history will appear here',
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
            else if (_filteredSearches.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 190),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No results found',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textMutedGray,
                      ),
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
                        itemCount: _filteredSearches.length,
                        itemBuilder: (context, index) {
                          final search = _filteredSearches[index];
                          final sourceWord = search['source_word'] as String;
                          final targetWord = search['target_word'] as String;
                          final sourceLanguage =
                              search['source_language'] as String;
                          final targetLanguage =
                              search['target_language'] as String;
                          final createdAt = search['created_at'] as int?;

                          // Convert timestamp to readable format
                          String? timestamp;
                          if (createdAt != null) {
                            final date = DateTime.fromMillisecondsSinceEpoch(
                              createdAt,
                            );
                            final now = DateTime.now();
                            final difference = now.difference(date);

                            if (difference.inMinutes < 1) {
                              timestamp = 'Just now';
                            } else if (difference.inMinutes < 60) {
                              timestamp = '${difference.inMinutes}m ago';
                            } else if (difference.inHours < 24) {
                              timestamp = '${difference.inHours}h ago';
                            } else if (difference.inDays < 7) {
                              timestamp = '${difference.inDays}d ago';
                            } else {
                              timestamp =
                                  '${date.day}/${date.month}/${date.year}';
                            }
                          }

                          return _buildHistoryCard(
                            sourceWord: sourceWord,
                            targetWord: targetWord,
                            sourceLanguage: sourceLanguage,
                            targetLanguage: targetLanguage,
                            timestamp: timestamp,
                            onDelete: () => _deleteRecentSearch(search),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ModernTranslationScreen(
                                    initialWord: sourceWord,
                                    initialTranslation: targetWord,
                                    initialFromLanguage: sourceLanguage,
                                    initialToLanguage: targetLanguage,
                                  ),
                                ),
                              ).then((_) => _loadRecentSearches());
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
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
                              'RECENT WORDS',
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
                  hintText: 'Search history...',
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

  Widget _buildHistoryCard({
    required String sourceWord,
    required String targetWord,
    required String sourceLanguage,
    required String targetLanguage,
    required String? timestamp,
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
                  // Arrow
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.arrow_forward,
                      color: AppColors.accentMutedGold,
                      size: 20,
                    ),
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
                  if (timestamp != null)
                    Text(
                      timestamp,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMutedGray,
                      ),
                    )
                  else
                    const SizedBox(),
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
