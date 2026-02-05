import 'package:flutter/material.dart';
import 'disease_details_screen.dart';

final List<Map<String, String>> diseasePlantList = [
  {"title": "مرض البياض الدقيقي", "image": "assets/images/yellow.jpg"},
  {
    "title": "حشرة المن (الندوة العسلية)",
    "image": "assets/images/leaf_spot.jpg",
  },
  {"title": "مرض صدأ الأوراق", "image": "assets/images/brown.jpg"},
  {"title": "تعفن الجذور السطحي", "image": "assets/images/leaf_spot.jpg"},
  {"title": "نقص عنصر الحديد (اصفرار)", "image": "assets/images/wilting.jpg"},
];

class DiseasePlantScreen extends StatelessWidget {
  final String plantName;

  const DiseasePlantScreen({super.key, required this.plantName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // ✅ بدل Colors.white
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "أمراض $plantName",
          style: theme.textTheme.bodyLarge?.copyWith(
            // ✅ خلي العنوان واضح في الدارك
            color: isDark ? Colors.white : null,
          ),
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
                hintText: "ابحث عن مرض",
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

          // قائمة الأمراض
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: diseasePlantList.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final disease = diseasePlantList[index];
              return DiseaseCard(
                title: disease['title']!,
                subtitle: "أعراض وطرق علاج ${disease['title']}",
                imagePath: disease['image']!,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiseaseDetailsScreen(
                        diseseTitle: disease['title']!,
                        diseaseImage: disease['image']!,
                        plantName: plantName,
                      ),
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 20),

          Text(
            'لا توجد أمراض أخرى لهذا النبات.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withOpacity(0.55),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
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
        border: Border.all(
          color: cs.onSurface.withOpacity(0.06),
          width: 1,
        ),
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
                        color: cs.onSurface.withOpacity(0.65),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildStatusIcon(cs, Icons.wb_sunny_outlined,
                            Colors.orange),
                        const SizedBox(width: 8),
                        _buildStatusIcon(cs, Icons.eco_outlined, Colors.green),
                        const SizedBox(width: 8),
                        _buildStatusIcon(
                            cs, Icons.water_drop_outlined, Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                Icons.chevron_right,
                color: cs.primary,
              ),
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
        border: Border.all(
          color: color.withOpacity(0.55),
          width: 1.5,
        ),
        // ✅ خلفية خفيفة تتبع السطح
        color: cs.surface.withOpacity(0.20),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}
