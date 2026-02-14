import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/runtime_settings.dart';
import '../../core/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _kNoti = 'noti';
  bool _noti = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNoti();
  }

  Future<void> _loadNoti() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _noti = p.getBool(_kNoti) ?? true;
      _loading = false;
    });
  }

  Future<void> _setNoti(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kNoti, v);
    setState(() => _noti = v);
  }

  // ✅ BottomSheet للتراخيص: عناوين ملوّنة + نص صغير رمادي (لايت)
  Future<void> _licensesSheet({required bool isAr}) async {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;

    final titleStyle = t.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : AppTheme.titleTheme,
    );

    final bodyStyle = t.textTheme.bodySmall?.copyWith(
      height: 1.45,
      color: isDark ? const Color(0xFFDDDDDD) : const Color(0xFF777777),
    );

    final items = isAr
        ? const [
            ('شروط الاستخدام', 'استخدام مشروع فقط. النتائج إرشادية وقد تختلف.'),
            (
              'سياسة الخصوصية',
              'نحفظ إعداداتك محليًا. صور التشخيص للتحليل فقط.',
            ),
            (
              'إخلاء المسؤولية',
              'ليس بديلاً عن خبير زراعي. القرار على مسؤوليتك.',
            ),
            (
              'حقوق الملكية والترخيص',
              'محتوى التطبيق محفوظ. يمنع النسخ دون إذن.',
            ),
          ]
        : const [
            (
              'Terms of Use',
              'Lawful use only. Results are guidance and may vary.',
            ),
            (
              'Privacy Policy',
              'Settings stored locally. Diagnosis images for analysis only.',
            ),
            (
              'Disclaimer',
              'Not a substitute for an agronomist. Decisions are yours.',
            ),
            (
              'IP & License',
              'App content is protected. No copying without permission.',
            ),
          ];

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: t.bottomSheetTheme.backgroundColor,
      builder: (ctx) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.65,
            minChildSize: 0.40,
            maxChildSize: 0.95,
            builder: (_, controller) {
              return ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  Text(
                    isAr ? 'التراخيص والسياسات' : 'Licenses & Policies',
                    style: t.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),

                  ...items.expand(
                    (e) => [
                      Text(e.$1, style: titleStyle),
                      const SizedBox(height: 4),
                      Text(e.$2, style: bodyStyle),
                      const SizedBox(height: 10),
                    ],
                  ),

                  const SizedBox(height: 6),

                
                ],
              );
            },
          ),
        );
      },
    );
  }

  // ✅ About dialog مخصص (بدون زر "الاطلاع على التراخيص" اللي فوق)
  void _about({required bool isAr}) {
    final t = Theme.of(context);
    final isDark = t.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: t.dialogTheme.backgroundColor,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Plant Doctor',
                    style: t.textTheme.titleLarge?.copyWith(
                      color: isDark ? Colors.white : AppTheme.titleTheme,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              Align(
                alignment: AlignmentDirectional.center,
                child: Text(
                  '1.0.0',
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            isAr
                ? 'تطبيق لتشخيص أمراض النباتات واقتراح العلاجات.'
                : 'An app to diagnose plant diseases and suggest treatments.',
            textAlign: TextAlign.center,
            style: t.textTheme.bodyMedium,
          ),

          // ✅ فقط الزر اللي تحت (الاطلاع على التراخيص) + إغلاق
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _licensesSheet(isAr: isAr);
              },
              child: Text(
                isAr ? 'الاطلاع على التراخيص' : 'View licenses',
                style: t.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                isAr ? 'الإغلاق' : 'Close',
                style: t.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? const Color(0xFFDDDDDD)
                      : const Color(0xFF777777),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        RuntimeSettings.locale,
        RuntimeSettings.themeMode,
      ]),
      builder: (_, __) {
        final code = RuntimeSettings.locale.value.languageCode;
        final isAr = code == 'ar';
        final isDark = RuntimeSettings.themeMode.value == ThemeMode.dark;

        return Scaffold(
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              const _CurvedHeaderImage(
                imagePath: 'assets/images/image.png',
                height: 200,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 🌐 اللغة
                    _tile(
                      icon: Icons.language_outlined,
                      title: isAr ? 'اللغة' : 'Language',
                      subtitle: isAr
                          ? (code == 'ar' ? 'العربية' : 'الإنجليزية')
                          : (code == 'ar' ? 'Arabic' : 'English'),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          builder: (ctx) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RadioListTile<String>(
                                  value: 'ar',
                                  groupValue: code,
                                  title: Text(
                                    'العربية',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  onChanged: (v) async {
                                    if (v != null)
                                      await RuntimeSettings.setLanguage(v);
                                    if (ctx.mounted) Navigator.pop(ctx);
                                  },
                                ),
                                RadioListTile<String>(
                                  value: 'en',
                                  groupValue: code,
                                  title: Text(
                                    'English',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  onChanged: (v) async {
                                    if (v != null)
                                      await RuntimeSettings.setLanguage(v);
                                    if (ctx.mounted) Navigator.pop(ctx);
                                  },
                                ),
                                const SizedBox(height: 60),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    // 🌙 الوضع الليلي
                    _tile(
                      icon: Icons.dark_mode_outlined,
                      title: isAr ? 'الوضع الليلي' : 'Dark mode',
                      trailing: Switch(
                        value: isDark,
                        onChanged: (v) => RuntimeSettings.setDark(v),
                      ),
                      onTap: () {},
                    ),

                    // 🔔 الإشعارات
                    _tile(
                      icon: Icons.notifications_none,
                      title: isAr ? 'الإشعارات' : 'Notifications',
                      trailing: Switch(value: _noti, onChanged: _setNoti),
                      onTap: () {},
                    ),

                    // ℹ️ حول التطبيق
                    _tile(
                      icon: Icons.info_outline,
                      title: isAr ? 'حول التطبيق' : 'About',
                      onTap: () => _about(isAr: isAr),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final t = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: t.brightness == Brightness.dark ? t.cardColor : Colors.white,
      surfaceTintColor: Colors.transparent,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: t.textTheme.bodyMedium),
        subtitle: subtitle != null
            ? Text(subtitle, style: t.textTheme.bodySmall)
            : null,
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// ✅ صورة خلفية بانحناء بيضاوي ناعم
class _CurvedHeaderImage extends StatelessWidget {
  final String imagePath;
  final double height;

  const _CurvedHeaderImage({
    required this.imagePath,
    this.height = 250,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _OvalBottomClipper(curve: 60),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Image.asset(imagePath, fit: BoxFit.cover),
      ),
    );
  }
}

class _OvalBottomClipper extends CustomClipper<Path> {
  final double curve;

  const _OvalBottomClipper({this.curve = 62});

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    path.lineTo(0, h - curve);
    path.quadraticBezierTo(w * 0.25, h, w * 0.50, h);
    path.quadraticBezierTo(w * 0.75, h, w, h - curve);
    path.lineTo(w, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _OvalBottomClipper oldClipper) {
    return oldClipper.curve != curve;
  }
}
