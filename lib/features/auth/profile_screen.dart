import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Profile screen that displays user information and app settings.
/// 
/// This screen allows users to:
/// - View and update their display name
/// - Manage app preferences (dark mode, notifications)
/// - Sign out of their account
/// 
/// User profile data is stored in Firebase Auth, while app preferences
/// are persisted locally using SharedPreferences.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Controller for the display name text field
  final _nameController = TextEditingController();
  
  /// Indicates whether a profile save operation is in progress
  bool _saving = false;
  
  /// Dark mode preference state
  bool _darkMode = false;
  
  /// Notifications preference state
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Initializes the profile screen by loading user data and preferences.
  /// 
  /// Sets the display name from Firebase Auth current user, or empty string
  /// if no display name is set. Also loads saved app preferences.
  void _initializeProfile() {
    final currentUser = FirebaseAuth.instance.currentUser;
    _nameController.text = currentUser?.displayName ?? '';
    _loadSettings();
  }

  /// Loads app settings from local storage (SharedPreferences).
  /// 
  /// Retrieves saved preferences for dark mode and notifications.
  /// Defaults to false for dark mode and true for notifications if not set.
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _darkMode = prefs.getBool('darkMode') ?? false;
        _notifications = prefs.getBool('notifications') ?? true;
      });
    }
  }

  /// Saves a boolean setting to local storage.
  /// 
  /// [key] - The preference key to save
  /// [value] - The boolean value to persist
  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// Saves the user's display name to Firebase Auth.
  /// 
  /// Updates the current user's display name with the trimmed text from
  /// the name field. Shows a success message on completion or error message
  /// if the operation fails.
  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user signed in')),
          );
        }
        return;
      }

      final trimmedName = _nameController.text.trim();
      await currentUser.updateDisplayName(trimmedName);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: ${e.message ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  /// Signs out the current user from Firebase Auth.
  /// 
  /// This will trigger the AuthGate to show the SignInPage since
  /// the auth state will change to null.
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Note: No need to navigate - AuthGate will handle the UI change
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    }
  }

  /// Gets the initial for the user's avatar.
  /// 
  /// Returns the first character of the display name, email, or 'U' as fallback.
  String _getAvatarInitial(User? user) {
    if (user == null) return 'U';
    final name = user.displayName ?? user.email ?? 'U';
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // User Avatar and Email Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      _getAvatarInitial(currentUser),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentUser?.email ?? 'No email',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            
            const Divider(height: 32),
            
            // Profile Settings Section
            Text(
              'Profile',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Display name',
                hintText: 'Enter your display name',
                border: OutlineInputBorder(),
              ),
              enabled: !_saving,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _saving ? null : _saveProfile,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
            
            const Divider(height: 32),
            
            // App Settings Section
            Text(
              'Settings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Use dark theme'),
              value: _darkMode,
              onChanged: (val) {
                setState(() => _darkMode = val);
                _saveSetting('darkMode', val);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Restart app to apply theme'),
                    duration: Duration(seconds: 2),
                  ),
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
            
            // Sign Out Section
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: _signOut,
              iconColor: theme.colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}