import 'package:flutter/material.dart';
import 'dart:math';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const EcoRewardsApp());
}

/// -------------------------------------------------------------
/// ECO REWARDS – SPRINT 1 LEARNING PROTOTYPE (Flutter)
/// -------------------------------------------------------------
/// This updated file adds a functional barcode scanner using the
/// `mobile_scanner` package. Scans use the phone camera and award
/// simulated points (no real product lookup or backend).
///
/// Requirements (add to pubspec.yaml):
///   mobile_scanner: ^2.0.0
///
/// Android permissions (android/app/src/main/AndroidManifest.xml):
///   <uses-permission android:name="android.permission.CAMERA" />
///
/// iOS permissions (ios/Runner/Info.plist):
///   <key>NSCameraUsageDescription</key>
///   <string>Camera is used to scan barcodes for demo receipt scanning.</string>
///
/// Screens:
///  - Home
///  - Scan Receipt (real camera-based barcode scanning)
///  - Link Accounts
///  - Progress
///  - Rewards
///
/// Notes:
///  - Barcode content is used only to determine a deterministic but
///    simulated point value (so repeated scans of same barcode give
///    reproducible points in the demo).
///  - You can keep the "Simulate Scan" fallback button for desktop
///    or tester convenience.
/// -------------------------------------------------------------

class EcoRewardsApp extends StatelessWidget {
  const EcoRewardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoRewards Prototype',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF2E7D32),
        useMaterial3: true,
      ),
      home: EcoStateProvider(
        state: EcoState(),
        child: const Shell(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// ---------------------- STATE (In‑Memory) ----------------------
class EcoState extends ChangeNotifier {
  int points = 320;
  int level = 3;
  int nextLevelThreshold = 400; // points needed per level (simple)

  // One-time bonuses when linking accounts
  bool uberLinked = false;
  bool lyftLinked = false;
  bool groceryLinked = false; // e.g., Kroger/Whole Foods

  // Earned reward vouchers (simulated codes)
  final List<RewardVoucher> earned = [];

  // Milestones for progress screen
  final List<int> milestones = [100, 250, 500, 750, 1000];

  void addPoints(int value, {String? reason, BuildContext? context}) {
    points += value;
    // Level up logic
    while (points >= nextLevelThreshold) {
      points -= nextLevelThreshold;
      level += 1;
      // Show lightweight celebration if context available
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Level Up! You reached Level $level 🎉'),
          ),
        );
      }
    }
    notifyListeners();
  }

  void toggleUber(bool v, BuildContext context) {
    if (uberLinked == v) return;
    uberLinked = v;
    if (v) {
      addPoints(25);
      _toast(context, 'Uber linked! +25 points');
    } else {
      _toast(context, 'Uber unlinked');
    }
    notifyListeners();
  }

  void toggleLyft(bool v, BuildContext context) {
    if (lyftLinked == v) return;
    lyftLinked = v;
    if (v) {
      addPoints(25);
      _toast(context, 'Lyft linked! +25 points');
    } else {
      _toast(context, 'Lyft unlinked');
    }
    notifyListeners();
  }

  void toggleGrocery(bool v, BuildContext context) {
    if (groceryLinked == v) return;
    groceryLinked = v;
    if (v) {
      addPoints(40);
      _toast(context, 'Grocery account linked! +40 points');
    } else {
      _toast(context, 'Grocery account unlinked');
    }
    notifyListeners();
  }

  bool canRedeem(int cost) => totalPoints >= cost;

  int get totalPoints => points + levelProgressOffset;

  int get levelProgressOffset => (level - 1) * nextLevelThreshold;

  void redeem(Reward reward, BuildContext context) {
    if (!canRedeem(reward.cost)) {
      _toast(context, 'Not enough points to redeem.');
      return;
    }
    int remaining = reward.cost;
    if (points >= remaining) {
      points -= remaining;
      remaining = 0;
    } else {
      remaining -= points;
      points = 0;
    }
    while (remaining > 0 && level > 1) {
      level -= 1;
      int pool = nextLevelThreshold;
      if (pool >= remaining) {
        points = pool - remaining;
        remaining = 0;
      } else {
        remaining -= pool;
      }
    }
    final code = _generateCode();
    earned.add(RewardVoucher(reward: reward, code: code));
    notifyListeners();
    _toast(context, 'Redeemed ${reward.title}! Code: $code');
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(10, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class EcoStateProvider extends InheritedNotifier<EcoState> {
  const EcoStateProvider({super.key, required EcoState state, required super.child})
      : super(notifier: state);

  static EcoState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<EcoStateProvider>();
    assert(provider != null, 'EcoStateProvider not found in widget tree');
    return provider!.notifier!;
  }
}

/// ---------------------- SHELL & NAV ----------------------
class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;

  final pages = const [
    HomeScreen(),
    ScanScreen(),
    LinkScreen(),
    ProgressScreen(),
    RewardsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = EcoStateProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoRewards Prototype'),
        centerTitle: true,
      ),
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.document_scanner_outlined), selectedIcon: Icon(Icons.document_scanner), label: 'Scan'),
          NavigationDestination(icon: Icon(Icons.link_outlined), selectedIcon: Icon(Icons.link), label: 'Link'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.card_giftcard_outlined), selectedIcon: Icon(Icons.card_giftcard), label: 'Rewards'),
        ],
      ),
      floatingActionButton: index == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                state.addPoints(5, context: context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Daily eco check-in +5 points')),
                );
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Daily Check-In'),
            )
          : null,
    );
  }
}

/// ---------------------- HOME ----------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = EcoStateProvider.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScoreHeader(points: state.points, level: state.level, threshold: state.nextLevelThreshold),
          const SizedBox(height: 16),
          _QuickActions(),
          const SizedBox(height: 24),
          _InfoCard(
            title: 'Prototype Goals',
            body:
                '• Validate if points & levels feel motivating.
• Check if scan->points flow is clear.
• Test clarity of linking & rewards.
• Gather feedback on reward values & tiers.',
          ),
        ],
      ),
    );
  }
}

class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader({required this.points, required this.level, required this.threshold});
  final int points;
  final int level;
  final int threshold;

  @override
  Widget build(BuildContext context) {
    final pct = (points / threshold).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Level $level • Eco Explorer', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: pct),
            const SizedBox(height: 8),
            Text('$points / $threshold points to next level'),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = EcoStateProvider.of(context);

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => state.addPoints(10, context: context),
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Reusable Bag +10'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => state.addPoints(20, context: context),
            icon: const Icon(Icons.directions_bus_outlined),
            label: const Text('Transit +20'),
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.body});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(body),
        ]),
      ),
    );
  }
}

/// ---------------------- SCAN (Camera Barcode Scanner) ----------------------
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool scanned = false;
  String? lastCode;
  bool isProcessing = false;

  final Map<String, int> sampleMappingFallback = {
    'Reusable Bag': 10,
    'Plant‑Based Meal': 30,
    'Sustainable Fish': 50,
    'LED Bulb': 25,
    'Public Transit Ride': 20,
  };

  // Convert a barcode string deterministically into a simulated point value
  int _pointsForBarcode(String code) {
    // simple hash -> map into useful range
    int h = 0;
    for (int i = 0; i < code.length; i++) {
      h = (h * 31 + code.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    // map to one of the demo point buckets
    final buckets = [10, 20, 25, 30, 50];
    return buckets[h % buckets.length];
  }

  void _onDetect(BarcodeCapture capture) async {
    if (isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue ?? barcodes.first.format.name;
    if (code.isEmpty) return;

    // avoid double-processing same code rapidly
    if (lastCode == code) return;

    setState(() {
      isProcessing = true;
      lastCode = code;
    });

    final pts = _pointsForBarcode(code);
    // Show confirmation dialog and add points when user accepts
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Receipt Detected'),
        content: Text('Detected barcode: $code
Award simulated +$pts pts?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final state = EcoStateProvider.of(context);
              state.addPoints(pts, context: context);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added +$pts points')));
            },
            child: const Text('Claim Points'),
          ),
        ],
      ),
    );

    // small cooldown to avoid repeated dialogs
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      isProcessing = false;
    });
  }

  // Fallback simulated scan for desktop/demo
  void _simulateScan() {
    final rand = Random();
    final keys = sampleMappingFallback.keys.toList();
    keys.shuffle();
    final picked = keys.take(1 + rand.nextInt(2)).toList();
    final pts = picked.fold(0, (sum, k) => sum + (sampleMappingFallback[k] ?? 0));
    final state = EcoStateProvider.of(context);
    state.addPoints(pts, context: context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Simulated scan: +$pts pts')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              MobileScanner(
                allowDuplicates: false,
                onDetect: _onDetect,
              ),
              Positioned(
                top: 32,
                left: 16,
                right: 16,
                child: Card(
                  color: Colors.white70,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Point your camera at a barcode on a receipt.'),
                        Text('A dialog will appear to claim simulated points.'),
                      ],
                    ),
                  ),
                ),
              ),
              if (isProcessing)
                const Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(child: CircularProgressIndicator()),
                )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _simulateScan,
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Simulate Scan (fallback)'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    lastCode = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Scanner reset')));
                },
                icon: const Icon(Icons.refresh_outlined),
                label: const Text('Reset Scanner'),
              ),
            ),
          ]),
        )
      ],
    );
  }
}

/// ---------------------- LINK ACCOUNTS ----------------------
class LinkScreen extends StatelessWidget {
  const LinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = EcoStateProvider.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Link Accounts', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text('Connect services to automatically earn points for sustainable choices.'),
        const SizedBox(height: 16),
        Card(
          child: SwitchListTile(
            title: const Text('Uber'),
            subtitle: const Text('Earn points for shared rides & Uber Green.'),
            value: state.uberLinked,
            onChanged: (v) => state.toggleUber(v, context),
            secondary: const Icon(Icons.local_taxi_outlined),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: SwitchListTile(
            title: const Text('Lyft'),
            subtitle: const Text('Earn points for shared & EV rides.'),
            value: state.lyftLinked,
            onChanged: (v) => state.toggleLyft(v, context),
            secondary: const Icon(Icons.electric_car_outlined),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: SwitchListTile(
            title: const Text('Grocery Loyalty'),
            subtitle: const Text('Auto-detect sustainable groceries (e.g., plant-based, MSC fish).'),
            value: state.groceryLinked,
            onChanged: (v) => state.toggleGrocery(v, context),
            secondary: const Icon(Icons.shopping_cart_outlined),
          ),
        ),
        const SizedBox(height: 16),
        const _HintCard(
          text:
              'Prototype behavior: First time you link each account, you get a one-time bonus (Uber +25, Lyft +25, Grocery +40). This tests whether linking feels “worth it.”',
        ),
      ],
    );
  }
}

/// ---------------------- PROGRESS ----------------------
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = EcoStateProvider.of(context);
    final threshold = state.nextLevelThreshold;
    final pct = (state.points / threshold).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Your Progress', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Level ${state.level}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: pct),
              const SizedBox(height: 6),
              Text('${state.points} / $threshold to next level'),
              const SizedBox(height: 12),
              Text('Lifetime Points (approx): ${state.totalPoints}'),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Text('Milestones', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: state.milestones.map((m) {
              final achieved = state.totalPoints >= m;
              return ListTile(
                leading: Icon(achieved ? Icons.verified : Icons.radio_button_unchecked,
                    color: achieved ? Colors.green : null),
                title: Text('$m points'),
                subtitle: Text(achieved ? 'Achieved' : 'Not yet'),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Text('Redeemed Rewards', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (state.earned.isEmpty)
          const _HintCard(text: 'You haven\'t redeemed any rewards yet.'),
        if (state.earned.isNotEmpty)
          Card(
            child: Column(
              children: state.earned.map((v) => ListTile(
                    leading: const Icon(Icons.card_giftcard),
                    title: Text(v.reward.title),
                    subtitle: Text('Code: ${v.code}'),
                  )).toList(),
            ),
          ),
      ]),
    );
  }
}

/// ---------------------- REWARDS (Simulated Redemption) ----------------------
class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = EcoStateProvider.of(context);

    final rewards = [
      Reward(title: '\$5 Starbucks eGift', cost: 200, brand: 'Starbucks'),
      Reward(title: '\$10 Amazon eGift', cost: 400, brand: 'Amazon'),
      Reward(title: '\$5 Chipotle eGift', cost: 200, brand: 'Chipotle'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Redeem Rewards', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('Your available pts: ${state.totalPoints}'),
        const SizedBox(height: 16),
        ...rewards.map((r) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(
                    children: [
                      const Icon(Icons.card_giftcard),
                      const SizedBox(width: 8),
                      Expanded(child: Text(r.title, style: Theme.of(context).textTheme.titleMedium)),
                      Chip(label: Text('${r.cost} pts')),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: Text('Brand: ${r.brand}')),
                      FilledButton(
                        onPressed: state.canRedeem(r.cost)
                            ? () => state.redeem(r, context)
                            : null,
                        child: const Text('Redeem'),
                      ),
                    ],
                  ),
                ]),
              ),
            )),
        const SizedBox(height: 12),
        const _HintCard(
          text:
              'This simulates e‑gift redemptions by generating a code. In a future sprint, this would hit a rewards service and deliver a secure claim link or barcode.',
        ),
      ],
    );
  }
}

/// ---------------------- MODELS ----------------------
class Reward {
  final String title;
  final String brand;
  final int cost;
  const Reward({required this.title, required this.brand, required this.cost});
}

class RewardVoucher {
  final Reward reward;
  final String code;
  RewardVoucher({required this.reward, required this.code});
}
