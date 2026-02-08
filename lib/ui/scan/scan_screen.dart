import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_theme.dart';
import '../../core/runtime_settings.dart';
import '../../ai/disease_classifier.dart';
import '../disease/disease_details_screen.dart';
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

  // ✅ مربع بدل مستطيل
  static const double _vfSize = 320;
  static const double _vfR = 22;

  // ✅ رفع المربع للأعلى أكثر
  static const double _vfLift = 0.52;

  // ✅ رفع الأزرار اللي تحت للأعلى أكثر
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
      _setErrorResult('Model error: $e');
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

    return ValueListenableBuilder<Locale>(
      valueListenable: RuntimeSettings.locale,
      builder: (_, loc, __) {
        final lang = loc.languageCode;
        final isAr = lang == 'ar';

        final guideText = isAr
            ? 'اجعل النبات في بؤرة التركيز'
            : 'Keep the plant in focus';

        return Directionality(
          textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                if (camReady) CameraPreview(_cam!),

                // ✅ بدون أي تظليل / overlay — فقط المربع والنص
                if (camReady)
                  Align(
                    alignment: Alignment(0, -_vfLift),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _SquareViewFinder(size: _vfSize, radius: _vfR),
                        const SizedBox(height: 12),
                        Text(
                          guideText,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withOpacity(0.90),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedOpacity(
                          opacity: _busy ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            isAr ? 'جاري الفحص...' : 'Scanning...',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.95),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                SafeArea(
                  bottom: true,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                      ).copyWith(bottom: _buttonsBottomPad),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: (_result == null)
                                ? const SizedBox.shrink()
                                : _ResultCard(
                                    title: _result!.title,
                                    desc: isAr
                                        ? 'النبات: ${_result!.plant}\n'
                                              'الثقة: ${_pct(_result!.confidence)}\n'
                                              '${_result!.description}'
                                        : 'Plant: ${_result!.plant}\n'
                                              'Confidence: ${_pct(_result!.confidence)}\n'
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
                                              isAr
                                                  ? 'النبات: ${r.plant}\n'
                                                        'الثقة: ${_pct(r.confidence)}\n\n'
                                                        '${r.description}'
                                                  : 'Plant: ${r.plant}\n'
                                                        'Confidence: ${_pct(r.confidence)}\n\n'
                                                        '${r.description}',
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text(
                                                isAr ? 'إغلاق' : 'Close',
                                              ),
                                            ),
                                            if (r.plant != 'unknown')
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);

                                                  if (r.label != 'error' &&
                                                      r.label.isNotEmpty) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            DiseaseDetailsScreen(
                                                              diseaseCode:
                                                                  r.label,
                                                              plantCode:
                                                                  r.plant,
                                                              showPlantLink:
                                                                  true,
                                                            ),
                                                      ),
                                                    );
                                                  } else {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            DiseasePlantScreen(
                                                              plantCode:
                                                                  r.plant,
                                                            ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Text(
                                                  isAr ? 'تفاصيل' : 'Details',
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          if (_result != null) const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _RoundAction(
                                icon: Icons.photo_outlined,
                                onTap: _pickFromGallery,
                              ),
                              _CaptureButton(onTap: _capture, busy: _busy),
                              _RoundAction(
                                icon: _flashOn
                                    ? Icons.flash_on
                                    : Icons.flash_off,
                                onTap: _toggleFlash,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ===== Widgets =====

class _RoundAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark
        ? const Color(0xFF1E1E1E)
        : Colors.white.withOpacity(0.92);
    final titleColor = isDark ? Colors.white : Colors.black87;
    final descColor = isDark ? Colors.white70 : Colors.black54;

    return Material(
      color: bg,
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
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: descColor),
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

/// ✅ ViewFinder مربع (إطار + زوايا) بدون تظليل وبدون خط مسح
class _SquareViewFinder extends StatelessWidget {
  final double size;
  final double radius;

  const _SquareViewFinder({required this.size, required this.radius});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: Colors.white.withOpacity(0.90),
                width: 1.6,
              ),
            ),
          ),
          Positioned.fill(child: CustomPaint(painter: _CornerPainter())),
        ],
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
