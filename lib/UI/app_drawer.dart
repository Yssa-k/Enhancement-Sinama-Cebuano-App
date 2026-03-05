import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const AppDrawer({super.key, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundWarmOffWhite,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primaryForestGreen,
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
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
                        const Text(
                          'SINAMA',
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 28,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.only(left: 62),
                      child: Text(
                        'Translator App',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: AppColors.white,
                      size: 32,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Home
          _buildDrawerTile(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
            onTap: () {
              Navigator.pop(context);
            },
          ),

          const Divider(color: AppColors.dividerColor),

          // Exit
          _buildDrawerTile(
            icon: Icons.exit_to_app,
            activeIcon: Icons.exit_to_app,
            label: 'Exit',
            isDestructive: true,
            onTap: () {
              Navigator.pop(context);
              _showExitDialog(context);
            },
          ),
        ],
      ),
    );
  }

  /// Build custom drawer tile with modern styling
  Widget _buildDrawerTile({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppColors.primaryForestGreen,
        size: 24,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDestructive ? Colors.red : AppColors.textCharcoalGray,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      hoverColor: AppColors.secondarySageGreen.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      trailing: const Icon(
        Icons.chevron_right,
        size: 20,
        color: AppColors.textMutedGray,
      ),
    );
  }

  /// Show exit confirmation dialog
  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.white,
          title: const Text(
            'Exit App',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: AppColors.primaryForestGreen,
            ),
          ),
          content: const Text(
            'Are you sure you want to exit?',
            style: TextStyle(fontSize: 16, color: AppColors.textCharcoalGray),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textMutedGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryForestGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Exit',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.white,
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
