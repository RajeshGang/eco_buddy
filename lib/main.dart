import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// NEW: feature screens
import 'features/scan/barcode_scanner_screen.dart';
import 'features/scan/receipt_ocr_screen.dart';
import 'features/stats/trends_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EcoSustainApp());
}

class EcoSustainApp extends StatelessWidget {
  const EcoSustainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoSustain',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const EcoNavScaffold(),
    );
  }
}

class EcoNavScaffold extends StatefulWidget {
  const EcoNavScaffold({super.key});
  @override
  State<EcoNavScaffold> createState() => _EcoNavScaffoldState();
}

class _EcoNavScaffoldState extends State<EcoNavScaffold> {
  int _index = 0;

  bool get _mobileCameraSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
           defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      // Home
      _HomeLanding(onGoScan: () => setState(() => _index = 1), onGoReceipt: () => setState(() => _index = 2)),
      // Scan (barcode)
      _mobileCameraSupported
          ? const BarcodeScannerScreen()
          : const _UnsupportedPlaceholder(feature: 'Barcode Scanner'),
      // Receipt OCR
      _mobileCameraSupported
          ? const ReceiptOcrScreen()
          : const _UnsupportedPlaceholder(feature: 'Receipt OCR'),
      // Progress (uses Firestore stream; replace "demo" with your signed-in uid when Auth is wired)
      const TrendsScreen(uid: 'demo'),
      // Profile (placeholder)
      const _ProfilePlaceholder(),
    ];

    final items = const [
      BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
      BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Receipts'),
      BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'Progress'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: items.map((e) => NavigationDestination(icon: e.icon!, label: e.label!)).toList(),
      ),
    );
  }
}

class _HomeLanding extends StatelessWidget {
  final VoidCallback onGoScan;
  final VoidCallback onGoReceipt;
  const _HomeLanding({super.key, required this.onGoScan, required this.onGoReceipt});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        _HeroCard(
          title: 'Scan a Barcode',
          subtitle: 'Look up an item and calculate its sustainability score.',
          icon: Icons.qr_code_scanner,
        ),
        _HeroCard(
          title: 'Scan a Receipt',
          subtitle: 'Extract line items with OCR and save a trip score.',
          icon: Icons.receipt_long_outlined,
        ),
        _HeroCard(
          title: 'Track Progress',
          subtitle: 'See monthly trends and improvements over time.',
          icon: Icons.trending_up,
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  const _HeroCard({super.key, required this.title, required this.subtitle, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class _UnsupportedPlaceholder extends StatelessWidget {
  final String feature;
  const _UnsupportedPlaceholder({super.key, required this.feature});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          '$feature is not supported on Web.\nRun on Android/iOS to use the camera.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _ProfilePlaceholder extends StatelessWidget {
  const _ProfilePlaceholder({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile (coming soon)'));
  }
}
