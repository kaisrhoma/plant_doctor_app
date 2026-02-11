import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plant_doctor_app/ui/disease/disease_details_screen.dart';
import 'package:flutter/services.dart';
import '../../core/app_theme.dart';
import '../../core/runtime_settings.dart';
import '../../ai/disease_classifier.dart';
import '../../ai/image_crop_utils.dart';
import '../../data/database/database_helper.dart';

class ScanScreen extends StatefulWidget {
  // ✅ أضف هذا السطر لاستلام الدالة من الـ BottomNav
  final VoidCallback? onBackToHome;

  const ScanScreen({super.key, this.onBackToHome});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cam;
  bool _busy = false;
  bool _flashOn = false;

  String? _imgPath;
  String? _croppedImgPath;
  DiseaseResult? _result;

  // 1. تعريف متغيرات لتخزين ألوان الثيم
  late Color _navBarColor;
  late Brightness _navIconBrightness;

  late final AnimationController _scanLineCtrl;
  final _picker = ImagePicker();

  static const double _vfSize = 280;
  static const double _vfR = 22;

  @override
  void initState() {
    super.initState();

    //  تحويل شريط النظام السفلي (System Nav Bar) إلى الأسود عند الدخول
    // ضبط اللون الأسود عند الدخول
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _scanLineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _initCamera();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 2. نقوم بتحديث القيم هنا لأن context لا يزال صالحاً
    // وسيتم تحديثها تلقائياً إذا تغير الثيم (مثلاً من وضع ليلي لنهاري)
    _navBarColor = Theme.of(context).scaffoldBackgroundColor;
    _navIconBrightness = Theme.of(context).brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;
  }

  @override
  void dispose() {
    // 3. نستخدم المتغيرات المحفوظة مسبقاً بدلاً من Theme.of(context)
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: _navBarColor,
        systemNavigationBarIconBrightness: _navIconBrightness,
      ),
    );

    _scanLineCtrl.dispose();
    _cam?.dispose();
    super.dispose();
  }

  // الدالة التي كانت تسبب الخطأ
  String _pct(double v) => '${(v * 100).toStringAsFixed(1)}%';

  Future<void> _initCamera() async {
    final cams = await availableCameras();
    if (cams.isEmpty) return;

    _cam = CameraController(
      cams.first,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cam!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  Future<void> _runModel(Uint8List bytes) async {
    try {
      final decoded = await decodeImageFromList(bytes);
      final imgW = decoded.width.toDouble();
      final imgH = decoded.height.toDouble();

      // 1. حساب حجم الشاشة الفعلي
      final screenSize = MediaQuery.of(context).size;

      // 2. حساب نسبة التناسب مع مراعاة أن الكاميرا (Preview) تغطي الشاشة بالكامل (Cover)
      // نستخدم التناسب الأكبر لضمان مطابقة القص لما يظهر في الـ fill preview
      double scale = 1.0;
      if (imgH / imgW > screenSize.height / screenSize.width) {
        scale = imgW / screenSize.width;
      } else {
        scale = imgH / screenSize.height;
      }

      // 3. تحويل حجم المربع من الشاشة إلى بكسلات الصورة الأصلية
      final double cropSizeInPixels = _vfSize * scale;

      // 4. القص من المركز الفعلي للصورة
      final imageRect = Rect.fromCenter(
        center: Offset(imgW / 2, imgH / 2),
        width: cropSizeInPixels,
        height: cropSizeInPixels,
      );

      final croppedBytes = ImageCropUtils.cropToRect(
        bytes: bytes,
        imageSize: Size(imgW, imgH),
        cropRect: imageRect,
      );

      // ... باقي الكود لحفظ الملف وعرض النتيجة

      final tempDir = await Directory.systemTemp.createTemp();
      final file = File(
        '${tempDir.path}/crop_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(croppedBytes);

      final res = await DiseaseClassifier.instance.classify(croppedBytes);

      // --- التعديل هنا ---
      // --- التعديل هنا لإصلاح مشكلة اختلاط الأكواد بالأسماء المترجمة ---
      if (res.confidence >= 0.6) {
        final dbData = await DatabaseHelper.instance.getDiseaseFullDetails(
          diseaseCode: res.diseaseCode, // نستخدم الكود الأصلي للبحث
          plantCode: res.plantCode, // نستخدم الكود الأصلي للبحث
          langCode: RuntimeSettings.locale.value.languageCode,
        );

        if (dbData != null) {
          // نحدث حقول العرض فقط (UI)
          // لا تلمس res.diseaseCode أو res.plantCode نهائياً هنا
          res.title = dbData['disease_name'] ?? res.title;
          res.plant = dbData['plant_name'] ?? res.plant;
        }
      }
      // -------------------------------------------------------
      // ------------------

      if (mounted) {
        setState(() {
          _result = res;
          _croppedImgPath = file.path;
        });
      }
    } catch (e) {
      debugPrint("Crop/Model Error: $e");
    }
  }

  Future<void> _capture() async {
    if (_cam == null || _busy) return;
    setState(() {
      _busy = true;
      _result = null;
    });

    try {
      final file = await _cam!.takePicture();
      final bytes = await File(file.path).readAsBytes();
      _imgPath = file.path;
      await _runModel(bytes);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = RuntimeSettings.locale.value.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black, // اللون الأسود
        systemNavigationBarIconBrightness: Brightness.light, // أيقونات بيضاء
        statusBarColor: Colors.transparent, // جعل شريط الحالة علوي شفاف
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 1. معاينة الكاميرا
            if (_cam != null && _cam!.value.isInitialized)
              Positioned.fill(child: CameraPreview(_cam!)),

            // 2. زر الخروج العلوي
            _buildBackButton(context, isDark, widget.onBackToHome),

            // 3. منطقة المسح في المنتصف
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // مربع التصوير (Stack)
                  Stack(
                    alignment: Alignment.center, // يضمن توسيط كل شيء بالداخل
                    children: [
                      // 1. المربع المرسوم
                      _SquareViewFinder(size: _vfSize, radius: _vfR),

                      // 2. النص في المنتصف (يختفي عند البدء بالمسح لجعل الرؤية واضحة)
                      if (!_busy)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            isAr
                                ? "ضع النبات في بؤرة التركيز"
                                : "Place the plant in the center of attention",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5), // لون خافت
                              fontSize: 13, // حجم صغير
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                      // 3. خط المسح الأخضر (يظهر فقط عند المعالجة)
                      if (_busy)
                        AnimatedBuilder(
                          animation: _scanLineCtrl,
                          builder: (context, child) {
                            return Positioned(
                              top: 10 + (_scanLineCtrl.value * (_vfSize - 20)),
                              left: 10,
                              right: 10,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.greenAccent.withOpacity(
                                        0.6,
                                      ),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // 4. البار السفلي الأسود
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.only(
                  top: 20,
                  bottom: 40,
                  left: 30,
                  right: 30,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_result != null) _buildResultCard(isAr),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // زر الاستوديو
                        _RoundAction(
                          icon: Icons.image_outlined,
                          onTap: () async {
                            final x = await _picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (x != null) {
                              setState(() => _busy = true);
                              final b = await File(x.path).readAsBytes();
                              _imgPath = x.path;
                              await _runModel(b);
                              setState(() => _busy = false);
                            }
                          },
                        ),
                        // زر الالتقاط الكبير
                        GestureDetector(
                          onTap: _capture,
                          child: Container(
                            width: 80,
                            height: 80,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: _busy
                                  ? const CircularProgressIndicator(
                                      color: Colors.green,
                                    )
                                  : Icon(
                                      Icons.camera_alt,
                                      color: AppTheme.primaryGreen,
                                      size: 35,
                                    ),
                            ),
                          ),
                        ),
                        // زر الفلاش
                        _RoundAction(
                          icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                          onTap: () {
                            setState(() => _flashOn = !_flashOn);
                            _cam?.setFlashMode(
                              _flashOn ? FlashMode.torch : FlashMode.off,
                            );
                          },
                        ),
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

  Widget _buildResultCard(bool isAr) {
    bool isPlant = _result!.confidence >= 0.6 ? true : false;
    return InkWell(
      onTap: () {
        if (_result == null) return;
        if (!isPlant) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DiseaseDetailsScreen(
              // استخدمنا الـ Getters التي أضفناها بالأعلى
              diseaseCode: _result!.diseaseCode,
              plantCode: _result!.plantCode,
              showPlantLink: true,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // صورة المعاينة
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(_croppedImgPath ?? _imgPath!),
                width: 55,
                height: 55,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم المرض
                  Text(
                    isPlant
                        ? _result!.title
                        : isAr
                        ? "غير معروف"
                        : "Unknown",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  // اسم النبات
                  isPlant
                      ? Text(
                          "${isAr ? 'النبات' : 'Plant'}: ${_result!.plant}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.primaryGreen,
                          ),
                        )
                      : Text(
                          isAr
                              ? "⚠️ الصورة غير واضحة، حاول تقريب الورقة داخل الإطار"
                              : "⚠️ Low confidence. Please center the leaf clearly",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),

                  // نسبة التأكد
                  isPlant
                      ? Text(
                          "${isAr ? 'الثقة' : 'Conf'}: ${_pct(_result!.confidence)}",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppTheme.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }
}

class _SquareViewFinder extends StatelessWidget {
  final double size;
  final double radius;
  const _SquareViewFinder({required this.size, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: CustomPaint(painter: _CornerPainter()),
    );
  }
}

// زر الرجوع
Widget _buildBackButton(
  BuildContext context,
  bool isDark,
  VoidCallback? onBackToHome,
) {
  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: CircleAvatar(
        backgroundColor: Colors.black.withOpacity(0.40),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // ✅ التعديل هنا
            if (onBackToHome != null) {
              onBackToHome();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
    ),
  );
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const len = 30.0;
    // زوايا المربع
    canvas.drawPath(
      Path()
        ..moveTo(0, len)
        ..lineTo(0, 0)
        ..lineTo(len, 0),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, len),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - len)
        ..lineTo(0, size.height)
        ..lineTo(len, size.height),
      paint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width - len, size.height)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, size.height - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
