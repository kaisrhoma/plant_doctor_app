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

  bool _acceptedPrivacy = false;

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
      subtitle:
          'ابدأ مع Doctor Plant واكتشف كيف يمكن تشخيص أمراض النبات بسهولة وإيجاد الحلول المناسبة.',
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
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _openPrivacySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PrivacyPolicySheet(
        onAccept: () {
          setState(() => _acceptedPrivacy = true);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = pages[_index].isLast;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() {
                  _index = i;

                  // اختياري: لو خرج من الصفحة الأخيرة نلغي الموافقة
                  if (!pages[_index].isLast) _acceptedPrivacy = false;
                }),
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
                    color: _index == i
                        ? AppTheme.accentGreen
                        : Colors.green.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ✅ Checkbox فوق زر "ابدأ" وبالمنتصف (يظهر فقط في الصفحة الأخيرة)
            if (isLast) ...[
              Center(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: IntrinsicWidth(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: _acceptedPrivacy,
                          onChanged: (v) =>
                              setState(() => _acceptedPrivacy = v ?? false),
                          activeColor: AppTheme.primaryGreen,
                        ),
                        Wrap(
                          children: [
                            Text(
                              'أوافق على ',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            GestureDetector(
                              onTap: _openPrivacySheet,
                              child: Text(
                                'سياسة الخصوصية',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.accentGreen,
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // ✅ زر تحت
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: isLast
                  ? SizedBox(
                      width: 220,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _acceptedPrivacy ? _finish : null,
                        child: const Text(
                          'ابدأ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.titleTheme,
              ),
            ),

          if (page.titleMain2.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  page.titleMain1,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  page.titleMain2,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.titleTheme,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 18),

          SizedBox(
            height: 320,
            child: Lottie.asset(page.lottiePath, fit: BoxFit.contain),
          ),

          const SizedBox(height: 18),

          if (page.subtitle.isNotEmpty)
            Text(
              page.subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
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
            child: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 26,
            ),
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

class _PrivacyPolicySheet extends StatelessWidget {
  final VoidCallback onAccept;
  const _PrivacyPolicySheet({required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (context, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'سياسة الخصوصية',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _H('سياسة الخصوصية لتطبيق Doctor Plant'),
                          SizedBox(height: 10),
                          _P(
                            'نحن نحترم خصوصيتك ونلتزم بحماية بياناتك. توضح هذه السياسة كيفية جمع المعلومات واستخدامها وحمايتها عند استخدامك للتطبيق.',
                          ),
                          SizedBox(height: 14),
                          _H('1) المعلومات التي نجمعها'),
                          SizedBox(height: 8),
                          _B('• الصور التي تقوم برفعها لتحليل حالة النبات (إن قمت بذلك).'),
                          _B('• معلومات تقنية عامة مثل نوع الجهاز وإصدار النظام لتحسين الأداء.'),
                          _B('• لا نجمع معلومات شخصية حساسة إلا إذا أدخلتها بنفسك داخل التطبيق.'),
                          SizedBox(height: 14),
                          _H('2) كيف نستخدم المعلومات'),
                          SizedBox(height: 8),
                          _B('• لتحليل أمراض النبات وتقديم نتائج/توصيات.'),
                          _B('• لتحسين تجربة المستخدم وإصلاح الأخطاء.'),
                          _B('• لأغراض الدعم الفني عند الحاجة.'),
                          SizedBox(height: 14),
                          _H('3) مشاركة البيانات'),
                          SizedBox(height: 8),
                          _P(
                            'لا نقوم ببيع بياناتك أو مشاركتها مع أطراف ثالثة لأغراض تسويقية. قد نشارك بيانات محدودة فقط عند الضرورة لتقديم الخدمة أو الامتثال للقانون.',
                          ),
                          SizedBox(height: 14),
                          _H('4) الأمان وحفظ البيانات'),
                          SizedBox(height: 8),
                          _P(
                            'نطبق إجراءات معقولة لحماية بياناتك من الوصول غير المصرح به. ومع ذلك لا توجد طريقة آمنة 100% على الإنترنت.',
                          ),
                          SizedBox(height: 14),
                          _H('5) حقوقك'),
                          SizedBox(height: 8),
                          _B('• يمكنك التوقف عن استخدام التطبيق في أي وقت.'),
                          _B('• يمكنك طلب حذف بياناتك إن كانت محفوظة لدينا (إن وُجدت).'),
                          _B('• يمكنك مراجعة هذه السياسة في أي وقت.'),
                          SizedBox(height: 14),
                          _H('6) تحديثات السياسة'),
                          SizedBox(height: 8),
                          _P(
                            'قد نقوم بتحديث سياسة الخصوصية من وقت لآخر. سنعرض النسخة المحدثة داخل التطبيق عند توفرها.',
                          ),
                          SizedBox(height: 18),
                          _P('باستخدامك للتطبيق فإنك توافق على سياسة الخصوصية هذه.'),
                          SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.titleTheme,
                              side: BorderSide(
                                color: AppTheme.primaryGreen.withOpacity(0.5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'إغلاق',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: onAccept,
                            child: const Text(
                              'أوافق',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _H extends StatelessWidget {
  final String t;
  const _H(this.t);

  @override
  Widget build(BuildContext context) {
    return Text(t, style: Theme.of(context).textTheme.bodyLarge);
  }
}

class _P extends StatelessWidget {
  final String t;
  const _P(this.t);

  @override
  Widget build(BuildContext context) {
    return Text(t, style: Theme.of(context).textTheme.bodyMedium);
  }
}

class _B extends StatelessWidget {
  final String t;
  const _B(this.t);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(t, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
