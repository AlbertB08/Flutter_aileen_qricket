import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'base_screen.dart';
import 'package:intl/intl.dart';
import 'dart:io'; // Added for FileImage

class ActivityLogScreen extends BaseScreen {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends BaseScreenState<ActivityLogScreen> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      _currentUser = AuthService.currentUser;
    });
  }

  IconData _getActivityIcon(String activity) {
    switch (activity.toLowerCase()) {
      case 'login':
        return Icons.login;
      case 'logout':
        return Icons.logout;
      case 'account registration':
        return Icons.person_add;
      case 'account verification':
        return Icons.verified;
      case 'account update':
        return Icons.edit;
      case 'ticket purchase':
        return Icons.confirmation_number;
      case 'event save':
        return Icons.bookmark;
      case 'event unsave':
        return Icons.bookmark_border;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String activity) {
    switch (activity.toLowerCase()) {
      case 'login':
        return Colors.green;
      case 'logout':
        return Colors.red;
      case 'account registration':
        return Colors.blue;
      case 'account verification':
        return Colors.green;
      case 'account update':
        return Colors.orange;
      case 'ticket purchase':
        return Colors.purple;
      case 'event save':
        return Colors.blue;
      case 'event unsave':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

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

  ImageProvider? _getProfileImageProvider() {
    final user = _currentUser;
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

  @override
  Widget build(BuildContext context) {
    final activityLog = _currentUser?.activityLog ?? [];
    final reversedLog = activityLog.reversed.toList();

    // Group activities by date
    Map<String, List<dynamic>> groupedByDate = {};
    for (var entry in reversedLog) {
      String dateKey = DateFormat('MMMM d, yyyy').format(entry.datetime);
      groupedByDate.putIfAbsent(dateKey, () => []).add(entry);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity log'),
        backgroundColor: const Color(0xFF00B388),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: activityLog.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No activity logged yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your account activities will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                _loadUserData();
              },
              child: ListView(
                padding: const EdgeInsets.all(0),
                children: groupedByDate.entries.map((dateGroup) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                        child: Text(
                          dateGroup.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ...dateGroup.value.map((entry) {
                        bool isPublic = entry.activity.toLowerCase().contains('public');
                  return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.grey[900]
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                          child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar
                              CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                backgroundImage: _getProfileImageProvider(),
                                child: _getProfileImageProvider() == null
                                    ? const Icon(Icons.person, color: Colors.white)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              // Main content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                                fontSize: 15,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: '${_currentUser?.fname ?? ''} ${_currentUser?.lname ?? ''} ',
                                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                TextSpan(
                                                  text: entry.activity,
                                                  style: const TextStyle(fontWeight: FontWeight.w400),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (isPublic)
                                          Row(
                                            children: [
                                              const Icon(Icons.public, size: 16, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              const Text('Public', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                            ],
                                          )
                                        else
                                          Row(
                                            children: [
                                              const Icon(Icons.lock, size: 16, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              const Text('Only me', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                            ],
                                          ),
                                        const SizedBox(width: 8),
                                    Text(
                                          DateFormat('h:mm a').format(entry.datetime),
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                        // Three-dot menu
                                        PopupMenuButton<String>(
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Text('Delete'),
                                            ),
                                          ],
                                          onSelected: (value) {
                                            // TODO: Implement delete
                                          },
                                          icon: const Icon(Icons.more_horiz, size: 18, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    if (entry.activityDetails.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: Text(
                                          entry.activityDetails,
                                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                        ),
                                      ),
                                    if (isPublic)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[200],
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Text('View'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
} 