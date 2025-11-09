import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// ---- Auth (you added these files earlier) ----
import 'features/auth/auth_gate.dart';
import 'features/auth/profile_screen.dart';

// ---- Trends (works on web & mobile) ----
import 'features/stats/trends_screen.dart';

// ---- Conditional imports: real mobile screens vs web stubs ----
import 'features/scan/barcode_scanner_screen_stub.dart'
  if (dart.library.io) 'features/scan/barcode_scanner_screen_mobile.dart';
import 'features/scan/receipt_ocr_screen_stub.dart'
  if (dart.library.io) 'features/scan/receipt_ocr_screen_mobile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // We only init Firebase on mobile. Web config can be added later.
  if (!kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const EcoSustainApp());
}

class EcoSustainApp extends StatelessWidget {
  const EcoSustainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoSustain',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      // If web is not configured, show a friendly page instead of crashing.
      home: kIsWeb ? const _WebNotConfigured() : const AuthGate(child: EcoNavScaffold()),
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
      const _HomeLanding(),
      _mobileCameraSupported ? const BarcodeScannerScreen()
                             : const _UnsupportedPlaceholder(feature: 'Barcode Scanner'),
      _mobileCameraSupported ? const ReceiptOcrScreen()
                             : const _UnsupportedPlaceholder(feature: 'Receipt OCR'),
      // Replace 'demo' with your auth UID once you plumb it through (or read from FirebaseAuth)
      const TrendsScreen(uid: 'demo'),
      const ProfileScreen(),
    ];

    final destinations = const [
      NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
      NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
      NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Receipts'),
      NavigationDestination(icon: Icon(Icons.trending_up), label: 'Progress'),
      NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: destinations,
      ),
    );
  }
}

class _HomeLanding extends StatelessWidget {
  const _HomeLanding({super.key});
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

class _WebNotConfigured extends StatelessWidget {
  const _WebNotConfigured({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EcoSustain (Web)')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Web Firebase isn’t configured yet.\n\n'
            '✅ Android/iOS are ready. Run on a phone or simulator.\n\n'
            'If you want Web later, add a Web app in Firebase,\n'
            'then run: flutterfire configure --platforms=web,android,ios',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
