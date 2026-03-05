import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top header with rounded bottom corners
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
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 36,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 24),
                      ],
                    ),
                    const Spacer(),
                    // Help title in header with logo
                    Stack(
                      children: [
                        // Logo positioned to the far left
                        Positioned(
                          left: 5,
                          top: 0,
                          child: Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent,
                            ),
                            child: ClipOval(
                              child: Transform.scale(
                                scale: 1.3,
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const SizedBox(
                                      width: 55,
                                      height: 55,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Centered text
                        const Center(
                          child: Text(
                            'HELP',
                            style: TextStyle(
                              color: AppColors.primaryForestGreen,
                              fontWeight: FontWeight.w900,
                              fontSize: 40,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Help content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(
                        Icons.chevron_right,
                        size: 24,
                        color: AppColors.primaryForestGreen,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Searching word with text',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(
                        Icons.chevron_right,
                        size: 24,
                        color: AppColors.primaryForestGreen,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Searching words with speech',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(
                        Icons.chevron_right,
                        size: 24,
                        color: AppColors.primaryForestGreen,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Navigation to other page',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom bar
          Container(
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primaryForestGreen,
            ),
          ),
        ],
      ),
    );
  }
}
