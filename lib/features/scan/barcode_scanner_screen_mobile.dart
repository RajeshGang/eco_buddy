import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../catalog/upc_lookup_service.dart';
import '../catalog/scoring_service.dart';
import 'scan_result_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});
  @override State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final _scoringService = ScoringService();
  String? lastCode;
  bool _processing = false;

  Future<void> _handleBarcode(String code) async {
    if (_processing) return;
    setState(() => _processing = true);

    try {
      // Lookup product in catalog
      final item = await UpcLookupService.instance.lookup(code);
      
      if (!mounted) return;

      if (item == null) {
        // Product not found in catalog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product not found for barcode: $code'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
        setState(() => _processing = false);
        return;
      }

      // Calculate sustainability score
      final score = await _scoringService.scoreItem(
        category: item.category,
        baseScore: item.baseScore,
      );

      if (!mounted) return;

      // Navigate to results screen with score and AI recommendations
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScanResultScreen(
            productName: item.name,
            category: item.category,
            score: score,
            brand: item.brand,
            upc: item.upc,
          ),
        ),
      );

      // Reset after returning from results screen
      setState(() {
        _processing = false;
        lastCode = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing barcode: $e'),
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
        title: const Text('Scan Barcode'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) async {
              final code = capture.barcodes.first.rawValue;
              if (code == null || code == lastCode || _processing) return;
              setState(() => lastCode = code);
              await _handleBarcode(code);
            },
          ),
          if (_processing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Processing barcode...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Scanning guide overlay
          if (!_processing)
            Center(
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          // Instructions at bottom
          if (!_processing)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Align barcode within frame',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
