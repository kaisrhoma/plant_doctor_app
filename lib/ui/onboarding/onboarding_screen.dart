import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../navigation/bottom_nav.dart';
import '../../core/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<_OnboardPage> pages = const [
    _OnboardPage(
      lottiePath: 'assets/lottie/scanning_plant.json',
      titleTop: 'مرحبًا بك في',
      titleMain1: 'Doctor',
      titleMain2: ' Plant',
      subtitle: '',
    ),
    _OnboardPage(
      lottiePath: 'assets/lottie/plant_growing.json',
      titleTop: '',
      titleMain1: '',
      titleMain2: '',
      subtitle: 'ابدأ مع Doctor Plant واكتشف كيف يمكن تشخيص أمراض النبات بسهولة وإيجاد الحلول المناسبة.',
    ),
    _OnboardPage(
      lottiePath: 'assets/lottie/get_started.json',
      titleTop: '',
      titleMain1: 'Doctor',
      titleMain2: ' Plant',
      subtitle: 'هيا نبدأ الآن!',
      isLast: true,
    ),
  ];

  Future<void> _finish() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('seen_onboarding', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BottomNavScreen()),
    );
  }

  void _next() {
    if (_index == pages.length - 1) {
      _finish();
      return;
    }
    _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) => _OnboardingItem(page: pages[i]),
              ),
            ),

            const SizedBox(height: 8),

            // dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == i ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i ? AppTheme.accentGreen : Colors.green.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // زر تحت مثل الصورة (سهم) أو "ابدأ"
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: pages[_index].isLast
                  ? SizedBox(
                      width: 220,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: _finish,
                        child: const Text('ابدأ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    )
                  : _CircleArrowButton(onTap: _next),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingItem extends StatelessWidget {
  final _OnboardPage page;
  const _OnboardingItem({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (page.titleTop.isNotEmpty)
            Text(
              page.titleTop,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.titleTheme),
            ),

          if (page.titleMain2.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  page.titleMain1,
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                ),
                const SizedBox(width: 6),
                Text(
                  page.titleMain2,
                  style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppTheme.titleTheme),
                ),
              ],
            ),
          ],

          const SizedBox(height: 18),

          // Lottie JSON
          SizedBox(
            height: 320,
            child: Lottie.asset(page.lottiePath, fit: BoxFit.contain),
          ),

          const SizedBox(height: 18),

          if (page.subtitle.isNotEmpty)
            Text(
              page.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.5, color: Colors.grey.shade700),
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _CircleArrowButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CircleArrowButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 36,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward, color: Colors.white, size: 26),
          ),
        ),
      ),
    );
  }
}

class _OnboardPage {
  final String lottiePath;
  final String titleTop;
  final String titleMain1;
  final String titleMain2;
  final String subtitle;
  final bool isLast;

  const _OnboardPage({
    required this.lottiePath,
    required this.titleTop,
    required this.titleMain1,
    required this.titleMain2,
    required this.subtitle,
    this.isLast = false,
  });
}
