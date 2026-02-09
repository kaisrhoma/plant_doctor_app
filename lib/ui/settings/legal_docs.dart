import 'package:flutter/material.dart';
import '../../core/app_theme.dart'; // عدّل المسار حسب مشروعك

class LegalDocs {
  static List<_LegalDoc> docs({required bool isAr}) => [
        _LegalDoc(
          icon: Icons.rule_folder_outlined,
          title: isAr ? 'شروط الاستخدام' : 'Terms of Use',
          body: isAr ? _arTerms : _enTerms,
        ),
        _LegalDoc(
          icon: Icons.privacy_tip_outlined,
          title: isAr ? 'سياسة الخصوصية' : 'Privacy Policy',
          body: isAr ? _arPrivacy : _enPrivacy,
        ),
        _LegalDoc(
          icon: Icons.warning_amber_rounded,
          title: isAr ? 'إخلاء المسؤولية' : 'Disclaimer',
          body: isAr ? _arDisclaimer : _enDisclaimer,
        ),
        _LegalDoc(
          icon: Icons.gavel_outlined,
          title: isAr ? 'حقوق الملكية والترخيص' : 'IP & License',
          body: isAr ? _arIp : _enIp,
        ),
      ];

  static Future<void> openDocSheet(
    BuildContext context, {
    required String title,
    required String body,
  }) async {
    final t = Theme.of(context);

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: t.bottomSheetTheme.backgroundColor,
      builder: (ctx) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.82,
            minChildSize: 0.45,
            maxChildSize: 0.95,
            builder: (_, controller) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: t.textTheme.titleLarge?.copyWith(
                        color: t.brightness == Brightness.dark
                            ? Colors.white
                            : AppTheme.titleTheme,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: t.brightness == Brightness.dark
                              ? const Color(0xFF1E1E1E)
                              : AppTheme.backraoundCard,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SingleChildScrollView(
                          controller: controller,
                          padding: const EdgeInsets.all(14),
                          child: Text(
                            body,
                            style: t.textTheme.bodyMedium?.copyWith(height: 1.55),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _LegalDoc {
  final IconData icon;
  final String title;
  final String body;

  const _LegalDoc({
    required this.icon,
    required this.title,
    required this.body,
  });
}

// =======================
// AR TEXTS (Libya-aware)
// =======================
const String _arTerms = '''
شروط الاستخدام — Plant Doctor

1) القبول:
باستخدامك للتطبيق فأنت توافق على هذه الشروط. إذا لم توافق، يرجى عدم استخدام التطبيق.

2) نطاق الخدمة:
التطبيق يساعد في تشخيص أمراض النباتات واقتراح إجراءات علاجية/وقائية. النتائج تقديرية وقد تختلف حسب جودة الصور والظروف.

3) الاستخدام المسموح:
- استخدام شخصي/تعليمي/زراعي مشروع.
- عدم إساءة استخدام الخدمة، أو إدخال محتوى غير قانوني، أو محاولة اختراق/تعطيل التطبيق.

4) حماية الحساب والبيانات:
أنت مسؤول عن سرية جهازك وبيانات الدخول (إن وجدت) وأي نشاط يتم عبر جهازك.

5) الالتزام بالقوانين الليبية:
يلتزم المستخدم بعدم استخدام التطبيق بما يخالف القوانين والأنظمة النافذة في دولة ليبيا، بما في ذلك ما يتعلق بالجرائم الإلكترونية والمعاملات الإلكترونية والاتصالات.

6) القيود:
قد نقوم بتقييد أو إيقاف الخدمة مؤقتاً للصيانة أو لأسباب أمنية أو تقنية.

7) التعديل:
قد تُحدّث هذه الشروط. استمرارك في الاستخدام بعد التحديث يعني قبولك.

آخر تحديث: 2026-02-09
''';

const String _arPrivacy = '''
سياسة الخصوصية — Plant Doctor

1) ما الذي نجمعه؟
- بيانات إعدادات داخل التطبيق فقط (مثل اللغة/الوضع الليلي/تفعيل الإشعارات).
- قد تُستخدم الصور التي ترفعها للتشخيص داخل التطبيق (حسب آلية مشروعك: محلياً أو عبر خادم).

2) لماذا نجمعها؟
- لتشغيل الميزات وتحسين تجربة المستخدم.
- لتحسين دقة التشخيص (إذا كان التشخيص يعتمد على خادم).

3) أين تُخزن؟
- إعدادات التطبيق تُخزن محلياً على جهازك (SharedPreferences).
- إذا كان لديك خادم: قد تُرسل الصور/البيانات مؤقتاً لإجراء التحليل ثم تُحذف وفق سياسة الاحتفاظ.

4) المشاركة مع أطراف ثالثة:
لا نبيع بياناتك. قد نستخدم خدمات طرف ثالث (مثل إشعارات/تحليلات) فقط عند الضرورة وبالحد الأدنى.

5) الأمان:
نطبق إجراءات أمنية معقولة، لكن لا يمكن ضمان الأمان 100% على الإنترنت.

6) حقوقك:
يمكنك تعطيل الإشعارات من داخل التطبيق. ويمكنك حذف التطبيق لإزالة البيانات المحلية.

ملاحظة قانونية (ليبيا):
لا يوجد إطار “قانون حماية بيانات شامل مستقل” واضح مثل بعض الدول، لذلك تعتمد هذه السياسة على مبادئ الخصوصية العامة والالتزام بالقوانين الليبية ذات الصلة بالمعاملات الإلكترونية والجرائم الإلكترونية.

آخر تحديث: 2026-02-09
''';

const String _arDisclaimer = '''
إخلاء المسؤولية — Plant Doctor

- التطبيق يقدم معلومات إرشادية ولا يُعد بديلاً عن استشارة مهندس/خبير زراعي أو جهة رسمية.
- أي قرار علاجي تتخذه هو على مسؤوليتك.
- لا نضمن دقة 100% لنتائج التشخيص لأنها تعتمد على عوامل عديدة (الإضاءة، جودة الصورة، نوع النبات، البيئة...).
- لا نتحمل مسؤولية أي أضرار مباشرة/غير مباشرة ناتجة عن استخدام الاقتراحات داخل التطبيق.

آخر تحديث: 2026-02-09
''';

const String _arIp = '''
حقوق الملكية والترخيص — Plant Doctor

1) حقوق الملكية:
جميع محتويات التطبيق (التصميم، الشعارات، النصوص، الواجهة) محفوظة لمالكي التطبيق ما لم يُذكر خلاف ذلك.

2) ترخيص استخدام التطبيق:
يُمنح المستخدم ترخيصاً شخصياً غير حصري وغير قابل للتحويل لاستخدام التطبيق للأغراض المشروعة فقط.

3) قيود:
يُمنع النسخ أو إعادة النشر أو الهندسة العكسية أو إعادة البيع دون إذن كتابي.

4) تراخيص المكونات مفتوحة المصدر:
قد يستخدم التطبيق مكتبات مفتوحة المصدر (مثل Flutter packages). يمكنك الاطلاع على تراخيصها من صفحة “تراخيص المصادر المفتوحة” في الإعدادات.

آخر تحديث: 2026-02-09
''';

// =======================
// EN TEXTS
// =======================
const String _enTerms = '''
Terms of Use — Plant Doctor

1) Acceptance:
By using the app, you agree to these terms. If you do not agree, do not use the app.

2) Service scope:
The app helps diagnose plant diseases and suggests treatments/prevention steps. Results are estimations and may vary.

3) Allowed use:
Lawful personal/educational/agricultural use only. No abuse, illegal content, or attempts to disrupt/attack the app.

4) Device responsibility:
You are responsible for your device security and any activity through it.

5) Libya compliance:
You must not use the app in violation of applicable Libyan laws related to cybercrime, electronic transactions, and communications.

6) Limitations:
We may suspend/limit service for maintenance, security, or technical reasons.

7) Changes:
We may update these terms. Continued use means acceptance.

Last updated: 2026-02-09
''';

const String _enPrivacy = '''
Privacy Policy — Plant Doctor

1) What we collect:
- In-app settings only (language/dark mode/notifications).
- Images you upload for diagnosis (depending on your architecture: local or server-based).

2) Why we collect:
To operate features, improve UX, and (if server-based) perform diagnosis.

3) Storage:
- Settings are stored locally on your device (SharedPreferences).
- If server-based, uploads may be processed temporarily and retained per your retention rules.

4) Third parties:
We do not sell your data. We may use minimal third-party services only when necessary.

5) Security:
We apply reasonable safeguards; no online system is 100% secure.

6) Your choices:
Disable notifications in the app. Uninstalling removes local data.

Libya note:
There is no clearly-established single comprehensive data protection statute comparable to GDPR; this policy follows general privacy principles and relevant Libyan e-transactions/cybercrime frameworks.

Last updated: 2026-02-09
''';

const String _enDisclaimer = '''
Disclaimer — Plant Doctor

- Informational guidance only; not a substitute for a qualified agronomist/official advice.
- Any treatment decision is at your own risk.
- We do not guarantee 100% accuracy; results depend on many factors.
- We are not liable for direct/indirect damages arising from using suggestions.

Last updated: 2026-02-09
''';

const String _enIp = '''
IP & License — Plant Doctor

1) Ownership:
All app content (UI, branding, text) is owned by the app owners unless stated otherwise.

2) License:
You get a personal, non-exclusive, non-transferable license to use the app lawfully.

3) Restrictions:
No copying, redistribution, reverse engineering, or resale without written permission.

4) Open-source:
The app may include open-source packages; see “Open Source Licenses” in Settings.

Last updated: 2026-02-09
''';
