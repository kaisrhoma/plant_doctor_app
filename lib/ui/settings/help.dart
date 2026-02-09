import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../../core/app_theme.dart';
import '../../core/runtime_settings.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // التحقق من اللغة الحالية
    final bool isAr = RuntimeSettings.locale.value.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAr ? 'مركز المساعدة' : 'Help Center',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // قسم خطوات الاستخدام
            _buildSectionTitle(
              context,
              isAr ? 'كيفية الاستخدام' : 'How to use',
              isAr,
            ),
            _buildStepCard(
              context,
              icon: Icons.camera_alt_outlined,
              title: isAr ? 'التقط صورة واضحة' : 'Take a clear photo',
              description: isAr
                  ? 'ضع الورقة المصابة داخل المربع وتجنب الاهتزاز.'
                  : 'Place the infected leaf inside the square and avoid shaking.',
              isDark: isDark,
            ),
            _buildStepCard(
              context,
              icon: Icons.wb_sunny_outlined,
              title: isAr ? 'الإضاءة الجيدة' : 'Good Lighting',
              description: isAr
                  ? 'تأكد من وجود إضاءة كافية ليتمكن الذكاء الاصطناعي من تحليل التفاصيل.'
                  : 'Ensure there is sufficient light for the AI to analyze details.',
              isDark: isDark,
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            // قسم الأسئلة الشائعة
            _buildSectionTitle(
              context,
              isAr ? 'الأسئلة الشائعة' : 'FAQs',
              isAr,
            ),
            _buildFAQItem(
              context,
              isAr ? 'هل التطبيق دقيق دائماً؟' : 'Is the app always accurate?',
              isAr
                  ? 'التطبيق يعطي نتائج بناءً على تدريب الذكاء الاصطناعي، يفضل استشارة خبير في الحالات الحرجة.'
                  : 'The app provides results based on AI training; consult an expert in critical cases.',
            ),
            _buildFAQItem(
              context,
              isAr
                  ? 'ماذا لو لم يتعرف التطبيق على المرض؟'
                  : 'What if the app doesn\'t recognize the disease?',
              isAr
                  ? 'حاول التقاط الصورة من زاوية مختلفة أو تأكد من نظافة عدسة الكاميرا.'
                  : 'Try taking the photo from a different angle or ensure the camera lens is clean.',
            ),
          ],
        ),
      ),
    );
  }

  // عنوان القسم
  Widget _buildSectionTitle(BuildContext context, String title, bool isAr) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
    );
  }

  // بطاقة الخطوات
  Widget _buildStepCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
              child: Icon(icon, color: AppTheme.primaryGreen),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // عنصر سؤال وجواب
  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(question, style: Theme.of(context).textTheme.bodyMedium),
        iconColor: AppTheme.primaryGreen,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
