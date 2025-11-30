import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'receipt_parser.dart';
import 'receipt_results_screen.dart';
import 'receipt_history_screen.dart';

class ReceiptOcrScreen extends StatefulWidget {
  const ReceiptOcrScreen({super.key});
  
  @override
  State<ReceiptOcrScreen> createState() => _ReceiptOcrScreenState();
}

class _ReceiptOcrScreenState extends State<ReceiptOcrScreen> {
  final _picker = ImagePicker();
  String? _imagePath;
  bool _processing = false;

  Future<void> _pickAndScan(ImageSource source) async {
    setState(() => _processing = true);

    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      
      if (file == null) {
        setState(() => _processing = false);
        return;
      }

      setState(() => _imagePath = file.path);

      // Perform OCR
      final input = InputImage.fromFilePath(file.path);
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final result = await recognizer.processImage(input);
      await recognizer.close();

      final rawText = result.text;

      if (!mounted) return;

      if (rawText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No text found in image. Try taking a clearer photo.'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _processing = false);
        return;
      }

      // Parse receipt items
      final items = ReceiptParser.parseReceipt(rawText);

      if (!mounted) return;

      // Navigate to results screen
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptResultsScreen(
            items: items,
            rawText: rawText,
          ),
        ),
      );

      // Reset state after returning
      setState(() {
        _processing = false;
        _imagePath = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing receipt: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Receipt'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReceiptHistoryScreen(),
                ),
              );
            },
            tooltip: 'Receipt History',
          ),
        ],
      ),
      body: _processing
          ? _buildProcessingView()
          : _buildMainView(),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_imagePath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_imagePath!),
                width: 200,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
          ],
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text(
            'Processing receipt...',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Extracting items and calculating scores',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 120,
              color: Colors.green[300],
            ),
            const SizedBox(height: 32),
            Text(
              'Scan Your Receipt',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Take a photo of your receipt to analyze your purchases and get sustainability scores',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 48),
            
            // Camera Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _pickAndScan(ImageSource.camera),
                icon: const Icon(Icons.camera_alt, size: 28),
                label: const Text(
                  'Take Photo',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Gallery Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => _pickAndScan(ImageSource.gallery),
                icon: const Icon(Icons.photo_library, size: 28),
                label: const Text(
                  'Choose from Gallery',
                  style: TextStyle(fontSize: 18),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: const BorderSide(color: Colors.green, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Tips Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tips_and_updates, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Tips for best results',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Ensure good lighting\n'
                      '• Keep receipt flat and straight\n'
                      '• Capture the entire receipt\n'
                      '• Avoid shadows and glare',
                      style: TextStyle(color: Colors.blue[900]),
                    ),
                  ],
                ),
              ),
            ),
            // Add bottom padding to prevent cutoff by navigation bar
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
