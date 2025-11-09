import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReceiptOcrScreen extends StatefulWidget { const ReceiptOcrScreen({super.key}); @override State<ReceiptOcrScreen> createState() => _ReceiptOcrScreenState(); }
class _ReceiptOcrScreenState extends State<ReceiptOcrScreen> {
  final _picker = ImagePicker();
  String _raw = '';
  Future<void> _pickAndScan() async {
    final file = await _picker.pickImage(source: ImageSource.camera);
    if (file == null) return;
    final input = InputImage.fromFilePath(file.path);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final result = await recognizer.processImage(input);
    await recognizer.close();
    setState(()=> _raw = result.text);
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Receipt')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          ElevatedButton.icon(onPressed: _pickAndScan, icon: const Icon(Icons.camera_alt_outlined), label: const Text('Capture Receipt')),
          const SizedBox(height: 12),
          Expanded(child: SingleChildScrollView(child: Text(_raw.isEmpty ? 'No text yet' : _raw)))
        ]),
      ),
    );
  }
}
