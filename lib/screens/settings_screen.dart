import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoSaveEnabled = true;
  String _language = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _autoSaveEnabled = prefs.getBool('autoSaveEnabled') ?? true;
      _language = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('autoSaveEnabled', _autoSaveEnabled);
    await prefs.setString('language', _language);
  }

  void _toggleDarkMode(bool value) {
    final themeProvider = ThemeProvider.of(context);
    themeProvider.toggleTheme();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Dark mode ${value ? 'enabled' : 'disabled'}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    _saveSettings();
    if (value) {
      _requestNotificationPermission();
      _showTestNotification();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notifications ${value ? 'enabled' : 'disabled'}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _requestNotificationPermission() async {
    // Placeholder: In a real app, use flutter_local_notifications or firebase_messaging
    // For now, just show a dialog
    if (Platform.isAndroid || Platform.isIOS) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Notification Permission'),
          content: const Text('Notification permissions would be requested here.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _showTestNotification() {
    // Placeholder: In a real app, use flutter_local_notifications or firebase_messaging
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification: This is how a push notification would appear.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleAutoSave(bool value) {
    setState(() {
      _autoSaveEnabled = value;
    });
    _saveSettings();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Auto-save ${value ? 'enabled' : 'disabled'}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _changeLanguage(String? value) {
    if (value != null) {
      setState(() {
        _language = value;
      });
      _saveSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Language changed to $value'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF00B388),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            _buildSectionHeader('Appearance'),
            _buildSettingTile(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: 'Switch between light and dark themes',
              trailing: Switch(
                value: ThemeProvider.of(context).isDarkMode,
                onChanged: _toggleDarkMode,
                activeColor: const Color(0xFF00B388),
              ),
            ),
            const SizedBox(height: 16),

            // Notifications Section
            _buildSectionHeader('Notifications'),
            _buildSettingTile(
              icon: Icons.notifications,
              title: 'Push Notifications',
              subtitle: 'Receive notifications for events and updates',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                activeColor: const Color(0xFF00B388),
              ),
            ),
            const SizedBox(height: 16),

            // Data & Storage Section
            _buildSectionHeader('Data & Storage'),
            _buildSettingTile(
              icon: Icons.save,
              title: 'Auto-save',
              subtitle: 'Automatically save your changes',
              trailing: Switch(
                value: _autoSaveEnabled,
                onChanged: _toggleAutoSave,
                activeColor: const Color(0xFF00B388),
              ),
            ),
            const SizedBox(height: 16),

            // Language Section
            _buildSectionHeader('Language'),
            _buildSettingTile(
              icon: Icons.language,
              title: 'Language',
              subtitle: 'Choose your preferred language',
              trailing: DropdownButton<String>(
                value: _language,
                items: const [
                  DropdownMenuItem(value: 'English', child: Text('English')),
                  DropdownMenuItem(value: 'Spanish', child: Text('Spanish')),
                  DropdownMenuItem(value: 'French', child: Text('French')),
                  DropdownMenuItem(value: 'German', child: Text('German')),
                ],
                onChanged: _changeLanguage,
              ),
            ),
            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader('About'),
            _buildSettingTile(
              icon: Icons.info,
              title: 'App Version',
              subtitle: '1.0.0',
              trailing: null,
            ),
            _buildSettingTile(
              icon: Icons.description,
              title: 'Terms of Service',
              subtitle: 'Read our terms and conditions',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Terms of Service - Coming Soon')),
                );
              },
            ),
            _buildSettingTile(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              subtitle: 'Learn about our privacy practices',
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy Policy - Coming Soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF00B388),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF00B388)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
} 