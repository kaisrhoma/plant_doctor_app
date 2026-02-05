import 'package:flutter/material.dart';
import 'package:plant_doctor_app/ui/widgets/curved_header_image.dart';
import '../plant/plant_details_screen.dart';

// تحديث القائمة لتشمل 3 عناصر لكل نبات (الاسم، النوع، مسار الصورة)
final List<Map<String, String>> plantList = [
  {
    "name": "نباتات ورقية",
    "species": "نباتات زينة",
    "image": "assets/images/plant_leaf.jpg",
  },
  {
    "name": "زهور الربيع",
    "species": "نباتات مزهرة",
    "image": "assets/images/flowers.jpg",
  },
  {
    "name": "أشجار الفاكهة",
    "species": "أشجار مثمرة",
    "image": "assets/images/fruite.jpg",
  },
  {
    "name": "خضروات عضوية",
    "species": "محاصيل شتوية",
    "image": "assets/images/vegetables.jpg",
  },
  {
    "name": "حبوب كاملة",
    "species": "محاصيل حقلية",
    "image": "assets/images/fruite.jpg",
  },
  {
    "name": "أشجار حرجية",
    "species": "نباتات برية",
    "image": "assets/images/fruite.jpg",
  },
];

class CategoryScreen extends StatelessWidget {
  final String categoryTitle;
  final String categoryImage;

  const CategoryScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // ✅ بدل Colors.white
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              CurvedHeaderImage(imagePath: categoryImage, height: 220),
              const SizedBox(height: 20),

              // عنوان الفئة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  categoryTitle,
                  style: theme.textTheme.bodyLarge,
                ),
              ),

              const SizedBox(height: 20),

              // 🔍 البحث
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : null,
                  ),
                  decoration: InputDecoration(
                    hintText: "ابحث عن نباتك",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                    filled: true,
                    // ✅ يتبع الثيم
                    fillColor: theme.cardColor,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: (isDark
                                ? Colors.white.withOpacity(0.12)
                                : Colors.grey.withOpacity(0.25))
                            .withOpacity(1),
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

              // قائمة النباتات
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: plantList.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final plant = plantList[index];
                  return PlantCard(
                    name: plant['name']!,
                    species: plant['species']!,
                    imagePath: plant['image']!,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlantDetailsScreen(
                            name: plant['name']!,
                            imagePath: plant['image']!,
                            species: plant['species']!,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 20),

              Text(
                'لا توجد نباتات أخرى في هذه الفئة.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),

          // زر الرجوع
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    // ✅ متوافق مع الدارك
                    color: Colors.black.withOpacity(isDark ? 0.35 : 0.40),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// بطاقة النبات
class PlantCard extends StatelessWidget {
  final String name;
  final String species;
  final String imagePath;
  final VoidCallback onTap;

  const PlantCard({
    super.key,
    required this.name,
    required this.species,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                      name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      species,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white54 : null,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildStatusIcon(Icons.wb_sunny_outlined, Colors.orange),
                        const SizedBox(width: 8),
                        _buildStatusIcon(Icons.eco_outlined, Colors.green),
                        const SizedBox(width: 8),
                        _buildStatusIcon(
                            Icons.water_drop_outlined, Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.55), width: 1.5),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}
