import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_theme.dart';
import 'core/runtime_settings.dart';
import 'ui/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تفعيل وضع الحافة إلى الحافة
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent, // شفاف
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,

      // --- هذا السطر هو الحل النهائي ---
      systemNavigationBarContrastEnforced: false,

      // ---------------------------------
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await RuntimeSettings.load();
  runApp(const PlantDoctorApp());
}

// لو تريد اختبار الـ Onboarding كل مرة فعّل السطرين:
// final p = await SharedPreferences.getInstance();
// await p.remove('seen_onboarding');
class PlantDoctorApp extends StatelessWidget {
  const PlantDoctorApp({super.key});

  Future<bool> _seenOnboarding() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('seen_onboarding') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        RuntimeSettings.locale,
        RuntimeSettings.themeMode,
      ]),
      builder: (context, __) {
        final loc = RuntimeSettings.locale.value;
        final isAr = loc.languageCode == 'ar';
        final isDarkMode = RuntimeSettings.themeMode.value == ThemeMode.dark;

        // هنا نقوم بفرض ألوان شريط التنقل والحالة
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            // جعل شريط التنقل أبيض في الوضع الفاتح، وأسود (أو لون الثيم) في الوضع الداكن
            systemNavigationBarColor: isDarkMode
                ? const Color(0xFF1E1E1E) // لون رمادي غامق للوضع الليلي
                : AppTheme.backraoundCard,
            systemNavigationBarIconBrightness: isDarkMode
                ? Brightness.light
                : Brightness.dark,
            systemNavigationBarDividerColor: Colors.transparent,

            // حل مشكلة أندرويد 10+ (إزالة الطبقة الشفافة السوداء)
            systemNavigationBarContrastEnforced: false,

            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDarkMode
                ? Brightness.light
                : Brightness.dark,
          ),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: RuntimeSettings.themeMode.value,
            locale: loc,
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return Directionality(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: SplashScreen(seenOnboarding: _seenOnboarding),
          ),
        );
      },
    );
  }
}
