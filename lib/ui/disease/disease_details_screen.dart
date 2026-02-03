import 'package:flutter/material.dart';
import 'package:plant_doctor_app/ui/widgets/curved_header_image.dart';

class DiseaseDetailsScreen extends StatelessWidget {
  final String diseseTitle;
  final String diseaseImage;
  final String plantName; // المتغير الجديد لاستقبال اسم النبات

  const DiseaseDetailsScreen({
    super.key,
    required this.diseseTitle,
    required this.diseaseImage,
    required this.plantName, // مطلوب عند الانتقال
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              CurvedHeaderImage(imagePath: diseaseImage, height: 220),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    // عرض اسم المشكلة
                    Text(
                      diseseTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // عرض اسم النبات (الذي مررناه من البطاقة)
                    Text(
                      "النبات: $plantName",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'هنا سيتم عرض محتوى الفئة وتفاصيل المرض وكيفية علاجه...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),

          // 🔙 زر الرجوع (يبقى كما هو)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
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
