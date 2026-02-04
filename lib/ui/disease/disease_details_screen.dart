import 'package:flutter/material.dart';
import 'package:plant_doctor_app/ui/widgets/curved_header_image.dart';
import '../../core/app_theme.dart';
import '../plant/plant_details_screen.dart';

class DiseaseDetailsScreen extends StatelessWidget {
  final String diseseTitle;
  final String diseaseImage;
  final String plantName;
  // أضفت المتغيرات التي ستأتي من قاعدة البيانات لاحقاً
  final String treatment;
  final String? prevention;
  final String? notes;

  const DiseaseDetailsScreen({
    super.key,
    required this.diseseTitle,
    required this.diseaseImage,
    required this.plantName,
    this.treatment =
        "يتم استخراج خطة العلاج من قاعدة البيانات...", // قيم افتراضية للتجربة
    this.prevention = "نظافة الأدوات، تجنب الرطوبة العالية...",
    this.notes = "يفضل استشارة مهندس زراعي في الحالات المتقدمة.",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // لجعل المحتوى يمتد خلف شريط التنقل الشفاف الذي ضبطناه سابقاً
      extendBody: true,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              // الرأس مع الصورة المنحنية
              CurvedHeaderImage(imagePath: diseaseImage, height: 250),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // العنوان واسم النبات
                    Center(
                      child: Column(
                        children: [
                          Text(
                            diseseTitle,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.titleTheme, // تمييز اسم المرض
                                ),
                          ),
                          const SizedBox(height: 5),
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
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Colors.white,
                              // إضافة ظل خفيف ليعطي إيحاء بأنه زر قابل للضغط
                              elevation: 2,
                              shadowColor: Colors.green.withOpacity(0.3),
                              side: const BorderSide(
                                color: Colors.green,
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              avatar: const Icon(
                                Icons.local_florist,
                                color: Colors.green,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // --- قسم الخطة العلاجية (Treatment) ---
                    _buildInfoCard(
                      context,
                      title: "الخطة العلاجية",
                      content: treatment,
                      icon: Icons.medical_services_outlined,
                      accentColor: Colors.blue,
                    ),

                    const SizedBox(height: 16),

                    // --- قسم الوقاية (Prevention) ---
                    if (prevention != null)
                      _buildInfoCard(
                        context,
                        title: "طرق الوقاية",
                        content: prevention!,
                        icon: Icons.shield_outlined,
                        accentColor: Colors.green,
                      ),

                    const SizedBox(height: 16),

                    // --- قسم ملاحظات إضافية (Notes) ---
                    if (notes != null)
                      _buildInfoCard(
                        context,
                        title: "ملاحظات هامة",
                        content: notes!,
                        icon: Icons.info_outline,
                        accentColor: Colors.orange,
                      ),

                    const SizedBox(height: 80), // مساحة إضافية أسفل القائمة
                  ],
                ),
              ),
            ],
          ),

          // زر الرجوع
          _buildBackButton(context),
        ],
      ),
    );
  }

  // ودجت بناء البطاقة الاحترافية
  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
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
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: accentColor),
              ),
            ],
          ),
          const Divider(height: 20),
          Text(
            content,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.titleTheme),
          ),
        ],
      ),
    );
  }

  // زر الرجوع بتصميم طافي
  Widget _buildBackButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.4),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
