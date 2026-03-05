import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../data/word_repository.dart';

/// Modern redesigned Settings Screen
/// Features: Clean list sections, toggles/switches, language preferences, about info
class ModernSettingsScreen extends StatefulWidget {
  const ModernSettingsScreen({super.key});

  @override
  State<ModernSettingsScreen> createState() => _ModernSettingsScreenState();
}

class _ModernSettingsScreenState extends State<ModernSettingsScreen> {
  final WordRepository _repository = WordRepository();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundWarmOffWhite,
        body: Column(
          children: [
            // Curved header
            Container(
              height: 200,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.chevron_left,
                          color: AppColors.white,
                          size: 32,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Text(
                        'Settings',
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
                ),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildActionButton(
                        icon: Icons.history,
                        title: 'Clear All Recent Words',
                        onTap: _showClearRecentDialog,
                      ),
                      const SizedBox(height: 16),
                      _buildActionButton(
                        icon: Icons.favorite,
                        title: 'Clear All Favorite Words',
                        onTap: _showClearFavoritesDialog,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.secondarySageGreen, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textCharcoalGray,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showClearRecentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Recent Words'),
        content: const Text(
          'Are you sure you want to clear all recent translation history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _repository.clearRecentSearches();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Recent words cleared successfully'),
                      backgroundColor: AppColors.primaryForestGreen,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error clearing recent words: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryForestGreen,
            ),
            child: const Text(
              'Clear All',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearFavoritesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favorite Words'),
        content: const Text(
          'Are you sure you want to clear all saved favorites? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _repository.clearAllFavorites();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Favorites cleared successfully'),
                      backgroundColor: AppColors.primaryForestGreen,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error clearing favorites: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryForestGreen,
            ),
            child: const Text(
              'Clear All',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
