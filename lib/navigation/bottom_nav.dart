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

  late final List<Widget> _screens;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    // ✅ ضع القائمة هنا داخل الـ build
    final List<Widget> screens = [
      const HomeScreen(),
      ScanScreen(onBackToHome: () => setState(() => _currentIndex = 0)),
      const SettingsScreen(),
    ];

    // ✅ متغير للتحقق مما إذا كنا في شاشة الكاميرا
    final bool isScanning = _currentIndex == 1;

    return PopScope(
      canPop: false, // نمنع الخروج المباشر
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // المنطق: إذا لم نكن في شاشة الـ Home (Index 0)، عد إليها
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        } else {
          // إذا كنا في الـ Home أصلاً، اسمح بالخروج من التطبيق
          // ملاحظة: في الإصدارات الحديثة يمكنك استخدام SystemNavigator.pop()
          // أو جعل canPop ديناميكياً
        }
      },
      child: Scaffold(
        extendBody: true,
        body: screens[_currentIndex],

        // 📸 زر الكاميرا الدائري - يختفي عند النقر عليه
        floatingActionButton: isScanning
            ? null
            : SizedBox(
                width: 65,
                height: 65,
                child: FloatingActionButton(
                  shape: const CircleBorder(),
                  backgroundColor: AppTheme.primaryGreen,
                  elevation: 4,
                  onPressed: () => setState(() => _currentIndex = 1),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        // 🛑 شريط التنقل السفلي - يختفي عند الدخول لوضع الكاميرا
        bottomNavigationBar: isScanning
            ? const SizedBox.shrink() // مساحة فارغة لا تشغل حيزاً
            : Container(
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
                    padding: EdgeInsets.zero,
                    child: Row(
                      children: [
                        // 🏠 زر الرئيسية
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

                        const SizedBox(width: 80), // فراغ الـ FAB
                        // ⚙️ زر الإعدادات
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
      ),
    );
  }
}
