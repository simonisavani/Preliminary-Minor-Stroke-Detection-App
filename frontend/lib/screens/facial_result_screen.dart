// facial_result_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';

class FacialResultScreen extends StatelessWidget {
  final File imageFile;
  final String resultText;
  final String asymmetryScore;

  const FacialResultScreen({
    Key? key,
    required this.imageFile,
    required this.resultText,
    required this.asymmetryScore,
  }) : super(key: key);

  Widget _buildResultCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(value, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Facial Test Result'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(imageFile, height: 250, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            _buildResultCard('Test Result:', resultText),
            _buildResultCard('Asymmetry Score:', asymmetryScore),
          ],
        ),
      ),
    );
  }
}
