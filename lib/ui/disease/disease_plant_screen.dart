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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "أمراض $plantName",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 20),

              // حقل البحث
              // 🔍 البحث
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "ابحث عن نباتك",
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: Colors.grey.withAlpha(100), // ← خفيف
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Colors.grey.withAlpha(100),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // قائمة النباتات باستخدام الـ Map الجديدة
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: diseasePlantList.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final disease = diseasePlantList[index];
                  return PlantCard(
                    name: disease['title']!,
                    species: "أعراض وطرق علاج ${disease['title']}",
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
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ],
      ),
    );
  }
}

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
            color: Colors.black.withAlpha(30),
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
            // صورة النبات بحواف دائرية بالكامل داخل البطاقة
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
                    Text(name, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(species, style: Theme.of(context).textTheme.bodySmall),
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
// ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: diseasePlantList.length,
//         itemBuilder: (context, index) {
//           final disease = diseasePlantList[index];
//           return Card(
//             margin: const EdgeInsets.only(bottom: 15),
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: ListTile(
//               contentPadding: const EdgeInsets.all(12),
//               leading: ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: Image.asset(
//                   disease['image']!,
//                   width: 65,
//                   height: 65,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               title: Text(
//                 disease['title']!,
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               subtitle: Text("أعراض وطرق علاج $plantName"),
//               trailing: const Icon(
//                 Icons.arrow_forward_ios,
//                 size: 16,
//                 color: Colors.redAccent,
//               ),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: 
//                   ),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }