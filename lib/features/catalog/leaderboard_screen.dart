import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../catalog/leaderboard_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _service = LeaderboardService();
  int? _userRank;
  int _userPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final rank = await _service.getUserRank(uid);
    final points = await _service.getUserPoints(uid);

    if (mounted) {
      setState(() {
        _userRank = rank;
        _userPoints = points;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserStats,
          ),
        ],
      ),
      body: Column(
        children: [
          // User stats card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('Your Rank',
                          style: theme.textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        _userRank == null ? '--' : '#$_userRank',
                        style: theme.textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Total Points',
                          style: theme.textTheme.bodySmall),
                      const SizedBox(height: 4),
                      Text(
                        '$_userPoints',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Leaderboard list
          Expanded(
            child: StreamBuilder<List<LeaderboardEntry>>(
              stream: _service.getTopUsers(limit: 100),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final entries = snapshot.data!;

                if (entries.isEmpty) {
                  return const Center(
                    child: Text('No entries yet. Be the first!'),
                  );
                }

                return ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final rank = index + 1;
                    final isCurrentUser = entry.uid == uid;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getRankColor(rank),
                        child: rank <= 3
                            ? _getRankIcon(rank)
                            : Text(
                                '$rank',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      title: Text(
                        entry.displayName,
                        style: TextStyle(
                          fontWeight: isCurrentUser
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${entry.totalPoints} pts',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      tileColor: isCurrentUser
                          ? theme.colorScheme.primaryContainer
                              .withOpacity(0.3)
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[300]!;
      default:
        return Colors.blue;
    }
  }

  Widget _getRankIcon(int rank) {
    IconData icon;
    switch (rank) {
      case 1:
        icon = Icons.emoji_events;
        break;
      case 2:
        icon = Icons.military_tech;
        break;
      case 3:
        icon = Icons.workspace_premium;
        break;
      default:
        icon = Icons.star;
    }
    return Icon(icon, color: Colors.white);
  }
}