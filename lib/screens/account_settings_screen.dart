import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'login_screen.dart'; // Added import for LoginScreen
import 'settings_screen.dart'; // Added import for SettingsScreen
import 'dart:convert'; // Added import for jsonDecode

class AccountSettingsScreen extends StatefulWidget {
  final VoidCallback? onUserInfoChanged;
  const AccountSettingsScreen({Key? key, this.onUserInfoChanged}) : super(key: key);

  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  String? userId;
  List<String> participatedEvents = [];
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSaving = false;
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _passwordError;
  bool _isPasswordSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAccountData();
    _loadUserInfo();
  }

  Future<void> _loadAccountData() async {
    final id = await SharedPreferencesStorageService.getOrCreateUserId();
    final events = await SharedPreferencesStorageService.getParticipatedEventIds();
    setState(() {
      userId = id;
      participatedEvents = events;
    });
  }

  Future<void> _loadUserInfo() async {
    final user = AuthService.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }
  }

  Future<void> _saveUserInfo() async {
    setState(() { _isSaving = true; });
    
    final currentUser = AuthService.currentUser;
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );
      await AuthService.updateCurrentUser(updatedUser);
      
      // Log account info update activity
      await AuthService.addActivityLog(
        'Account Update',
        'Account information updated: name and email',
      );
    }
    
    setState(() { _isSaving = false; });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account info updated!')),
      );
      widget.onUserInfoChanged?.call();
    }
  }

  Future<void> _changePassword() async {
    setState(() { _isPasswordSaving = true; _passwordError = null; });
    
    // Get fresh user data from storage to ensure we have the latest password
    final user = await AuthService.getCurrentUserFresh();
    if (user == null) {
      setState(() {
        _passwordError = 'User not found.';
        _isPasswordSaving = false;
      });
      return;
    }
    
    // Debug: Print the expected old password (for testing only)
    print('Expected old password: ${user.password}');
    print('Entered old password: ${_oldPasswordController.text}');
    
    if (_oldPasswordController.text != user.password) {
      setState(() {
        _passwordError = 'Old password is incorrect.';
        _isPasswordSaving = false;
      });
      return;
    }
    
    if (_newPasswordController.text.length < 6) {
      setState(() {
        _passwordError = 'New password must be at least 6 characters.';
        _isPasswordSaving = false;
      });
      return;
    }
    
    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordError = 'Passwords do not match.';
        _isPasswordSaving = false;
      });
      return;
    }
    
    final updatedUser = user.copyWith(password: _newPasswordController.text);
    await AuthService.updateCurrentUser(updatedUser);
    
    // Log password change activity
    await AuthService.addActivityLog(
      'Password Change',
      'Password updated successfully',
    );
    
    setState(() { _isPasswordSaving = false; });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated!')),
      );
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    }
  }

  Future<User?> _getFreshUserData() async {
    return await AuthService.getCurrentUserFresh();
  }

  Future<void> _clearData() async {
    await SharedPreferencesStorageService().clearData();
    await _loadAccountData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('All data cleared!')),
    );
  }

  IconData _getActivityIcon(String activity) {
    switch (activity) {
      case 'Account Registration':
        return Icons.person_add;
      case 'Account Verification':
        return Icons.verified;
      case 'Login':
        return Icons.login;
      case 'Event Participation':
        return Icons.event;
      case 'Logout':
        return Icons.logout;
      case 'Password Change':
        return Icons.lock;
      case 'Account Update':
        return Icons.edit;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String activity) {
    switch (activity) {
      case 'Account Registration':
        return Colors.blue;
      case 'Account Verification':
        return Colors.green;
      case 'Login':
        return Colors.orange;
      case 'Event Participation':
        return Colors.purple;
      case 'Logout':
        return Colors.red;
      case 'Password Change':
        return Colors.amber;
      case 'Account Update':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime datetime) {
    final now = DateTime.now();
    final difference = now.difference(datetime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name:', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'Enter your name',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey[800] 
                              : Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF00B388), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Email:', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey[800] 
                              : Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF00B388), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveUserInfo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B388),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isSaving 
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Change Password:', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.white 
                            : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _oldPasswordController,
                        decoration: InputDecoration(
                          hintText: 'Old password',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey[800] 
                              : Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF00B388), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        obscureText: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _newPasswordController,
                        decoration: InputDecoration(
                          hintText: 'New password',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey[800] 
                              : Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF00B388), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        obscureText: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          hintText: 'Confirm new password',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey[800] 
                              : Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF00B388), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        obscureText: true,
                      ),
                    ),
                    if (_passwordError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _passwordError!,
                                style: const TextStyle(color: Colors.red, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isPasswordSaving ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B388),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isPasswordSaving 
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Change Password',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Activity Log Section
                    Text('Activity Log:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          if (AuthService.currentUser?.activityLog.isNotEmpty == true)
                            ...AuthService.currentUser!.activityLog.reversed.map((entry) => 
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey.shade200),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          _getActivityIcon(entry.activity),
                                          size: 16,
                                          color: _getActivityColor(entry.activity),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            entry.activity,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          _formatDateTime(entry.datetime),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).brightness == Brightness.dark 
                                                ? Colors.grey[400] 
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      entry.activityDetails,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Theme.of(context).brightness == Brightness.dark 
                                            ? Colors.grey[300] 
                                            : Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'IP: ${entry.ip}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context).brightness == Brightness.dark 
                                            ? Colors.grey[500] 
                                            : Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).toList()
                          else
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'No activity logged yet',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Settings Button
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.settings),
                        label: const Text('Settings'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey[800] 
                              : Colors.grey[100],
                          foregroundColor: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey[200] 
                              : Colors.grey[800],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () async {
                  // Log logout activity
                  await AuthService.addActivityLog(
                    'Logout',
                    'User logged out from account settings',
                  );
                  
                  await AuthService.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 