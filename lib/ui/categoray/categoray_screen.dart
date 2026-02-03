import 'package:flutter/material.dart';
import '../widgets/curved_header_image.dart';

class CategoryScreen extends StatelessWidget {
  final String categoryName;
  final String imagePath;

  const CategoryScreen({
    super.key,
    required this.categoryName,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🔹 المحتوى
          ListView(
            padding: EdgeInsets.zero,
            children: [
              CurvedHeaderImage(
                imagePath: imagePath,
                height: 220,
                curve: 60,
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  categoryName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: const [
                    Text(
                      'هنا سيتم عرض محتوى الفئة',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 🔙 زر الرجوع (عائم فوق الهيدر)
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
                  child: Icon(
                    // دعم RTL تلقائيًا 👌
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_forward
                        : Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
