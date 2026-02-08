import 'package:flutter/material.dart';
import 'package:plant_doctor_app/ui/widgets/curved_header_image.dart';
import '../plant/plant_details_screen.dart';
import '../../data/database/database_helper.dart';
import '../../core/runtime_settings.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryTitle;
  final String categoryImage;
  final String categoryCode;

  const CategoryScreen({
    super.key,
    required this.categoryTitle,
    required this.categoryImage,
    required this.categoryCode,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Map<String, dynamic>> _allPlants = [];
  List<Map<String, dynamic>> _displayPlants = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _lastLang = RuntimeSettings.locale.value.languageCode;

  @override
  void initState() {
    super.initState();
    _loadData(_lastLang);
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData(String lang) async {
    setState(() => _isLoading = true);
    final plants = await DatabaseHelper.instance.getPlantsByCategoryCode(
      categoryCode: widget.categoryCode,
      langCode: lang,
    );
    setState(() {
      _allPlants = plants;
      _displayPlants = plants;
      _isLoading = false;
    });

    // ✅ لو في بحث مكتوب، طبّقه مرة ثانية بعد التحميل
    final q = _searchController.text.trim();
    if (q.isNotEmpty) _runFilter(q);
  }

  void _runFilter(String enteredKeyword) {
    final q = enteredKeyword.trim();
    List<Map<String, dynamic>> results;

    if (q.isEmpty) {
      results = _allPlants;
    } else {
      results = _allPlants
          .where(
            (plant) => plant["plant_name"]
                .toString()
                .toLowerCase()
                .contains(q.toLowerCase()),
          )
          .toList();
    }

    setState(() => _displayPlants = results);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ValueListenableBuilder(
        valueListenable: RuntimeSettings.locale,
        builder: (_, loc, __) {
          final lang = loc.languageCode;

          // ✅ إعادة تحميل النباتات عند تغيير اللغة فقط
          if (lang != _lastLang) {
            _lastLang = lang;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _loadData(lang);
            });
          }

          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            body: Stack(
              children: [
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    CurvedHeaderImage(
                      imagePath: widget.categoryImage,
                      height: 220,
                    ),
                    const SizedBox(height: 20),

                    // ✅ عنوان الفئة (أبيض قوي + أكبر في الدارك)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        widget.categoryTitle,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isDark ? 20 : 18,
                          color: isDark ? Colors.white : cs.onSurface,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 🔍 البحث
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onChanged: _runFilter,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white : cs.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: lang == 'ar'
                              ? "ابحث عن نباتك"
                              : "Find your plants",
                          hintStyle: TextStyle(
                            color: isDark ? Colors.white54 : Colors.grey,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: isDark ? Colors.white54 : Colors.grey,
                          ),
                          filled: true,
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
                    ),

                    const SizedBox(height: 20),

                    _buildPlantsList(theme, isDark, cs, lang),

                    const SizedBox(height: 100),
                  ],
                ),

                _buildBackButton(isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlantsList(
    ThemeData theme,
    bool isDark,
    ColorScheme cs,
    String lang,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_displayPlants.isEmpty) {
      return Center(
        child: Text(
          lang == 'ar' ? "لا توجد نتائج" : "No results found",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white70 : Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _displayPlants.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final plant = _displayPlants[index];
        return PlantCard(
          name: plant['plant_name'],
          species: plant['plant_description'] ?? '',
          imagePath: plant['image_path'] ?? 'assets/images/spl.png',
          onTap: () {
            _searchFocusNode.unfocus();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PlantDetailsScreen(plant_code: plant['plant_code']),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBackButton(bool isDark) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.40),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.20 : 0.10),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
        border: Border.all(color: cs.onSurface.withOpacity(0.06), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ اسم النبات: أبيض + أكبر في الدارك
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isDark ? 15 : 14,
                        color: isDark ? Colors.white : cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // ✅ الوصف: أبيض أهدى في الدارك
                    Text(
                      species,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: isDark ? 12 : 12,
                        color: isDark ? Colors.white70 : cs.onSurface.withOpacity(0.7),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildStatusIcon(cs, Icons.wb_sunny_outlined, Colors.orange),
                        const SizedBox(width: 8),
                        _buildStatusIcon(cs, Icons.eco_outlined, Colors.green),
                        const SizedBox(width: 8),
                        _buildStatusIcon(cs, Icons.water_drop_outlined, Colors.blue),
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

  Widget _buildStatusIcon(ColorScheme cs, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.55), width: 1.5),
        color: cs.surface.withOpacity(0.20),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}
