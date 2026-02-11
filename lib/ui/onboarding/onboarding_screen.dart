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

  // تحويل القائمة إلى Getter لتحديث النصوص بناءً على لغة السياق
  List<_OnboardPage> _getPages(bool isAr) {
    return [
      _OnboardPage(
        lottiePath: 'assets/lottie/scanning_plant.json',
        titleTop: isAr ? 'مرحبًا بك في' : 'Welcome to',
        titleMain1: 'Doctor',
        titleMain2: ' Plant',
        subtitle: '',
      ),
      _OnboardPage(
        lottiePath: 'assets/lottie/plant_growing.json',
        titleTop: '',
        titleMain1: '',
        titleMain2: '',
        subtitle: isAr
            ? 'ابدأ مع Doctor Plant واكتشف كيف يمكن تشخيص أمراض النبات بسهولة وإيجاد الحلول المناسبة.'
            : 'Start with Doctor Plant and discover how to easily diagnose plant diseases and find the right solutions.',
      ),
      _OnboardPage(
        lottiePath: 'assets/lottie/get_started.json',
        titleTop: '',
        titleMain1: 'Doctor',
        titleMain2: ' Plant',
        subtitle: isAr ? 'هيا نبدأ الآن!' : 'Let\'s get started now!',
        isLast: true,
      ),
    ];
  }

  Future<void> _finish() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('seen_onboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BottomNavScreen()),
    );
  }

  void _next() {
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
    final String languageCode = Localizations.localeOf(context).languageCode;
    final bool isAr = languageCode == 'ar';
    final pages = _getPages(isAr); // جلب الصفحات باللغة المناسبة
    final isLast = pages[_index].isLast;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() {
                  _index = i;
                  if (!pages[_index].isLast) _acceptedPrivacy = false;
                }),
                itemBuilder: (context, i) => _OnboardingItem(page: pages[i]),
              ),
            ),

            // Dots
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

            if (isLast) ...[
              Center(
                child: Directionality(
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: _acceptedPrivacy,
                        onChanged: (v) =>
                            setState(() => _acceptedPrivacy = v ?? false),
                        activeColor: AppTheme.primaryGreen,
                      ),
                      GestureDetector(
                        onTap: _openPrivacySheet,
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodySmall,
                            children: [
                              TextSpan(
                                text: isAr ? 'أوافق على ' : 'I agree to the ',
                              ),
                              TextSpan(
                                text: isAr
                                    ? 'سياسة الخصوصية'
                                    : 'Privacy Policy',
                                style: const TextStyle(
                                  color: AppTheme.accentGreen,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

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
                        child: Text(
                          isAr ? 'ابدأ' : 'Get Started',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : _CircleArrowButton(onTap: _next, isAr: isAr),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleArrowButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isAr;
  const _CircleArrowButton({required this.onTap, required this.isAr});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
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
            child: Icon(
              // عكس السهم إذا كانت اللغة عربية
              isAr ? Icons.arrow_back : Icons.arrow_forward,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

// ... بقية كلاسات _OnboardingItem و _PrivacyPolicySheet (التي قمت بتعديلها سابقاً) تظل كما هي ...

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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppTheme.titleTheme,
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
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : AppTheme.titleTheme,
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
    final String languageCode = Localizations.localeOf(context).languageCode;
    final bool isAr = languageCode == 'ar';
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (context, controller) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Color(0xFF1E1E1E)
                  : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
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
                  isAr ? 'سياسة الخصوصية' : 'Privacy Policy',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Scrollbar(
                    controller: controller,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // --- بداية محتوى السياسة المترجم ---
                          _H(
                            isAr
                                ? 'سياسة الخصوصية لتطبيق Doctor Plant'
                                : 'Privacy Policy for Doctor Plant',
                          ),
                          SizedBox(height: 10),
                          _P(
                            isAr
                                ? 'نحن نحترم خصوصيتك ونلتزم بحماية بياناتك. توضح هذه السياسة كيفية جمع المعلومات واستخدامها وحمايتها عند استخدامك للتطبيق.'
                                : 'We respect your privacy and are committed to protecting your data. This policy explains how we collect, use, and protect information when you use the app.',
                          ),

                          SizedBox(height: 14),
                          _H(
                            isAr
                                ? '1) المعلومات التي نجمعها'
                                : '1) Information We Collect',
                          ),
                          SizedBox(height: 8),
                          _B(
                            isAr
                                ? '• الصور التي تقوم برفعها لتحليل حالة النبات (إن قمت بذلك).'
                                : '• Images you upload for plant health analysis (if applicable).',
                          ),
                          _B(
                            isAr
                                ? '• معلومات تقنية عامة مثل نوع الجهاز وإصدار النظام لتحسين الأداء.'
                                : '• General technical info like device type and system version to improve performance.',
                          ),
                          _B(
                            isAr
                                ? '• لا نجمع معلومات شخصية حساسة إلا إذا أدخلتها بنفسك داخل التطبيق.'
                                : '• We do not collect sensitive personal info unless you enter it manually.',
                          ),

                          SizedBox(height: 14),
                          _H(
                            isAr
                                ? '2) كيف نستخدم المعلومات'
                                : '2) How We Use Information',
                          ),
                          SizedBox(height: 8),
                          _B(
                            isAr
                                ? '• لتحليل أمراض النبات وتقديم نتائج/توصيات.'
                                : '• To analyze plant diseases and provide results/recommendations.',
                          ),
                          _B(
                            isAr
                                ? '• لتحسين تجربة المستخدم وإصلاح الأخطاء.'
                                : '• To improve user experience and fix bugs.',
                          ),
                          _B(
                            isAr
                                ? '• لأغراض الدعم الفني عند الحاجة.'
                                : '• For technical support purposes when neede',
                          ),
                          SizedBox(height: 14),
                          _H(isAr ? '3) مشاركة البيانات' : '3) Data Sharing'),
                          SizedBox(height: 8),
                          _P(
                            isAr
                                ? 'لا نقوم ببيع بياناتك أو مشاركتها مع أطراف ثالثة لأغراض تسويقية. قد نشارك بيانات محدودة فقط عند الضرورة لتقديم الخدمة أو الامتثال للقانون.'
                                : 'We do not sell or share your data with third parties for marketing. We may share limited data only when necessary to provide the service or comply with the law.',
                          ),

                          SizedBox(height: 14),
                          _H(
                            isAr
                                ? '4) الأمان وحفظ البيانات'
                                : '4) Security and Data Retention',
                          ),
                          SizedBox(height: 8),
                          _P(
                            isAr
                                ? 'نطبق إجراءات معقولة لحماية بياناتك من الوصول غير المصرح به. ومع ذلك لا توجد طريقة آمنة 100% على الإنترنت.'
                                : 'We implement reasonable measures to protect your data. However, no method of internet transmission is 100% secure.',
                          ),

                          SizedBox(height: 14),
                          _H(isAr ? '5) حقوقك' : '5) Your Rights'),
                          SizedBox(height: 8),
                          _B(
                            isAr
                                ? '• يمكنك التوقف عن استخدام التطبيق في أي وقت.'
                                : '• You can stop using the app at any time.',
                          ),
                          _B(
                            isAr
                                ? '• يمكنك طلب حذف بياناتك إن كانت محفوظة لدينا.'
                                : '• You can request to delete your data if stored by us',
                          ),
                          SizedBox(height: 14),
                          _H(isAr ? '6) تحديثات السياسة' : '6) Policy Updates'),
                          SizedBox(height: 8),
                          _P(
                            isAr
                                ? 'قد نقوم بتحديث سياسة الخصوصية من وقت لآخر. سنعرض النسخة المحدثة داخل التطبيق عند توفرها.'
                                : 'We may update this policy from time to time. The updated version will be available within the app.',
                          ),

                          SizedBox(height: 18),
                          _P(
                            isAr
                                ? 'باستخدامك للتطبيق فإنك توافق على سياسة الخصوصية هذه.'
                                : 'By using the app, you agree to this Privacy Policy.',
                          ),

                          SizedBox(height: 20),
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
                            child: Text(
                              isAr ? 'إغلاق' : 'Close',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : AppTheme.titleTheme,
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
                            child: Text(
                              isAr ? 'أوافق' : 'I Agree',
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
    return Text(t, style: Theme.of(context).textTheme.bodyMedium);
  }
}

class _P extends StatelessWidget {
  final String t;
  const _P(this.t);

  @override
  Widget build(BuildContext context) {
    return Text(t, style: Theme.of(context).textTheme.bodySmall);
  }
}

class _B extends StatelessWidget {
  final String t;
  const _B(this.t);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(t, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
