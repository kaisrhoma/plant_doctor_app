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
      _setErrorResult('Model error: $e'); // ✅ هنا يظهر سبب الخطأ الحقيقي
    }
  }

  /// ✅ يعرض الخطأ الحقيقي داخل الكرت
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
          if (camReady)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(color: Colors.black.withOpacity(0.25)),
            ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _TopIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.maybePop(context),
                    ),
                  ),
                ),
                const Spacer(),
                _ViewFinder(scanCtrl: _scanCtrl, showScan: _busy),
                const SizedBox(height: 14),

                AnimatedOpacity(
                  opacity: _busy ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    'جاري الفحص...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(
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
                ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: (_result == null)
                      ? const SizedBox(height: 18)
                      : _ResultCard(
                          title: _result!.title,
                          desc:
                              'النبات: ${_result!.plant}\n'
                              'الثقة: ${_pct(_result!.confidence)}\n'
                              '${_result!.description}', // ✅ هنا سيظهر نص الخطأ
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
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('إغلاق'),
                                  ),
                                  if (r.plant != 'unknown')
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DiseasePlantScreen(
                                              plantName: r.plant,
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

                const SizedBox(height: 14),
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
    return Material(
      color: Colors.white.withOpacity(0.25),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _ViewFinder extends StatelessWidget {
  final AnimationController scanCtrl;
  final bool showScan;

  const _ViewFinder({required this.scanCtrl, required this.showScan});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.white.withOpacity(0.55), width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Container(color: Colors.white.withOpacity(0.06)),
              if (showScan)
                AnimatedBuilder(
                  animation: scanCtrl,
                  builder: (_, __) {
                    final t = scanCtrl.value;
                    return Align(
                      alignment: Alignment(0, (t * 2) - 1),
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppTheme.primaryGreen.withOpacity(0.45),
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
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.75)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 26.0;

    canvas.drawLine(const Offset(14, 14), const Offset(14 + len, 14), p);
    canvas.drawLine(const Offset(14, 14), const Offset(14, 14 + len), p);

    canvas.drawLine(
      Offset(size.width - 14, 14),
      Offset(size.width - 14 - len, 14),
      p,
    );
    canvas.drawLine(
      Offset(size.width - 14, 14),
      Offset(size.width - 14, 14 + len),
      p,
    );

    canvas.drawLine(
      Offset(14, size.height - 14),
      Offset(14 + len, size.height - 14),
      p,
    );
    canvas.drawLine(
      Offset(14, size.height - 14),
      Offset(14, size.height - 14 - len),
      p,
    );

    canvas.drawLine(
      Offset(size.width - 14, size.height - 14),
      Offset(size.width - 14 - len, size.height - 14),
      p,
    );
    canvas.drawLine(
      Offset(size.width - 14, size.height - 14),
      Offset(size.width - 14, size.height - 14 - len),
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
      color: Colors.white.withOpacity(0.22),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon, color: Colors.white),
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
          width: 64,
          height: 64,
          child: busy
              ? const Padding(
                  padding: EdgeInsets.all(18),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
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
                  child: Icon(
                    Icons.chevron_right,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
