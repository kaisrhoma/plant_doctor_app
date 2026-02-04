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
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: _screens[_currentIndex],

      // 📸 زر الكاميرا الدائري
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: AppTheme.primaryGreen,
          elevation: 8,
          onPressed: () {
            setState(() => _currentIndex = 1);
          },
          child: const Icon(Icons.camera_alt, size: 32, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        height: 55.0,

        // ✅ الحل: إذا كان الوضع داكن، استخدم لون داكن، وإلا استخدم لونك الفاتح
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E1E1E) // لون رمادي غامق للوضع الليلي
            : AppTheme.backraoundCard, // لونك الأخضر الفاتح للوضع العادي
        elevation: 0, // إزالة الخط والظل
        // surfaceTintColor: Colors
        //     .transparent, // ضروري جداً في Material 3 لمنع تلوين الشريط تلقائياً
        notchMargin: 8,
        child: SizedBox(
          height: 30, // أقل ارتفاع وأكثر حداثة
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.home,
                  size: 28, // ⬆️ تكبير الأيقونة
                ),
                color: _currentIndex == 0 ? AppTheme.primaryGreen : Colors.grey,
                onPressed: () {
                  setState(() => _currentIndex = 0);
                },
              ),

              const SizedBox(width: 40), // مكان زر الكاميرا

              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.settings,
                  size: 28, // ⬆️ تكبير الأيقونة
                ),
                color: _currentIndex == 2 ? AppTheme.primaryGreen : Colors.grey,
                onPressed: () {
                  setState(() => _currentIndex = 2);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
