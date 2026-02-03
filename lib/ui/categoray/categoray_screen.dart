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
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[900],
                  ),
                ),
              ),

              // حقل البحث
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'ابحث عن نباتك',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // قائمة النباتات باستخدام الـ Map الجديدة
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
                    color: Colors.black.withOpacity(0.4),
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

// ويدجت البطاقة المنفصل
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            // صورة النبات بحواف دائرية بالكامل داخل البطاقة
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  imagePath,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // تفاصيل النبات
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2D3142),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      species,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    // أيقونات الحالة
                    Row(
                      children: [
                        _buildStatusIcon(
                          Icons.wb_sunny_outlined,
                          Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        _buildStatusIcon(Icons.eco_outlined, Colors.green),
                        const SizedBox(width: 8),
                        _buildStatusIcon(
                          Icons.water_drop_outlined,
                          Colors.blue,
                        ),
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
        border: Border.all(color: color.withAlpha(80), width: 1.5),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}
