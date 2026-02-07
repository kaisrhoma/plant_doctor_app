import 'package:flutter/material.dart';
import 'disease_details_screen.dart';
import '../../data/database/database_helper.dart';
import '../../core/runtime_settings.dart';

class DiseasePlantScreen extends StatefulWidget {
  final String plantCode;

  const DiseasePlantScreen({super.key, required this.plantCode});

  @override
  State<DiseasePlantScreen> createState() => _DiseasePlantScreenState();
}

class _DiseasePlantScreenState extends State<DiseasePlantScreen> {
  List<Map<String, dynamic>> _allDiseases = [];
  List<Map<String, dynamic>> _displayDiseases = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  // 1. تعريف الـ FocusNode
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadDiseases();
  }

  @override
  void dispose() {
    // 2. التخلص من الـ Nodes والمتحكمات
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadDiseases() async {
    setState(() => _isLoading = true);
    final diseases = await DatabaseHelper.instance.getDiseaseNamesWithImages(
      plantCode: widget.plantCode,
      langCode: RuntimeSettings.locale.value.languageCode,
    );
    setState(() {
      _allDiseases = diseases;
      _displayDiseases = diseases;
      _isLoading = false;
    });
  }

  void _runFilter(String enteredKeyword) {
    setState(() {
      if (enteredKeyword.isEmpty) {
        _displayDiseases = _allDiseases;
      } else {
        _displayDiseases = _allDiseases
            .where(
              (disease) => disease["disease_name"]
                  .toString()
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder(
      valueListenable: RuntimeSettings.locale,
      builder: (_, loc, __) {
        final lang = loc.languageCode;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              lang == 'ar' ? "أمراض النبات" : "Plant Diseases",
              style: theme.textTheme.bodyLarge,
            ),
            centerTitle: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
          ),
          body: GestureDetector(
            // إغلاق الكيبورد عند الضغط في أي مكان فارغ
            onTap: () => FocusScope.of(context).unfocus(),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 20),

                // 🔍 مربع البحث مع الفوكس
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode, // ربط النود هنا
                    onChanged: _runFilter,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: lang == 'ar'
                          ? "ابحث عن مرض"
                          : "Search for a disease",
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

                _buildDiseaseContent(theme, cs, lang),

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDiseaseContent(ThemeData theme, ColorScheme cs, String lang) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_displayDiseases.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            lang == 'ar' ? "لا توجد نتائج بحث" : "No results found",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _displayDiseases.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final disease = _displayDiseases[index];

        return DiseaseCard(
          title: disease['disease_name'],
          subtitle: lang == 'ar' ? "اضغط لعرض التفاصيل" : "Tap to view details",
          imagePath: disease['image_path'] ?? 'assets/images/placeholder.png',
          onTap: () {
            // 3. إغلاق الفوكس قبل الانتقال للشاشة التالية
            _searchFocusNode.unfocus();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DiseaseDetailsScreen(
                  diseaseCode: disease['disease_code'],
                  plantCode: widget.plantCode,
                  showPlantLink:
                      false, // هنا نمنع ظهور الزر لأننا جئنا من شاشة النبات أصلاً
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class DiseaseCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final VoidCallback onTap;

  const DiseaseCard({
    super.key,
    required this.title,
    required this.subtitle,
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
        // ✅ بدل Colors.white
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
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: cs.onSurface.withOpacity(0.65),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildStatusIcon(
                          cs,
                          Icons.wb_sunny_outlined,
                          Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        _buildStatusIcon(cs, Icons.eco_outlined, Colors.green),
                        const SizedBox(width: 8),
                        _buildStatusIcon(
                          cs,
                          Icons.water_drop_outlined,
                          Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(Icons.chevron_right, color: cs.primary),
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
        // ✅ خلفية خفيفة تتبع السطح
        color: cs.surface.withOpacity(0.20),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}
