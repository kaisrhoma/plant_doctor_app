import 'package:flutter/material.dart';
import '../ui/home/home_screen.dart';
import '../ui/scan/scan_screen.dart';
import '../ui/settings/settings_screen.dart';
import '../core/app_theme.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ScanScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],

      // 📸 زر الكاميرا الدائري
      floatingActionButton: SizedBox(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: AppTheme.primaryGreen,
          elevation: 4,
          onPressed: () => setState(() => _currentIndex = 1),
          child: const Icon(Icons.camera_alt, size: 30, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.4)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: true,
          child: BottomAppBar(
            clipBehavior: Clip.antiAlias,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8.0,
            height: 55.0,
            color: isDark ? const Color(0xFF1E1E1E) : theme.cardColor,
            elevation: 0,
            // ✅ إزالة الـ Padding الافتراضي للـ BottomAppBar لتوسيع منطقة النقر
            padding: EdgeInsets.zero,
            child: Row(
              children: [
                // 🏠 زر الرئيسية - مساحة نقر كاملة
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _currentIndex = 0),
                    child: Center(
                      child: Icon(
                        Icons.home,
                        size: 28,
                        color: _currentIndex == 0
                            ? AppTheme.primaryGreen
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),

                // ⭕ فراغ زر الكاميرا (يجب أن يتناسب مع عرض الـ FAB)
                const SizedBox(width: 80),

                // ⚙️ زر الإعدادات - مساحة نقر كاملة
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _currentIndex = 2),
                    child: Center(
                      child: Icon(
                        Icons.settings,
                        size: 28,
                        color: _currentIndex == 2
                            ? AppTheme.primaryGreen
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
