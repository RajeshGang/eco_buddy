import 'package:flutter/material.dart';

class ReceiptOcrScreen extends StatelessWidget {
  const ReceiptOcrScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('Receipt OCR isn’t supported on Web.\nRun on Android/iOS.'),
      ),
    );
  }
}
