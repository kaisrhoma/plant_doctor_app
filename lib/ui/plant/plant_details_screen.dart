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
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. رأس الصفحة (الصورة)
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: AppTheme.primaryGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: imagePath,
                child: ClipRRect(
                  child: Image.asset(
                    imagePath,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.3),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

          // 2. محتوى التفاصيل - يبدأ بالعنوان
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- العنوان أولاً ---
                  Text(
                    name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.titleTheme,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    species,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.accentGreen,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- ثم شريط المعلومات السريعة ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildDetailIcon(
                          Icons.wb_sunny,
                          "إضاءة قوية",
                          Colors.orange,
                        ),
                        _buildDetailIcon(
                          Icons.water_drop,
                          "ري متوسط",
                          Colors.blue,
                        ),
                        _buildDetailIcon(
                          Icons.thermostat,
                          "25°C - 30°C",
                          Colors.redAccent,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- ثم المعلومات التفصيلية والانتشار ---
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "هذا النبات يعتبر من الأصناف المتأقلمة مع المناخ الليبي، ويتميز بقدرته على تحمل تقلبات درجات الحرارة بين الصيف والشتاء.",
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppTheme.titleTheme),
                  ),

                  const SizedBox(height: 120), // مساحة للزر السفلي
                ],
              ),
            ),
          ),
        ],
      ),

      // الزر السفلي
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

  // دالة المعلومات التفصيلية
  Widget _buildInfoSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.titleTheme),
          ),
          const Divider(height: 20),
        ],
      ),
    );
  }

  // دالة أيقونات الشريط
  Widget _buildDetailIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
