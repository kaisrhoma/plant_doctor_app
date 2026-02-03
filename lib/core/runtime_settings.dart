import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RuntimeSettings {
  static const _kLang = 'lang';
  static const _kDark = 'dark';

  static final ValueNotifier<Locale> locale = ValueNotifier(const Locale('ar'));
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

  static Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final lang = p.getString(_kLang) ?? 'ar';
    final dark = p.getBool(_kDark) ?? false;

    locale.value = Locale(lang);
    themeMode.value = dark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> setLanguage(String code) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kLang, code);
    locale.value = Locale(code);
  }

  static Future<void> setDark(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kDark, v);
    themeMode.value = v ? ThemeMode.dark : ThemeMode.light;
  }
}
