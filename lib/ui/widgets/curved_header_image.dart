import 'package:flutter/material.dart';

class CurvedHeaderImage extends StatelessWidget {
  final String imagePath;
  final double height;
  final double curve;

  const CurvedHeaderImage({
    super.key,
    required this.imagePath,
    this.height = 250,
    this.curve = 62,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: OvalBottomClipper(curve: curve),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Image.asset(imagePath, fit: BoxFit.cover),
      ),
    );
  }
}

class OvalBottomClipper extends CustomClipper<Path> {
  final double curve;

  const OvalBottomClipper({this.curve = 62});

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    path.lineTo(0, h - curve);

    path.quadraticBezierTo(w * 0.25, h, w * 0.50, h);
    path.quadraticBezierTo(w * 0.75, h, w, h - curve);

    path.lineTo(w, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant OvalBottomClipper oldClipper) {
    return oldClipper.curve != curve;
  }
}
