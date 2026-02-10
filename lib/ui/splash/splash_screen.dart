import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plant_doctor_app/core/app_theme.dart';
import '../../navigation/bottom_nav.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  final Future<bool> Function() seenOnboarding;

  const SplashScreen({super.key, required this.seenOnboarding});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // إعداد الانيميشن للمسح (Scanner Animation)
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // تكرار الحركة صعوداً وهبوطاً

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    _goNext();
  }

  @override
  void dispose() {
    _animationController.dispose(); // ضروري لإغلاق الـ Controller من الذاكرة
    super.dispose();
  }

  Future<void> _goNext() async {
    // ننتظر 3 ثوانٍ لنعطي فرصة للمستخدم لرؤية تأثير المسح
    await Future.delayed(const Duration(seconds: 3));

    final seen = await widget.seenOnboarding();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            seen ? const BottomNavScreen() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const double imageSize = 160.0;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // حاوية الصورة مع تأثير المسح
            Stack(
              children: [
                // 1. الصورة الأصلية
                Image.asset(
                  'assets/images/spl.png',
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.contain,
                ),

                // 2. تأثير الخط المتحرك (Scanner Line)
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Positioned(
                      top:
                          _animation.value * imageSize, // التحريك من أعلى لأسفل
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 2, // سماكة الخط
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withOpacity(0.8),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              cs.primary,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Plant Doctor',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.accentGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
