import 'package:flutter/material.dart';
import '../disease/disease_plant_screen.dart';
import '../../core/app_theme.dart';

class PlantDetailsScreen extends StatelessWidget {
  final String name;
  final String species;
  final String imagePath;

  const PlantDetailsScreen({
    super.key,
    required this.name,
    required this.species,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // ✅ بدل Colors.white
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: imagePath,
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: isDark ? Colors.white : AppTheme.titleTheme,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    species,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.accentGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      // ✅ بدل Colors.green[50]
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.20 : 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailIcon(context, Icons.wb_sunny, "إضاءة قوية",
                            Colors.orange),
                        _buildDetailIcon(context, Icons.water_drop, "ري متوسط",
                            Colors.blue),
                        _buildDetailIcon(context, Icons.thermostat,
                            "25°C - 30°C", Colors.redAccent),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  _buildInfoSection(
                    context,
                    "العائلة النباتية",
                    "الفصيلة البقولية - Fabaceae",
                  ),
                  _buildInfoSection(
                    context,
                    "الانتشار في ليبيا",
                    "ينتشر بكثرة في مناطق الجبل الأخضر، ترهونة، وضواحي طرابلس.",
                  ),
                  _buildInfoSection(
                    context,
                    "طرق العناية",
                    "يتحمل الجفاف بشكل جيد، يفضل الري العميق مرة أسبوعياً في الصيف.",
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "عن النبات",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "هذا النبات يعتبر من الأصناف المتأقلمة مع المناخ الليبي، ويتميز بقدرته على تحمل تقلبات درجات الحرارة بين الصيف والشتاء.",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.white70 : AppTheme.titleTheme,
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiseasePlantScreen(plantName: name),
            ),
          );
        },
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.bug_report, color: Colors.white),
        label: const Text(
          "الأمراض وطرق الوقاية",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
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
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryGreen,
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

    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
