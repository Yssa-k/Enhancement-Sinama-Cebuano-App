import 'package:flutter/material.dart';
import 'modern_translation_screen.dart';
import 'help_dialog.dart';
import 'app_drawer.dart';
import 'modern_history_screen.dart';
import 'modern_favorites_screen.dart';
import 'modern_settings_screen.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedBottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(scaffoldKey: _scaffoldKey),
      appBar: _buildModernAppBar(),
      body: _buildMainContent(),
      bottomNavigationBar: _buildModernBottomNavBar(),
    );
  }

  /// Modern Top App Bar with SINAMA logo and centered title
  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 4,
      backgroundColor: AppColors.primaryForestGreen,
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: AppColors.white, size: 26),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            tooltip: 'Menu',
          );
        },
      ),
      actions: [],
      title: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo
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
            // App Name
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
      ),
      centerTitle: true,
    );
  }

  /// Main content area with pill-shaped SINAMA button
  Widget _buildMainContent() {
    return Container(
      color: AppColors.backgroundWarmOffWhite,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Welcome message
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  Text(
                    'Welcome to',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.textMutedGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SINAMA Translator',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.primaryForestGreen,
                    ),
                  ),
                ],
              ),
            ),

            // Main action button - Pill shaped with forest green
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ModernTranslationScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryForestGreen,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryForestGreen.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: AppColors.primaryForestGreen.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Text(
                  'Start Translating',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Quick links section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickLinkCard(
                    icon: Icons.history,
                    label: 'Recent',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ModernHistoryScreen(
                            key: ValueKey(
                              DateTime.now().millisecondsSinceEpoch,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildQuickLinkCard(
                    icon: Icons.favorite,
                    label: 'Favorite',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ModernFavoritesScreen(
                            key: ValueKey(
                              DateTime.now().millisecondsSinceEpoch,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildQuickLinkCard(
                    icon: Icons.settings,
                    label: 'Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ModernSettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Quick link card widget
  Widget _buildQuickLinkCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: AppColors.primaryForestGreen),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textCharcoalGray,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Modern bottom navigation bar with three tabs: Home, About, Help
  Widget _buildModernBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryForestGreen,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedBottomNavIndex,
          onTap: (index) {
            setState(() => _selectedBottomNavIndex = index);
            // Handle tab actions
            if (index == 1) {
              // About tab
              _showAboutDialog(context);
            } else if (index == 2) {
              // Help tab
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.accentMutedGold,
          unselectedItemColor: AppColors.white.withOpacity(0.7),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 26),
              activeIcon: Icon(Icons.home, size: 26),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info_outline, size: 26),
              activeIcon: Icon(Icons.info, size: 26),
              label: 'About Us',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.help_outline, size: 26),
              activeIcon: Icon(Icons.help, size: 26),
              label: 'How to Use',
            ),
          ],
        ),
      ),
    );
  }

  /// Show About this App dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.white,
          title: const Text(
            'About Us',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForestGreen,
              fontSize: 18,
            ),
          ),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.help_outline,
                      size: 24,
                      color: AppColors.primaryForestGreen,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This application is a joint project between researchers of Bohol Island State University - Main Campus, Tagbilaran City, Bohol and Totolan Elementary School, Dauis, Bohol.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textCharcoalGray,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      size: 24,
                      color: AppColors.primaryForestGreen,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This project aims to bridge the language barrier between Badjaon students and educators of Totolan Elementary School.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textCharcoalGray,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 24,
                      color: AppColors.primaryForestGreen,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'The researchers of this project are:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textCharcoalGray,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '> John Derick Quiachon\n> Allysa Rose Ligaya\n> Raquel Muga',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textCharcoalGray,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.sentiment_satisfied_alt,
                      size: 24,
                      color: AppColors.primaryForestGreen,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Special thanks to the instructors that made this project possible:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textCharcoalGray,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '> Mrs. Deanne Cameren Evangelista\n> Mrs. Editha Legasong\n> Mrs. Agustina Colonos\n> Mrs. Enerlena Vilano Liesa',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textCharcoalGray,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.volunteer_activism,
                      size: 24,
                      color: AppColors.primaryForestGreen,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Special thanks to the volunteers that contribute their voice for this project:',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textCharcoalGray,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '> Roque Adolfo\n> Angel Rose Orbolo\n> Lynle Cadenao\n> Jesse Caipara\n> Joseff Mar Luis Gumabon\n> John Rey Gamil\n> Arfe Grace Rosales\n> Ghea Rosales\n> Laurine Selocelo\n> John Kyle Tajon',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textCharcoalGray,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: AppColors.primaryForestGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
