import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_theme.dart';
import '../../ai/disease_classifier.dart';
import '../disease/disease_plant_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cam;
  bool _busy = false;
  bool _flashOn = false;

  String? _imgPath;
  DiseaseResult? _result;

  late final AnimationController _scanCtrl;
  final _picker = ImagePicker();

  // =========================
  // 1) إعدادات مقاس المستطيل
  // =========================
  static const double _vfW = 320; // عرض المستطيل
  static const double _vfH = 420; // ارتفاع المستطيل
  static const double _vfR = 22; // تدوير الزوايا

  // =========================
  // 2) رفع المستطيل للأعلى
  // =========================
  static const double _vfLift = 0.45;

  // =========================
  // 3) شفافية طبقة التظليل خارج المستطيل
  // =========================
  static const double _dimOpacity = 0.45;

  // =========================
  // 4) ✅ رفع الأزرار الثلاثة للأعلى (بالبكسل)
  // =========================
  // زِد الرقم = الأزرار ترتفع أكثر
  static const double _buttonsBottomPad = 48;

  @override
  void initState() {
    super.initState();

    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cams = await availableCameras();
      final back = cams.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cams.first,
      );

      final ctrl = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await ctrl.initialize();
      if (!mounted) return;
      setState(() => _cam = ctrl);
    } catch (e) {
      debugPrint('Camera init error: $e');
      _setErrorResult('Camera init error: $e');
    }
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _cam?.dispose();
    super.dispose();
  }

  String _pct(double v) => '${(v * 100).toStringAsFixed(1)}%';

  Future<void> _toggleFlash() async {
    if (_cam == null) return;
    try {
      _flashOn = !_flashOn;
      await _cam!.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
      setState(() {});
    } catch (e) {
      debugPrint('Flash error: $e');
    }
  }

  Future<void> _capture() async {
    if (_cam == null || _busy) return;

    setState(() {
      _busy = true;
      _result = null;
      _imgPath = null;
    });

    try {
      final file = await _cam!.takePicture();
      _imgPath = file.path;

      final bytes = await File(file.path).readAsBytes();
      await _runModel(bytes);
    } catch (e) {
      debugPrint('Capture error: $e');
      _setErrorResult('Capture error: $e');
    }

    if (!mounted) return;
    setState(() => _busy = false);
  }

  Future<void> _pickFromGallery() async {
    if (_busy) return;

    final x = await _picker.pickImage(source: ImageSource.gallery);
    if (x == null) return;

    setState(() {
      _busy = true;
      _result = null;
      _imgPath = x.path;
    });

    try {
      final bytes = await File(x.path).readAsBytes();
      await _runModel(bytes);
    } catch (e) {
      debugPrint('Gallery read error: $e');
      _setErrorResult('Gallery read error: $e');
    }

    if (!mounted) return;
    setState(() => _busy = false);
  }

  Future<void> _runModel(Uint8List bytes) async {
    try {
      final res = await DiseaseClassifier.instance.classify(bytes);
      if (!mounted) return;
      setState(() => _result = res);
    } catch (e) {
      debugPrint('Model error: $e');
      if (!mounted) return;
      setState(() {
        _result = DiseaseResult(
          plant: 'unknown',
          label: 'error',
          confidence: 0,
          title: 'خطأ',
          description: 'Model error: $e',
          modelUsed: null,
        );
      });
    }
  }

  void _setErrorResult(String err) {
    if (!mounted) return;
    setState(() {
      _result = DiseaseResult(
        plant: 'unknown',
        label: 'error',
        confidence: 0,
        title: 'خطأ',
        description: err,
        modelUsed: null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final camReady = _cam?.value.isInitialized == true;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (camReady) CameraPreview(_cam!),

          // ✅ الإطار + الثقب داخل بعض (نفس المكان)
          if (camReady)
            Align(
              alignment: Alignment(0, -_vfLift),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _HoleOverlay(
                    holeW: _vfW,
                    holeH: _vfH,
                    radius: _vfR,
                    dimOpacity: _dimOpacity,
                    lift: 0.0, // ✅ صار داخل Align لذلك نخليه 0
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ViewFinder(
                        scanCtrl: _scanCtrl,
                        showScan: _busy,
                        width: _vfW,
                        height: _vfH,
                        radius: _vfR,
                      ),
                      const SizedBox(height: 12),
                      AnimatedOpacity(
                        opacity: _busy ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          'جاري الفحص...',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withOpacity(0.95),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          SafeArea(
            bottom: true,
            child: Stack(
              children: [
                // زر الرجوع
                Positioned(
                  left: 12,
                  top: 12,
                  child: _TopIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.maybePop(context),
                  ),
                ),

                // ✅ أسفل الشاشة: (بطاقة النتيجة فوق الأزرار) + الأزرار مرفوعة
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 14,
                      right: 14,
                      bottom: _buttonsBottomPad,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // بطاقة النتيجة
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: (_result == null)
                              ? const SizedBox.shrink()
                              : _ResultCard(
                                  title: _result!.title,
                                  desc:
                                      'النبات: ${_result!.plant}\n'
                                      'الثقة: ${_pct(_result!.confidence)}\n'
                                      '${_result!.description}',
                                  thumbPath: _imgPath,
                                  onTap: () {
                                    final r = _result!;
                                    showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text(r.title),
                                        content: SingleChildScrollView(
                                          child: Text(
                                            'النبات: ${r.plant}\n'
                                            'الثقة: ${_pct(r.confidence)}\n\n'
                                            '${r.description}',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('إغلاق'),
                                          ),
                                          if (r.plant != 'unknown')
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        DiseasePlantScreen(
                                                          plantCode: r.plant,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: const Text('تفاصيل'),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),

                        if (_result != null) const SizedBox(height: 10),

                        // ✅ الأزرار الثلاثة بدون مربع/شريط
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _RoundAction(
                              icon: Icons.photo_outlined,
                              onTap: _pickFromGallery,
                            ),
                            _CaptureButton(onTap: _capture, busy: _busy),
                            _RoundAction(
                              icon: _flashOn ? Icons.flash_on : Icons.flash_off,
                              onTap: _toggleFlash,
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
        ],
      ),
    );
  }
}

/// ===== Widgets =====

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.black.withOpacity(0.25),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(icon, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewFinder extends StatelessWidget {
  final AnimationController scanCtrl;
  final bool showScan;
  final double width;
  final double height;
  final double radius;

  const _ViewFinder({
    required this.scanCtrl,
    required this.showScan,
    this.width = 320,
    this.height = 420,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            // إطار فقط بدون لون داخلي
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: Colors.white.withOpacity(0.90),
                  width: 1.6,
                ),
              ),
            ),

            // خط المسح أثناء الفحص
            if (showScan)
              AnimatedBuilder(
                animation: scanCtrl,
                builder: (_, __) {
                  final t = scanCtrl.value;
                  return Align(
                    alignment: Alignment(0, (t * 2) - 1),
                    child: Container(
                      height: height * 0.20,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppTheme.primaryGreen.withOpacity(0.70),
                            AppTheme.primaryGreen.withOpacity(0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

            Positioned.fill(child: CustomPaint(painter: _CornerPainter())),
          ],
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 34.0;
    const pad = 14.0;

    canvas.drawLine(const Offset(pad, pad), const Offset(pad + len, pad), p);
    canvas.drawLine(const Offset(pad, pad), const Offset(pad, pad + len), p);

    canvas.drawLine(
      Offset(size.width - pad, pad),
      Offset(size.width - pad - len, pad),
      p,
    );
    canvas.drawLine(
      Offset(size.width - pad, pad),
      Offset(size.width - pad, pad + len),
      p,
    );

    canvas.drawLine(
      Offset(pad, size.height - pad),
      Offset(pad + len, size.height - pad),
      p,
    );
    canvas.drawLine(
      Offset(pad, size.height - pad),
      Offset(pad, size.height - pad - len),
      p,
    );

    canvas.drawLine(
      Offset(size.width - pad, size.height - pad),
      Offset(size.width - pad - len, size.height - pad),
      p,
    );
    canvas.drawLine(
      Offset(size.width - pad, size.height - pad),
      Offset(size.width - pad, size.height - pad - len),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoundAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      // زر دائري شفاف بدون مربع خارجي
      color: Colors.white.withOpacity(0.16),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 54,
          height: 54,
          child: Icon(icon, color: Colors.white.withOpacity(0.98)),
        ),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool busy;

  const _CaptureButton({required this.onTap, required this.busy});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: busy ? null : onTap,
        child: SizedBox(
          width: 70,
          height: 70,
          child: busy
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              : Icon(Icons.center_focus_strong, color: AppTheme.primaryGreen),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String title;
  final String desc;
  final String? thumbPath;
  final VoidCallback onTap;

  const _ResultCard({
    required this.title,
    required this.desc,
    required this.thumbPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.92),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: thumbPath == null
                      ? Container(color: Colors.grey.shade300)
                      : Image.file(File(thumbPath!), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.chevron_right, color: AppTheme.primaryGreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Overlay: طبقة خارج المستطيل + ثقب شفاف
class _HoleOverlay extends StatelessWidget {
  final double holeW;
  final double holeH;
  final double radius;
  final double dimOpacity;
  final double lift;

  const _HoleOverlay({
    required this.holeW,
    required this.holeH,
    this.radius = 22,
    this.dimOpacity = 0.45,
    this.lift = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (_, c) {
          final size = Size(c.maxWidth, c.maxHeight);

          // نفس منطق Alignment(0, -lift)
          final center = Offset(
            size.width / 2,
            (size.height / 2) + ((-lift) * (size.height / 2)),
          );

          final rect = Rect.fromCenter(
            center: center,
            width: holeW,
            height: holeH,
          );

          return CustomPaint(
            size: Size.infinite,
            painter: _HoleOverlayPainter(
              holeRect: rect,
              radius: radius,
              dimOpacity: dimOpacity,
            ),
          );
        },
      ),
    );
  }
}

class _HoleOverlayPainter extends CustomPainter {
  final Rect holeRect;
  final double radius;
  final double dimOpacity;

  _HoleOverlayPainter({
    required this.holeRect,
    required this.radius,
    required this.dimOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Offset.zero & size, Paint());

    final dimPaint = Paint()..color = Colors.black.withOpacity(dimOpacity);
    canvas.drawRect(Offset.zero & size, dimPaint);

    final holePaint = Paint()..blendMode = BlendMode.clear;
    final rrect = RRect.fromRectAndRadius(holeRect, Radius.circular(radius));
    canvas.drawRRect(rrect, holePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HoleOverlayPainter oldDelegate) {
    return oldDelegate.holeRect != holeRect ||
        oldDelegate.radius != radius ||
        oldDelegate.dimOpacity != dimOpacity;
  }
}
