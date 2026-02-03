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
            backgroundColor: Colors.green[800],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: imagePath,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(32),
                  ),
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
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.titleTheme,
                    ),
                  ),
                  Text(
                    species,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.green[700]),
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
                    "العائلة النباتية",
                    "الفصيلة البقولية - Fabaceae",
                  ),
                  _buildInfoSection(
                    "الانتشار في ليبيا",
                    "ينتشر بكثرة في مناطق الجبل الأخضر، ترهونة، وضواحي طرابلس.",
                  ),
                  _buildInfoSection(
                    "طرق العناية",
                    "يتحمل الجفاف بشكل جيد، يفضل الري العميق مرة أسبوعياً في الصيف.",
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "عن النبات",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "هذا النبات يعتبر من الأصناف المتأقلمة مع المناخ الليبي، ويتميز بقدرته على تحمل تقلبات درجات الحرارة بين الصيف والشتاء.",
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
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
        backgroundColor: Colors.redAccent[700],
        icon: const Icon(Icons.bug_report, color: Colors.white),
        label: const Text(
          "الأمراض وطرق الوقاية",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // دالة المعلومات التفصيلية
  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.4,
            ),
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
