import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/app_theme.dart';
import 'core/runtime_settings.dart';
import 'ui/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await RuntimeSettings.load();

  // لو تريد اختبار الـ Onboarding كل مرة فعّل السطرين:
  // final p = await SharedPreferences.getInstance();
  // await p.remove('seen_onboarding');

  runApp(const PlantDoctorApp());
}

class PlantDoctorApp extends StatelessWidget {
  const PlantDoctorApp({super.key});

  Future<bool> _seenOnboarding() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('seen_onboarding') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([RuntimeSettings.locale, RuntimeSettings.themeMode]),
      builder: (_, __) {
        final loc = RuntimeSettings.locale.value;
        final isAr = loc.languageCode == 'ar';

        return MaterialApp(
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

          // ✅ البداية: Splash ثم يقرر يروح Onboarding أو BottomNav
          home: SplashScreen(
            seenOnboarding: _seenOnboarding,
          ),
        );
      },
    );
  }
}
