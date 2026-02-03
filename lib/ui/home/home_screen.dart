import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(right: 2),
          child: const Text(
            "ابحث عن حلول لصحة نباتاتك",
            style: TextStyle(fontSize: 18, color: AppTheme.titleTheme),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: IconButton(
              onPressed: () {
                // TODO: Implement language change functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تغيير اللغة غير متوفر حالياً')),
                );
              },
              icon: const Icon(Icons.language),
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
              decoration: InputDecoration(
                hintText: "بحث",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
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
            const Text(
              "التصنيفات",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.titleTheme,
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: 6,
                itemBuilder: (context, index) {
                  final items = [
                    ["نباتات ورقية", "assets/images/plant_leaf.jpg"],
                    ["زهور", "assets/images/flowers.jpg"],
                    ["فواكه", "assets/images/fruite.jpg"],
                    ["خضروات", "assets/images/vegetables.jpg"],
                    ["خضروات", "assets/images/vegetables.jpg"],
                    ["خضروات", "assets/images/vegetables.jpg"],
                  ];
                  return _CategoryItem(items[index][0], items[index][1]);
                },
                separatorBuilder: (_, __) => const SizedBox(width: 4),
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
                            fontSize: 14,
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
            const Text(
              "مشاكل شائعة",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.titleTheme,
              ),
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
                _ProblemCard("اصفرار الأوراق", "assets/images/yellow.jpg"),
                _ProblemCard("احتراق أطراف الأوراق", "assets/images/brown.jpg"),
                _ProblemCard("بقع على الأوراق", "assets/images/leaf_spot.jpg"),
                _ProblemCard("ذبول الأوراق", "assets/images/wilting.jpg"),
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

  const _ProblemCard(this.title, this.image);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30), // 0–255
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
        ],
      ),
    );
  }
}
