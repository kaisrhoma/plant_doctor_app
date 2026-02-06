import 'package:flutter/material.dart';
import 'disease_details_screen.dart';
import '../../data/database/database_helper.dart';
import '../../core/runtime_settings.dart';

class DiseasePlantScreen extends StatefulWidget {
  final String plantCode;

  const DiseasePlantScreen({super.key, required this.plantCode});

  @override
  State<DiseasePlantScreen> createState() => _DiseasePlantScreenState();
}

class _DiseasePlantScreenState extends State<DiseasePlantScreen> {
  String _lang = 'ar';
  late Future<List<Map<String, dynamic>>> _diseasesFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _diseasesFuture = DatabaseHelper.instance.getDiseaseNamesWithImages(
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
          // ✅ بدل Colors.white
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              _lang == 'ar' ? "أمراض النبات" : "Plant Diseases",
              style: theme.textTheme.bodyLarge,
            ),

            centerTitle: true,
            // ✅ خلي appbar يتبع الثيم
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            foregroundColor: cs.onSurface,
            elevation: 0,
          ),
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 20),

              // 🔍 البحث
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: _lang == 'ar'
                        ? "ابحث عن مرض"
                        : "Search for a disease",
                    hintStyle: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.55),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: cs.onSurface.withOpacity(0.55),
                    ),
                    filled: true,
                    // ✅ بدل Colors.white
                    fillColor: theme.cardColor,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: cs.onSurface.withOpacity(0.12),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: cs.primary.withOpacity(0.55),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              FutureBuilder<List<Map<String, dynamic>>>(
                future: _diseasesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        _lang == 'ar'
                            ? "لا توجد أمراض لهذا النبات"
                            : "No diseases for this plant",
                      ),
                    );
                  }

                  final diseases = snapshot.data!;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: diseases.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final disease = diseases[index];

                      return DiseaseCard(
                        title: disease['disease_name'],
                        subtitle: _lang == 'ar'
                            ? "اضغط لعرض التفاصيل"
                            : "Tap to view details",
                        imagePath:
                            disease['image_path'] ??
                            'assets/images/placeholder.png',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DiseaseDetailsScreen(
                                diseaseCode: disease['disease_code'],
                                plantCode: widget.plantCode,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),

              // قائمة الأمراض
              const SizedBox(height: 20),

              Text(
                _lang == 'ar'
                    ? "لا توجد أمراض أخرى لهذا النبات."
                    : "No more diseases for this plant.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withOpacity(0.55),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }
}

class DiseaseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onTap;

  const DiseaseCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        // ✅ بدل Colors.white
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.20 : 0.10),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
        border: Border.all(color: cs.onSurface.withOpacity(0.06), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(7.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  imagePath,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: cs.onSurface.withOpacity(0.65),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildStatusIcon(
                          cs,
                          Icons.wb_sunny_outlined,
                          Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        _buildStatusIcon(cs, Icons.eco_outlined, Colors.green),
                        const SizedBox(width: 8),
                        _buildStatusIcon(
                          cs,
                          Icons.water_drop_outlined,
                          Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(Icons.chevron_right, color: cs.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ColorScheme cs, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.55), width: 1.5),
        // ✅ خلفية خفيفة تتبع السطح
        color: cs.surface.withOpacity(0.20),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}
