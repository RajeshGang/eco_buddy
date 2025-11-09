import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  bool _saving = false;
  bool _darkMode = false;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _name.text = FirebaseAuth.instance.currentUser?.displayName ?? '';
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _notifications = prefs.getBool('notifications') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(_name.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
        setState(() {}); // refresh UI
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            CircleAvatar(radius: 28, child: Text((u?.displayName ?? u?.email ?? 'U')[0].toUpperCase())),
            const SizedBox(height: 12),
            Text(u?.email ?? 'No email', style: Theme.of(context).textTheme.bodyLarge),
            const Divider(height: 32),
            
            // Profile Settings
            Text('Profile', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Display name')),
            const SizedBox(height: 12),
            FilledButton(onPressed: _saving ? null : _save,
              child: _saving ? const SizedBox(height:20,width:20,child:CircularProgressIndicator(strokeWidth:2))
                             : const Text('Save')),
            
            const Divider(height: 32),
            
            // App Settings
            Text('Settings', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme'),
              value: _darkMode,
              onChanged: (val) {
                setState(() => _darkMode = val);
                _saveSetting('darkMode', val);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Restart app to apply theme')),
                );
              },
            ),
            SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Receive sustainability tips'),
              value: _notifications,
              onChanged: (val) {
                setState(() => _notifications = val);
                _saveSetting('notifications', val);
              },
            ),
            
            const Divider(height: 32),
            ListTile(leading: const Icon(Icons.logout), title: const Text('Sign out'), onTap: _signOut),
          ],
        ),
      ),
    );
  }
}