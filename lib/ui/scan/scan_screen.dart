import 'package:flutter/material.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan Plant Leaf"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.camera_alt,
              size: 80,
              color: Colors.green,
            ),
            SizedBox(height: 16),
            Text(
              "Point the camera at the plant leaf",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
