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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("أمراض $plantName"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: diseasePlantList.length,
        itemBuilder: (context, index) {
          final disease = diseasePlantList[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 15),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  disease['image']!,
                  width: 65,
                  height: 65,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                disease['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("أعراض وطرق علاج $plantName"),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.redAccent,
              ),
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
            ),
          );
        },
      ),
    );
  }
}
