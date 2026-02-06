import 'package:flutter/material.dart';
import 'package:plant_doctor_app/ui/widgets/curved_header_image.dart';
import '../plant/plant_details_screen.dart';
import '../../data/database/database_helper.dart';
import '../../core/runtime_settings.dart';
import '../../core/app_theme.dart';

class DiseaseDetailsScreen extends StatefulWidget {
  final String diseaseCode;
  final String plantCode;

  const DiseaseDetailsScreen({
    super.key,
    required this.diseaseCode,
    required this.plantCode,
  });

  @override
  State<DiseaseDetailsScreen> createState() => _DiseaseDetailsScreenState();
}

class _DiseaseDetailsScreenState extends State<DiseaseDetailsScreen> {
  late Future<Map<String, dynamic>?> _diseaseFuture;
  String _lang = RuntimeSettings.locale.value.languageCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _diseaseFuture = DatabaseHelper.instance.getDiseaseFullDetails(
      diseaseCode: widget.diseaseCode,
      plantCode: widget.plantCode,
      langCode: RuntimeSettings.locale.value.languageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder(
      valueListenable: RuntimeSettings.locale,
      builder: (_, loc, __) {
        _lang = loc.languageCode;
        return Scaffold(
          // ✅ لجعل المحتوى يمتد خلف شريط التنقل (مثل ما كنت)
          extendBody: true,
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Stack(
            children: [
              FutureBuilder<Map<String, dynamic>?>(
                future: _diseaseFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(
                      child: Text(
                        _lang == 'ar'
                            ? "لا توجد بيانات للمرض"
                            : "No data available for this disease",
                      ),
                    );
                  }

                  final d = snapshot.data!;

                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      CurvedHeaderImage(
                        imagePath:
                            d['image_path'] ??
                            'assets/images/disease_placeholder.jpg',
                        height: 250,
                      ),

                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    d['disease_name'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.titleTheme,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),

                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PlantDetailsScreen(
                                            plant_code: widget.plantCode,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Chip(
                                      label: Text(
                                        d['plant_name'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                      ),
                                      avatar: Icon(
                                        Icons.local_florist,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        size: 18,
                                      ),
                                      backgroundColor: Theme.of(
                                        context,
                                      ).cardColor,
                                      elevation: 2,
                                      shadowColor: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.25),
                                      side: BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.6),
                                        width: 1,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            _buildInfoCard(
                              context,
                              title: _lang == 'ar'
                                  ? "الخطة العلاجية"
                                  : "Treatment Plan",
                              content: d['treatment'] ?? 'غير متوفر',
                              icon: Icons.medical_services_outlined,
                              accentColor: Colors.blue,
                            ),

                            if (d['prevention'] != null) ...[
                              const SizedBox(height: 16),
                              _buildInfoCard(
                                context,
                                title: _lang == 'ar'
                                    ? "طرق الوقاية"
                                    : "Prevention Methods  ",
                                content: d['prevention'],
                                icon: Icons.shield_outlined,
                                accentColor: Colors.green,
                              ),
                            ],

                            if (d['notes'] != null) ...[
                              const SizedBox(height: 16),
                              _buildInfoCard(
                                context,
                                title: _lang == 'ar' ? "ملاحظات" : "Notes",
                                content: d['notes'],
                                icon: Icons.info_outline,
                                accentColor: Colors.orange,
                              ),
                            ],

                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              _buildBackButton(context, isDark),
            ],
          ),
        );
      },
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
        border: Border.all(color: cs.onSurface.withOpacity(0.06), width: 1),
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
          Divider(height: 20, color: cs.onSurface.withOpacity(0.12)),
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
