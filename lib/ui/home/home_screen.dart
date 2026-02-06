import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/runtime_settings.dart';
import '../categoray/categoray_screen.dart';
import '../disease/disease_details_screen.dart';
import '../../data/database/database_helper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<Locale>(
      valueListenable: RuntimeSettings.locale,
      builder: (_, loc, __) {
        final lang = loc.languageCode;

        // ✅ كارد التعريف يتغير في الدارك
        final introCardBg = isDark
            ? const Color(0xFF1E2A1F) // أخضر غامق مناسب
            : const Color.fromARGB(255, 233, 248, 215);

        final introTitleColor =
            isDark ? Colors.white : const Color.fromARGB(255, 15, 75, 17);
        final introBodyColor =
            isDark ? Colors.white70 : const Color.fromARGB(255, 15, 75, 17);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            centerTitle: false,
            surfaceTintColor: Colors.transparent,
            title: Text(
              lang == 'ar'
                  ? "ابحث عن حلول لصحة نباتاتك"
                  : "Find solutions for your plants",
              style: theme.textTheme.bodyLarge,
            ),
            actions: [
              IconButton(
                tooltip: lang == 'ar' ? 'تغيير اللغة' : 'Change language',
                onPressed: () async {
                  final next = (lang == 'ar') ? 'en' : 'ar';
                  await RuntimeSettings.setLanguage(next);
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
                // 🔍 البحث (دارك مود مضبوط)
                TextField(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : null,
                  ),
                  decoration: InputDecoration(
                    hintText: lang == 'ar' ? "بحث" : "Search",
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white54 : Colors.grey,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                    filled: true,
                    fillColor: theme.cardColor, // ✅ مهم
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                        color: isDark
                            ? Colors.white.withOpacity(0.12)
                            : Colors.grey.withOpacity(0.25),
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
                  lang == 'ar' ? "التصنيفات" : "Categories",
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 10),

                SizedBox(
                  height: 110,
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: DatabaseHelper.instance.getCategories(lang),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text(lang == 'ar' ? "لا توجد بيانات" : "No Data"),
                        );
                      }

                      final categories = snapshot.data!;
                      return ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final item = categories[index];
                          final img = "assets/category_icons/${item['icon']}";

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CategoryScreen(
                                    categoryTitle: item['name'],
                                    categoryCode: item['code'],
                                    categoryImage: img,
                                  ),
                                ),
                              );
                            },
                            child: _CategoryItem(item['name'], img),
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // 🟩 بطاقة التعريف (✅ دارك مود مضبوط)
                Container(
                  padding: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    color: introCardBg,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.25 : 0.08),
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
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang == 'ar'
                                    ? "صحة نباتاتك هي مهمتنا"
                                    : "Your plants’ health is our mission",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: introTitleColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                lang == 'ar'
                                    ? "أرسل صور النبات وسيتم تحديد ما إذا كان سليمًا أو مصابًا مع تقديم معلومات عن الأمراض."
                                    : "Send a plant photo to detect whether it’s healthy or infected, with disease info.",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: introBodyColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Image.asset("assets/images/plant.png", height: 150),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  lang == 'ar' ? "مشاكل شائعة" : "Common problems",
                  style: theme.textTheme.bodyLarge,
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
                    _ProblemCard("اصفرار الأوراق", "assets/images/yellow.jpg", "نبات الياسمين"),
                    _ProblemCard("احتراق الأطراف", "assets/images/brown.jpg", "نبات السجاد"),
                    _ProblemCard('بقع على الاوراق', "assets/images/leaf_spot.jpg", "نبات الورود"),
                    _ProblemCard('ذبول الاوراق', "assets/images/wilting.jpg", "نبات الزيتون"),
                  ],
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
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
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// ✅ هذا أهم تعديل: لون كارد المشاكل الشائعة يتبع الثيم
class _ProblemCard extends StatelessWidget {
  final String title;
  final String image;
  final String plantName;

  const _ProblemCard(this.title, this.image, this.plantName);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor, // ✅ بدل AppTheme.backraoundCard
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.12),
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:AppTheme.titleTheme,
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
