import 'package:flutter/material.dart';
import '../disease/disease_plant_screen.dart';
import '../../core/app_theme.dart';
import '../../data/database/database_helper.dart';
import '../../core/runtime_settings.dart';

class PlantDetailsScreen extends StatefulWidget {
  final String plant_code;

  const PlantDetailsScreen({super.key, required this.plant_code});

  @override
  State<PlantDetailsScreen> createState() => _PlantDetailsScreenState();
}

class _PlantDetailsScreenState extends State<PlantDetailsScreen> {
  late Future<Map<String, dynamic>?> _plantFuture;
  String _lang = 'ar';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPlant();
  }

  void _loadPlant() {
    _plantFuture = DatabaseHelper.instance.getPlantFullDetails(
      plantCode: widget.plant_code,
      langCode: RuntimeSettings.locale.value.languageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cs = theme.colorScheme;

    return ValueListenableBuilder(
      valueListenable: RuntimeSettings.locale,
      builder: (_, loc, __) {
        _lang = loc.languageCode;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                backgroundColor: AppTheme.primaryGreen,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: FutureBuilder<Map<String, dynamic>?>(
                    future: _plantFuture,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return const SizedBox();
                      }
                      final plant = snapshot.data!;
                      final imagePath = plant['image_path'];

                      return imagePath != null
                          ? Image.asset(imagePath, fit: BoxFit.cover)
                          : const Icon(Icons.local_florist, size: 120);
                    },
                  ),
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.30),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: FutureBuilder<Map<String, dynamic>?>(
                  future: _plantFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return Center(
                        child: Text(
                          _lang == "ar"
                              ? "لا توجد بيانات للنبات"
                              : "No data available for this plant",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface,
                          ),
                        ),
                      );
                    }

                    final plant = snapshot.data!;

                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //  اللون فقط (بدون تغيير الحجم)
                          Text(
                            plant['plant_name'],
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppTheme.titleTheme,
                            ),
                          ),

                          const SizedBox(height: 24),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    isDark ? 0.20 : 0.08,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildDetailIcon(
                                  context,
                                  Icons.wb_sunny,
                                  plant['sunlight'] ??
                                      (_lang == "ar"
                                          ? 'غير محدد'
                                          : 'Not Specified'),
                                  Colors.orange,
                                ),
                                _buildDetailIcon(
                                  context,
                                  Icons.water_drop,
                                  plant['watering'] ??
                                      (_lang == "ar"
                                          ? 'غير محدد'
                                          : 'Not Specified'),
                                  Colors.blue,
                                ),
                                _buildDetailIcon(
                                  context,
                                  Icons.thermostat,
                                  plant['min_temp'] != null &&
                                          plant['max_temp'] != null
                                      ? "${plant['min_temp']}°C - ${plant['max_temp']}°C"
                                      : (_lang == "ar"
                                          ? "غير محددة"
                                          : "Not Specified"),
                                  Colors.redAccent,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          _buildInfoSection(
                            context,
                            _lang == 'ar' ? "المملكة" : "Kingdom",
                            plant['kingdom'] ?? 'غير متوفر',
                          ),
                          _buildInfoSection(
                            context,
                            _lang == 'ar' ? "الشعبة" : "Phylum",
                            plant['phylum'] ?? 'غير متوفر',
                          ),
                          _buildInfoSection(
                            context,
                            _lang == 'ar' ? "الطائفة" : "Class",
                            plant['class'] ?? 'غير متوفر',
                          ),
                          _buildInfoSection(
                            context,
                            _lang == 'ar' ? "الرتبة" : "Order",
                            plant['plant_order'] ?? 'غير متوفر',
                          ),
                          _buildInfoSection(
                            context,
                            _lang == 'ar'
                                ? "العائلة النباتية"
                                : "Plant Family",
                            plant['family'] ?? 'غير متوفر',
                          ),
                          _buildInfoSection(
                            context,
                            _lang == 'ar' ? "الجنس" : "Genus",
                            plant['genus'] ?? 'غير متوفر',
                          ),
                          _buildInfoSection(
                            context,
                            _lang == "ar" ? "الانتشار" : "Growth Regions",
                            plant['growth_regions'] ??
                                (_lang == 'ar' ? 'غير متوفر' : 'Not Available'),
                          ),
                          _buildInfoSection(
                            context,
                            _lang == "ar" ? "طرق العناية" : "Care Tips",
                            plant['care_tips'] ?? 'غير متوفر',
                          ),

                          const SizedBox(height: 24),

                          //  اللون فقط
                          Text(
                            _lang == "ar" ? "عن النبات" : "About the Plant",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark ? Colors.white : AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          //  اللون فقط (بدون تغيير الحجم)
                          Text(
                            (plant['plant_description'] ?? '') +
                                (plant['country_notes'] ?? ''),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.white70 : AppTheme.titleTheme,
                            ),
                          ),

                          const SizedBox(height: 120),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FutureBuilder<Map<String, dynamic>?>(
            future: _plantFuture,
            builder: (context, snapshot) {
              final plant = snapshot.data;
              return FloatingActionButton.extended(
                onPressed: plant == null
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiseasePlantScreen(
                              plantCode: plant['plant_code'],
                            ),
                          ),
                        );
                      },
                backgroundColor: AppTheme.primaryGreen,
                icon: const Icon(Icons.bug_report, color: Colors.white),
                label: Text(
                  _lang == 'ar'
                      ? "الأمراض وطرق الوقاية"
                      : "Diseases and Prevention",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ اللون فقط
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white : AppTheme.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          Text(
            content,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? Colors.white70 : AppTheme.titleTheme,
            ),
          ),

          const Divider(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailIcon(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 4,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9,
              color: isDark ? Colors.white54 : Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
