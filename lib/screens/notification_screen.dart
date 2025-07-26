import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import 'base_screen.dart';

class NotificationScreen extends BaseScreen {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends BaseScreenState<NotificationScreen> {
  List<NotificationModel> _userNotifications = [];
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh notifications when dependencies change
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      showLoading();
      
      // Initialize notification service
      await NotificationService.initialize();
      
      // Get current user
      _currentUser = AuthService.currentUser;
      
      if (_currentUser != null) {
        _userNotifications = NotificationService.getNotificationsForUser(_currentUser!.id);
        // Sort by timestamp (newest first)
        _userNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      }
      
      hideLoading();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      hideLoading();
      showError('Failed to load notifications: $e');
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    await NotificationService.markAsRead(notification.id);
    setState(() {
      notification = notification.copyWith(isRead: true);
    });
  }

  Future<void> _markAllAsRead() async {
    if (_currentUser != null) {
      await NotificationService.markAllAsRead(_currentUser!.id);
      await _loadNotifications();
    }
  }

  String _getTimestampText(NotificationModel notification) {
    final now = DateTime.now();
    final notificationDate = notification.timestamp;

    if (now.year == notificationDate.year &&
        now.month == notificationDate.month &&
        now.day == notificationDate.day) {
      return 'Today at ${notificationDate.hour.toString().padLeft(2, '0')}:${notificationDate.minute.toString().padLeft(2, '0')}';
    } else if (now.year == notificationDate.year &&
               now.month == notificationDate.month &&
               now.day == notificationDate.day - 1) {
      return 'Yesterday at ${notificationDate.hour.toString().padLeft(2, '0')}:${notificationDate.minute.toString().padLeft(2, '0')}';
    } else {
      return notification.exactDateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF00B388),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_userNotifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark All Read',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userNotifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_none,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No notifications',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You\'ll see notifications here when you have updates',
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
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _userNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = _userNotifications[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: notification.isRead 
                              ? (Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.grey[800] 
                                  : Colors.white)
                              : notification.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: notification.color.withOpacity(0.2),
                            width: notification.isRead ? 1 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () => _markAsRead(notification),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: notification.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    notification.icon,
                                    color: notification.color,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notification.title,
                                              style: TextStyle(
                                                fontWeight: notification.isRead 
                                                    ? FontWeight.w500 
                                                    : FontWeight.bold,
                                                fontSize: 16,
                                                color: notification.isRead 
                                                    ? Colors.grey[600] 
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ),
                                          if (!notification.isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: notification.color,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notification.message,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getTimestampText(notification),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
} 