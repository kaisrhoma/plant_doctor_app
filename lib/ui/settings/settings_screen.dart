import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/runtime_settings.dart';

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

  void _about() {
    showAboutDialog(
      context: context,
      applicationName: 'Plant Doctor',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.local_florist),
      children: const [
        SizedBox(height: 8),
        Text('تطبيق لتشخيص أمراض النباتات واقتراح العلاجات.'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
                AnimatedBuilder(
                  animation: RuntimeSettings.locale,
                  builder: (_, __) {
                    final code = RuntimeSettings.locale.value.languageCode;
                    return _tile(
                      icon: Icons.language_outlined,
                      title: 'اللغة',
                      subtitle: code == 'ar' ? 'العربية' : 'English',
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
                                  title: const Text('العربية'),
                                  onChanged: (v) async {
                                    if (v != null) {
                                      await RuntimeSettings.setLanguage(v);
                                    }
                                    if (ctx.mounted) Navigator.pop(ctx);
                                  },
                                ),
                                RadioListTile<String>(
                                  value: 'en',
                                  groupValue: code,
                                  title: const Text('English'),
                                  onChanged: (v) async {
                                    if (v != null) {
                                      await RuntimeSettings.setLanguage(v);
                                    }
                                    if (ctx.mounted) Navigator.pop(ctx);
                                  },
                                ),
                                const SizedBox(height: 60),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                AnimatedBuilder(
                  animation: RuntimeSettings.themeMode,
                  builder: (_, __) {
                    final isDark =
                        RuntimeSettings.themeMode.value == ThemeMode.dark;
                    return _tile(
                      icon: Icons.dark_mode_outlined,
                      title: 'الوضع الليلي',
                      trailing: Switch(
                        value: isDark,
                        onChanged: (v) => RuntimeSettings.setDark(v),
                      ),
                      onTap: () {},
                    );
                  },
                ),

                _tile(
                  icon: Icons.notifications_none,
                  title: 'الإشعارات',
                  trailing: Switch(value: _noti, onChanged: _setNoti),
                  onTap: () {},
                ),

                _tile(
                  icon: Icons.info_outline,
                  title: 'حول التطبيق',
                  onTap: _about,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// ✅ صورة خلفية بانحناء بيضاوي ناعم (قوسين) مثل التصميم
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
      clipper: const _OvalBottomClipper(curve: 60), // ✅ غيّر الرقم إذا تريد
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Image.asset(imagePath, fit: BoxFit.cover),
      ),
    );
  }
}

/// ✅ هذا يعطي شكل بيضاوي ناعم من الأسفل (بدون خط مستقيم)
class _OvalBottomClipper extends CustomClipper<Path> {
  final double curve;

  const _OvalBottomClipper({this.curve = 62});

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    path.lineTo(0, h - curve);

    // قوس 1: يسار -> منتصف
    path.quadraticBezierTo(w * 0.25, h, w * 0.50, h);

    // قوس 2: منتصف -> يمين
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
