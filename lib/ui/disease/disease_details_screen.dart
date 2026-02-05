import 'package:flutter/material.dart';
import 'package:plant_doctor_app/ui/widgets/curved_header_image.dart';
import '../../core/app_theme.dart';
import '../plant/plant_details_screen.dart';

class DiseaseDetailsScreen extends StatelessWidget {
  final String diseseTitle;
  final String diseaseImage;
  final String plantName;

  // لاحقاً من قاعدة البيانات
  final String treatment;
  final String? prevention;
  final String? notes;

  const DiseaseDetailsScreen({
    super.key,
    required this.diseseTitle,
    required this.diseaseImage,
    required this.plantName,
    this.treatment = "يتم استخراج خطة العلاج من قاعدة البيانات...",
    this.prevention = "نظافة الأدوات، تجنب الرطوبة العالية...",
    this.notes = "يفضل استشارة مهندس زراعي في الحالات المتقدمة.",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // ✅ لجعل المحتوى يمتد خلف شريط التنقل (مثل ما كنت)
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              CurvedHeaderImage(imagePath: diseaseImage, height: 250),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            diseseTitle,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              // ✅ بدل AppTheme.titleTheme الثابت
                              color: cs.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),

                          // Chip النبات (قابل للضغط)
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlantDetailsScreen(
                                    name: plantName,
                                    imagePath: diseaseImage,
                                    species: "معلومات عن $plantName",
                                  ),
                                ),
                              );
                            },
                            child: Chip(
                              label: Text(
                                plantName,
                                style: TextStyle(
                                  color: cs.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // ✅ بدل Colors.white
                              backgroundColor: theme.cardColor,
                              elevation: 2,
                              shadowColor: cs.primary.withOpacity(0.20),
                              side: BorderSide(
                                color: cs.primary.withOpacity(0.65),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              avatar: Icon(
                                Icons.local_florist,
                                color: cs.primary,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    _buildInfoCard(
                      context,
                      title: "الخطة العلاجية",
                      content: treatment,
                      icon: Icons.medical_services_outlined,
                      accentColor: Colors.blue,
                    ),

                    const SizedBox(height: 16),

                    if (prevention != null)
                      _buildInfoCard(
                        context,
                        title: "طرق الوقاية",
                        content: prevention!,
                        icon: Icons.shield_outlined,
                        accentColor: Colors.green,
                      ),

                    const SizedBox(height: 16),

                    if (notes != null)
                      _buildInfoCard(
                        context,
                        title: "ملاحظات هامة",
                        content: notes!,
                        icon: Icons.info_outline,
                        accentColor: Colors.orange,
                      ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),

          _buildBackButton(context, isDark),
        ],
      ),
    );
  }

  // بطاقة المعلومات
  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required Color accentColor,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ✅ بدل Colors.white
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: cs.onSurface.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.20 : 0.10),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Divider(
            height: 20,
            color: cs.onSurface.withOpacity(0.12),
          ),
          Text(
            content,
            style: theme.textTheme.bodySmall?.copyWith(
              // ✅ بدل AppTheme.titleTheme (الثابت)
              color: cs.onSurface.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  // زر الرجوع
  Widget _buildBackButton(BuildContext context, bool isDark) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(isDark ? 0.35 : 0.40),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
