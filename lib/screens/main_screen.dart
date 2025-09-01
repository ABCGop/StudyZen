import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import 'home_screen.dart';
import 'ai_chat_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppProvider, ThemeProvider>(
      builder: (context, appProvider, themeProvider, child) {
        return Scaffold(
          body: IndexedStack(
            index: appProvider.currentBottomNavIndex,
            children: const [
              AIChatScreen(),
              HomeScreen(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: themeProvider.isDarkMode 
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, -3),
                ),
              ],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // AI Tab
                    _buildNavItem(
                      context: context,
                      index: 0,
                      icon: Icons.smart_toy_outlined,
                      activeIcon: Icons.smart_toy,
                      label: 'AI Assistant',
                      isSelected: appProvider.currentBottomNavIndex == 0,
                      onTap: () => appProvider.setCurrentBottomNavIndex(0),
                      themeProvider: themeProvider,
                    ),
                    
                    // Premium Home Button (Center)
                    _buildPremiumHomeButton(
                      context: context,
                      isSelected: appProvider.currentBottomNavIndex == 1,
                      onTap: () => appProvider.setCurrentBottomNavIndex(1),
                      themeProvider: themeProvider,
                    ),
                    
                    // Profile Tab
                    _buildNavItem(
                      context: context,
                      index: 2,
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: 'Profile',
                      isSelected: appProvider.currentBottomNavIndex == 2,
                      onTap: () => appProvider.setCurrentBottomNavIndex(2),
                      themeProvider: themeProvider,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeProvider themeProvider,
  }) {
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = themeProvider.isDarkMode;
    
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isSelected 
              ? primaryColor.withOpacity(0.1) 
              : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected 
                  ? primaryColor 
                  : (isDark ? Colors.grey[400] : Colors.grey[600]),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected 
                    ? primaryColor 
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHomeButton({
    required BuildContext context,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeProvider themeProvider,
  }) {
    final isDark = themeProvider.isDarkMode;
    
    return Expanded(
      flex: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: isDark
                    ? [
                        Colors.grey[800]!,
                        Colors.grey[700]!,
                      ]
                    : [
                        Colors.grey[200]!,
                        Colors.grey[300]!,
                      ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: isDark
                      ? Colors.black.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? Icons.home : Icons.home_outlined,
                color: isSelected 
                  ? Colors.white 
                  : (isDark ? Colors.grey[400] : Colors.grey[700]),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Home',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected 
                    ? Colors.white 
                    : (isDark ? Colors.grey[400] : Colors.grey[700]),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
