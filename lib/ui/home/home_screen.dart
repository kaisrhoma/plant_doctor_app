import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/runtime_settings.dart';
import '../categoray/categoray_screen.dart';
import '../disease/disease_details_screen.dart';
import '../../data/database/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchText = '';
  late Future<List<Map<String, dynamic>>> _diseasesFuture;
  late Future<List<Map<String, dynamic>>> _categoriesFuture;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    // التحميل المبدئي عند فتح الصفحة
    _initLoad();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose(); // ✅ ضروري جداً لتجنب تسريب الذاكرة
    super.dispose();
  }

  void _initLoad() {
    final lang = RuntimeSettings.locale.value.languageCode;

    // تحميل التصنيفات مرة واحدة
    _categoriesFuture = DatabaseHelper.instance.getCategories(lang);

    // تحميل الأمراض (عشوائي في البداية)
    _diseasesFuture = DatabaseHelper.instance.getRandomDiseases(
      langCode: lang,
      limit: 6,
    );
  }

  // ✅ دالة إعادة التحميل
  Future<void> _handleRefresh() async {
    final lang = RuntimeSettings.locale.value.languageCode;

    // محاكاة تأخير بسيط لشعور المستخدم بالاستجابة (اختياري)
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      // إعادة تحميل البيانات من الصفر
      _initLoad();
      // إذا كان هناك نص في البحث، يفضل مسحه عند السحب للإعادة للحالة الافتراضية
      // _searchText = '';
    });
  }

  void _updateData(String query, String lang) {
    setState(() {
      _searchText = query;
      // تحديث الأمراض بناءً على البحث
      if (query.isEmpty) {
        _diseasesFuture = DatabaseHelper.instance.getRandomDiseases(
          langCode: lang,
          limit: 6,
        );
      } else {
        _diseasesFuture = DatabaseHelper.instance.searchDiseases(
          query: query,
          langCode: lang,
        );
      }

      // ✅ تحديث التصنيفات أيضاً عند تغيير اللغة فقط
      _categoriesFuture = DatabaseHelper.instance.getCategories(lang);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bool isSearching = _searchText.trim().isNotEmpty;

    return ValueListenableBuilder<Locale>(
      valueListenable: RuntimeSettings.locale,
      builder: (_, loc, __) {
        final lang = loc.languageCode;

        // الألوان الخاصة بالـ RefreshIndicator
        final refreshBg = isDark ? cs.surface : Colors.white;
        final refreshColor = cs.primary;

        //  كارد التعريف يتغير في الدارك
        final introCardBg = isDark
            ? const Color(0xFF1E2A1F) // أخضر غامق مناسب
            : const Color.fromARGB(255, 233, 248, 215);

        final introTitleColor = isDark
            ? Colors.white
            : const Color.fromARGB(255, 15, 75, 17);
        final introBodyColor = isDark
            ? Colors.white70
            : const Color.fromARGB(255, 15, 75, 17);

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: theme.scaffoldBackgroundColor,
              centerTitle: false,
              surfaceTintColor: Colors.transparent,
              title: Text(
                lang == 'ar'
                    ? "ابحث عن حلول لصحة نباتاتك"
                    : "Find solutions for your plants",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark ? Colors.white : AppTheme.titleTheme,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: lang == 'ar' ? 'تغيير اللغة' : 'Change language',
                  onPressed: () async {
                    final next = (lang == 'ar') ? 'en' : 'ar';
                    await RuntimeSettings.setLanguage(next);
                    _updateData(_searchText, next);
                  },
                  icon: Icon(Icons.language, color: AppTheme.titleTheme),
                ),
              ],
            ),
            body: RefreshIndicator(
              color: refreshColor,
              backgroundColor: refreshBg,
              strokeWidth: 3.0,
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔍 البحث (دارك مود مضبوط)
                    TextField(
                      focusNode: _searchFocusNode,
                      onChanged: (value) {
                        final v = value.trim();

                        if (v == _searchText) return; //  يمنع rebuild غير ضروري

                        // لا نبحث إلا إذا كان النص فارغاً (للعودة) أو أكثر من حرفين
                        if (v.isEmpty || v.length >= 1) {
                          _updateData(v, lang);
                        }
                        setState(() {
                          _searchText = v;
                        });
                      },

                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : null,
                      ),
                      decoration: InputDecoration(
                        hintText: lang == 'ar' ? "بحث" : "ٍSearch",
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
                            color:
                                (isDark
                                        ? Colors.white.withOpacity(0.12)
                                        : Colors.grey.withOpacity(0.2))
                                    .withOpacity(0.40),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: cs.primary.withOpacity(0.55),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (!isSearching) ...[
                      // 📂 التصنيفات
                      Text(
                        lang == 'ar' ? "التصنيفات" : "Categories",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 18, // ✅ أكبر في الدارك
                          color: isDark
                              ? Colors.white
                              : null, // ✅ أبيض في الدارك
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        height: 110,
                        child: FutureBuilder<List<Map<String, dynamic>>>(
                          future: _categoriesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Center(
                                child: Text(
                                  lang == 'ar' ? "لا توجد بيانات" : "No Data",
                                ),
                              );
                            }

                            final categories = snapshot.data!;
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: categories.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final item = categories[index];
                                final img =
                                    "assets/category_icons/${item['icon']}";

                                return InkWell(
                                  onTap: () {
                                    // إلغاء التركيز قبل الانتقال لشاشة أخرى
                                    _searchFocusNode.unfocus();
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
                    ],

                    if (!isSearching) ...[
                      const SizedBox(height: 10),

                      // 🟩 بطاقة التعريف (✅ دارك مود مضبوط)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: introCardBg,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isDark ? 0.25 : 0.08,
                              ),
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
                                        fontSize: 11,
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
                    ],

                    const SizedBox(height: 15),

                    Text(
                      isSearching
                          ? (lang == 'ar' ? "نتائج البحث" : "Search results")
                          : (lang == 'ar' ? "مشاكل شائعة" : "Common problems"),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: isDark ? 20 : 18, // ✅ أكبر في الدارك
                        color: isDark ? Colors.white : null, // ✅ أبيض في الدارك
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // تم تعديل FutureBuilder ليستخدم _loadDiseases اللي بتتعامل مع البحث والعرض العشوائي
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _diseasesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              lang == 'ar'
                                  ? "لا توجد نتائج"
                                  : "No results found",
                            ),
                          );
                        }

                        final diseases = snapshot.data!;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.9,
                              ),
                          itemCount: diseases.length,
                          itemBuilder: (context, index) {
                            final d = diseases[index];
                            return _ProblemCard(
                              title: d['disease_name'],
                              image:
                                  d['image_path'] ??
                                  'assets/images/placeholder.png',
                              diseaseCode: d['disease_code'],
                              plantCode: d['plant_code'],
                              searchFocusNode: _searchFocusNode,
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
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
  final String diseaseCode;
  final String plantCode;
  final FocusNode searchFocusNode;

  const _ProblemCard({
    required this.title,
    required this.image,
    required this.diseaseCode,
    required this.plantCode,
    required this.searchFocusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor, //  بدل AppTheme.backraoundCard
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
            // إلغاء التركيز قبل الانتقال لشاشة أخرى
            searchFocusNode.unfocus();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DiseaseDetailsScreen(
                  diseaseCode: diseaseCode,
                  plantCode: plantCode,
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      //fontWeight: FontWeight.bold,
                      fontSize: 14, // ✅ أكبر في الدارك
                      color: isDark ? Colors.white : null, // ✅ أبيض في الدارك
                    ),
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
