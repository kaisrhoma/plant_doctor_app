import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../categoray/categoray_screen.dart';
import '../disease/disease_details_screen.dart';

final List<List<String>> items = [
  ["نباتات ورقية", "assets/images/plant_leaf.jpg"],
  ["زهور", "assets/images/flowers.jpg"],
  ["فواكه", "assets/images/fruite.jpg"],
  ["خضروات", "assets/images/vegetables.jpg"],
  ["حبوب", "assets/images/fruite.jpg"],
  ["أشجار", "assets/images/fruite.jpg"],
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Text(
            "ابحث عن حلول لصحة نباتاتك",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cs.onSurface,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تغيير اللغة غير متوفر حالياً')),
                );
              },
              icon: Icon(Icons.language, color: cs.onSurface),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 البحث
            TextField(
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
              ),
              decoration: InputDecoration(
                hintText: "بحث",
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

            const SizedBox(height: 10),

            // 📂 التصنيفات
            Text(
              "التصنيفات",
              style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryScreen(
                            categoryTitle: items[index][0],
                            categoryImage: items[index][1],
                          ),
                        ),
                      );
                    },
                    child: _CategoryItem(items[index][0], items[index][1]),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(width: 6),
              ),
            ),

            const SizedBox(height: 10),

            // 🟩 بطاقة التعريف
            Container(
              padding: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                // ✅ بدل لون ثابت
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: cs.onSurface.withOpacity(0.06),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.20 : 0.08),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          "صحة نباتاتك هي مهمتنا",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "أرسل صور النبات وسيتم تحديد ما إذا كان سليمًا أو مصابًا مع تقديم معلومات عن الأمراض.",
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: cs.onSurface.withOpacity(0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Image.asset("assets/images/plant.png", height: 150),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ⚠️ المشاكل الشائعة
            Text(
              "مشاكل شائعة",
              style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: 10),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: const [
                _ProblemCard(
                  "اصفرار الأوراق",
                  "assets/images/yellow.jpg",
                  "نبات الياسمين",
                ),
                _ProblemCard(
                  "احتراق الأطراف",
                  "assets/images/brown.jpg",
                  "نبات السجاد",
                ),
                _ProblemCard(
                  'بقع على الاوراق',
                  "assets/images/leaf_spot.jpg",
                  "نبات الورود",
                ),
                _ProblemCard(
                  'ذبول الاوراق',
                  "assets/images/wilting.jpg",
                  "نبات الزيتون",
                ),
              ],
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String title;
  final String image;

  const _CategoryItem(this.title, this.image, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SizedBox(
      width: 90,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 28, backgroundImage: AssetImage(image)),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProblemCard extends StatelessWidget {
  final String title;
  final String image;
  final String plantName;

  const _ProblemCard(this.title, this.image, this.plantName);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        // ✅ بدل AppTheme.backraoundCard الثابت
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.onSurface.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.20 : 0.10),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiseaseDetailsScreen(
                  diseseTitle: title,
                  diseaseImage: image,
                  plantName: plantName,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.asset(
                  image,
                  height: 145,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    // ✅ بدل AppTheme.titleTheme الثابت
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
