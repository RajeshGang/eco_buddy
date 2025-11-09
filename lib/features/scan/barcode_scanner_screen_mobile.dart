import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../catalog/upc_lookup_service.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});
  @override State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}
class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  String? lastCode;
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Barcode')),
      body: MobileScanner(
        onDetect: (capture) async {
          final code = capture.barcodes.first.rawValue;
          if (code == null || code == lastCode) return;
          setState(()=> lastCode = code);
          final item = await UpcLookupService.instance.lookup(code);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Found ${item?.name ?? code}')));
        },
      ),
    );
  }
}
