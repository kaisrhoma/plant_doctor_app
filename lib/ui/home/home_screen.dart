import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../categoray/categoray_screen.dart';
import '../disease/disease_details_screen.dart';
import '../../data/database/database_helper.dart';

final List<List<String>> items = [
  ["نباتات ورقية", "assets/images/plant_leaf.jpg"],
  ["زهور", "assets/images/flowers.jpg"],
  ["فواكه", "assets/images/fruite.jpg"],
  ["خضروات", "assets/images/vegetables.jpg"],
  ["حبوب", "assets/images/fruite.jpg"],
  ["أشجار", "assets/images/fruite.jpg"],
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentLang = 'ar';
  late Future<List<Map<String, dynamic>>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = DatabaseHelper.instance.getCategories(currentLang);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        title: Text(
          currentLang == 'ar'
              ? "ابحث عن حلول لصحة نباتاتك"
              : "Find solutions for your plants",
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                currentLang = (currentLang == 'ar') ? 'en' : 'ar';
                _categoriesFuture = DatabaseHelper.instance.getCategories(
                  currentLang,
                );
              });
            },

            icon: Icon(Icons.language, color: AppTheme.titleTheme),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 البحث
            TextField(
              decoration: InputDecoration(
                hintText: currentLang == 'ar' ? "بحث" : "Search",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
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

            const SizedBox(height: 10),

            // 📂 التصنيفات
            Text(
              currentLang == 'ar' ? "التصنيفات" : "Categories",
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),

            // SizedBox(
            //   height: 90,
            //   child: ListView.separated(
            //     scrollDirection: Axis.horizontal,
            //     physics: const BouncingScrollPhysics(),
            //     itemCount: items.length,
            //     itemBuilder: (context, index) {
            //       return InkWell(
            //         onTap: () {
            //           Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //               builder: (_) => CategoryScreen(
            //                 categoryTitle: items[index][0],
            //                 categoryImage: items[index][1],
            //               ),
            //             ),
            //           );
            //         },
            //         child: _CategoryItem(items[index][0], items[index][1]),
            //       );
            //     },
            //     separatorBuilder: (_, __) => const SizedBox(width: 6),
            //   ),
            // ),
            SizedBox(
              height: 110,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("No Data"));
                  }

                  final categories = snapshot.data!;

                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final item = categories[index];

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryScreen(
                                categoryTitle: item['name'],
                                categoryCode: item['code'],
                                categoryImage:
                                    "assets/category_icons/${item['icon']}",
                              ),
                            ),
                          );
                        },
                        child: _CategoryItem(
                          item['name'],
                          "assets/category_icons/${item['icon']}",
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // 🟩 بطاقة التعريف
            Container(
              padding: const EdgeInsets.only(right: 15),
              decoration: BoxDecoration(
                // This is for shadow effect niga hahahaha :)
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black.withAlpha(0), // 0–255
                //     blurRadius: 12,
                //     spreadRadius: 1,
                //     offset: const Offset(0, 0),
                //   ),
                // ],
                color: const Color.fromARGB(255, 233, 248, 215),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //const SizedBox(height: 16),
                        const SizedBox(height: 10),
                        const Text(
                          "صحة نباتاتك هي مهمتنا",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 15, 75, 17),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "أرسل صور النبات وسيتم تحديد ما إذا كان سليمًا أو مصابًا مع تقديم معلومات عن الأمراض.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 15, 75, 17),
                          ),
                        ),
                      ],
                    ),
                    // child: Text(
                    //   "صحة نباتاتك هي مهمتنا\n\n"
                    //   "أرسل صور النبات وسيتم تحديد ما إذا كان سليمًا أو مصابًا مع تقديم معلومات عن الأمراض.",
                    //   style: const TextStyle(fontSize: 14),
                    // ),
                  ),
                  const SizedBox(width: 10),
                  Image.asset("assets/images/plant.png", height: 150),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ⚠️ المشاكل الشائعة
            Text("مشاكل شائعة", style: Theme.of(context).textTheme.bodyLarge),
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
                // ... البقية
              ],
            ),
            SizedBox(height: 50),
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
    return SizedBox(
      width: 90, // ⭐ مهم جدًا
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
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ProblemCard extends StatelessWidget {
  final String title;
  final String image;
  final String plantName; // اسم النبات الذي سيمرر للشاشة التالية فقط

  const _ProblemCard(this.title, this.image, this.plantName);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backraoundCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Material(
        // أضفنا Material هنا ليعمل تأثير InkWell بشكل صحيح
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          // داخل ويدجت _ProblemCard في خاصية onTap:
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiseaseDetailsScreen(
                  diseseTitle: title, // يمرر لـ diseseTitle
                  diseaseImage: image, // يمرر لـ diseaseImage
                  plantName: plantName, // يمرر لـ plantName
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.titleTheme,
                  ),
                ),
              ),
              // اسم النبات موجود في الكود لكن لا يوجد ويدجت Text تعرضه هنا
            ],
          ),
        ),
      ),
    );
  }
}
