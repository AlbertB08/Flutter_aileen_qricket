import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'login_screen.dart'; // Added import for LoginScreen
import 'settings_screen.dart'; // Added import for SettingsScreen
import 'dart:convert'; // Added import for jsonDecode
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'activity_log_screen.dart';
import 'purchase_history_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  final VoidCallback? onUserInfoChanged;
  final VoidCallback? onProfileUpdated;
  const AccountSettingsScreen({Key? key, this.onUserInfoChanged, this.onProfileUpdated}) : super(key: key);

  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  String? userId;
  List<String> participatedEvents = [];
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSaving = false;
  bool _isEditMode = false; // Add edit mode state
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _passwordError;
  bool _isPasswordSaving = false;
  bool _oldPasswordChanged = false;
  bool _newPasswordChanged = false;
  bool _confirmPasswordChanged = false;
  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

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
      _fnameController.text = user.fname;
      _lnameController.text = user.lname;
      _emailController.text = user.email;
    }
  }

  void _cancelEdit() {
    // Reset form fields to original values
    final user = AuthService.currentUser;
    if (user != null) {
      _fnameController.text = user.fname;
      _lnameController.text = user.lname;
      _emailController.text = user.email;
    }
    // Reset profile image
    _profileImage = null;
    setState(() {
      _isEditMode = false;
    });
  }

  ImageProvider? _getProfileImageProvider() {
    // If there's a newly picked image, use that
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    }
    
    // If there's a profile image path from the user
    final user = AuthService.currentUser;
    if (user?.profileImagePath != null && user!.profileImagePath!.isNotEmpty) {
      final path = user.profileImagePath!;
      
      // Check if it's a network URL
      if (path.startsWith('http')) {
        return NetworkImage(path);
      }
      
      // Check if it's a local file
      if (path.startsWith('/') || path.contains('\\')) {
        return FileImage(File(path));
      }
      
      // Assume it's an asset
      return AssetImage(path);
    }
    
    return null;
  }

  Future<void> _pickProfileImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  Future<void> _saveUserInfo() async {
    setState(() { _isSaving = true; });
    
    final currentUser = AuthService.currentUser;
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        fname: _fnameController.text.trim(),
        lname: _lnameController.text.trim(),
        email: _emailController.text.trim(),
        profileImagePath: _profileImage?.path ?? currentUser.profileImagePath,
      );
      await AuthService.updateCurrentUser(updatedUser);
      
      // Log account info update activity
      await AuthService.addActivityLog(
        'Account Update',
        'Account information updated: name and email',
      );
    }
    
    setState(() { 
      _isSaving = false;
      _isEditMode = false; // Exit edit mode after saving
    });
    
    if (mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Call callback if provided
      widget.onUserInfoChanged?.call();
    }
  }

  Future<void> _showSaveConfirmation() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Changes Saved'),
            ],
          ),
          content: const Text('Your profile information has been updated successfully.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLogoutConfirmation() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Confirm Logout'),
            ],
          ),
          content: const Text('Are you sure you want to logout? You will need to login again to access your account.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
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
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changePassword() async {
    // Clear previous errors
    setState(() { 
      _passwordError = null; 
    });
    
    // Validate that all fields have text
    if (_oldPasswordController.text.trim().isEmpty) {
      setState(() {
        _passwordError = 'Please enter your old password.';
      });
      return;
    }
    
    if (_newPasswordController.text.trim().isEmpty) {
      setState(() {
        _passwordError = 'Please enter your new password.';
      });
      return;
    }
    
    if (_confirmPasswordController.text.trim().isEmpty) {
      setState(() {
        _passwordError = 'Please confirm your new password.';
      });
      return;
    }
    
    setState(() { _isPasswordSaving = true; });
    
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
    
    // Check if new password is same as old password
    if (_newPasswordController.text == user.password) {
      setState(() {
        _passwordError = 'New password must be different from your current password.';
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
      await _showPasswordChangeConfirmation();
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      // Reset change flags
      _oldPasswordChanged = false;
      _newPasswordChanged = false;
      _confirmPasswordChanged = false;
      // Reset visibility
      _showOldPassword = false;
      _showNewPassword = false;
      _showConfirmPassword = false;
    }
  }

  Future<void> _showPasswordChangeConfirmation() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.lock, color: Colors.green),
              SizedBox(width: 8),
              Text('Password Updated'),
            ],
          ),
          content: const Text('Your password has been changed successfully.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<User?> _getFreshUserData() async {
    return await AuthService.getCurrentUserFresh();
  }

  bool _isPasswordFormValid() {
    return _oldPasswordController.text.trim().isNotEmpty &&
           _newPasswordController.text.trim().isNotEmpty &&
           _confirmPasswordController.text.trim().isNotEmpty &&
           _newPasswordController.text.length >= 6 &&
           _newPasswordController.text == _confirmPasswordController.text;
  }

  Color _getFieldBorderColor(bool hasChanged) {
    if (hasChanged) {
      return const Color(0xFF00B388); // Green when changed
    }
    return Colors.grey.withOpacity(0.3); // Default grey
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
                    // Profile picture section
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _getProfileImageProvider(),
                            child: _getProfileImageProvider() == null
                                ? const Icon(Icons.person, size: 48, color: Colors.white)
                                : null,
                          ),
                          if (_isEditMode)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _pickProfileImage,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Edit button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Personal Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.grey[800],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_isEditMode) {
                              _cancelEdit();
                            } else {
                              setState(() {
                                _isEditMode = true;
                              });
                            }
                          },
                          icon: Icon(_isEditMode ? Icons.close : Icons.edit),
                          label: Text(_isEditMode ? 'Cancel' : 'Edit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isEditMode ? Colors.red : const Color(0xFF00B388),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Name fields on one line
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'First Name:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
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
                                  controller: _fnameController,
                                  enabled: _isEditMode,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your first name',
                                    hintStyle: TextStyle(color: Colors.grey[400]),
                                    filled: true,
                                    fillColor: _isEditMode 
                                        ? (Theme.of(context).brightness == Brightness.dark
                                            ? Colors.grey[800]
                                            : Colors.grey[50])
                                        : (Theme.of(context).brightness == Brightness.dark
                                            ? Colors.grey[900]
                                            : Colors.grey[100]),
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
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Last Name:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
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
                                  controller: _lnameController,
                                  enabled: _isEditMode,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your last name',
                                    hintStyle: TextStyle(color: Colors.grey[400]),
                                    filled: true,
                                    fillColor: _isEditMode 
                                        ? (Theme.of(context).brightness == Brightness.dark
                                            ? Colors.grey[800]
                                            : Colors.grey[50])
                                        : (Theme.of(context).brightness == Brightness.dark
                                            ? Colors.grey[900]
                                            : Colors.grey[100]),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Email field
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
                        enabled: _isEditMode,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: _isEditMode 
                              ? (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.grey[50])
                              : (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[900]
                                  : Colors.grey[100]),
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
                    
                    // Save button (only show in edit mode)
                    if (_isEditMode)
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
                            borderSide: BorderSide(color: _getFieldBorderColor(_oldPasswordChanged)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _getFieldBorderColor(_oldPasswordChanged)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF00B388), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          suffixIcon: IconButton(
                            icon: Icon(_showOldPassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _showOldPassword = !_showOldPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: !_showOldPassword,
                        onChanged: (value) {
                          setState(() {
                            _oldPasswordChanged = true;
                            _passwordError = null; // Clear error when user types
                          });
                        },
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
                            borderSide: BorderSide(color: _getFieldBorderColor(_newPasswordChanged)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _getFieldBorderColor(_newPasswordChanged)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF00B388), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          suffixIcon: IconButton(
                            icon: Icon(_showNewPassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _showNewPassword = !_showNewPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: !_showNewPassword,
                        onChanged: (value) {
                          setState(() {
                            _newPasswordChanged = true;
                            _passwordError = null; // Clear error when user types
                          });
                        },
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
                            borderSide: BorderSide(color: _getFieldBorderColor(_confirmPasswordChanged)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _getFieldBorderColor(_confirmPasswordChanged)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF00B388), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          suffixIcon: IconButton(
                            icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                _showConfirmPassword = !_showConfirmPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: !_showConfirmPassword,
                        onChanged: (value) {
                          setState(() {
                            _confirmPasswordChanged = true;
                            _passwordError = null; // Clear error when user types
                          });
                        },
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
                        onPressed: (_isPasswordSaving || !_isPasswordFormValid()) ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPasswordFormValid() ? const Color(0xFF00B388) : Colors.grey,
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
                    
                    // Menu Items Section
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark 
                            ? Colors.grey[800] 
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.grey[700]! 
                              : Colors.grey[200]!,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Activity Log Menu Item
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.history,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                            title: const Text(
                              'Activity Log',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                            ),
                                          ),
                            subtitle: Text(
                              'View your account activity history',
                                          style: TextStyle(
                                            fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                                          ),
                            onTap: () async {
                              // Do not log activity log view - removed to prevent recording viewing activity
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const ActivityLogScreen(),
                                ),
                              );
                            },
                          ),
                          Divider(
                            height: 1,
                                        color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.grey[700] 
                                : Colors.grey[200],
                                      ),
                          // Settings Menu Item
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.settings,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ),
                            title: const Text(
                              'Settings',
                                style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              'Manage app preferences and options',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                        ),
                            onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                          Divider(
                            height: 1,
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.grey[700] 
                                : Colors.grey[200],
                          ),
                          // Purchase History Menu Item
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.shopping_cart,
                                color: Colors.purple,
                                size: 20,
                              ),
                            ),
                            title: const Text(
                              'Purchase History',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              'View your past purchases',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const PurchaseHistoryScreen(),
                                ),
                              );
                            },
                          ),
                        ],
              ),
            ),
            const SizedBox(height: 24),
                    
                    // Logout Button
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
                          await _showLogoutConfirmation();
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 