import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/invoice_model.dart';
import 'invoice_service.dart';

class NotificationService {
  static List<NotificationModel> _notifications = [];
  static const String _notificationsKey = 'user_notifications';

  static List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  /// Initialize notification service
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString(_notificationsKey);
    
    if (notificationsJson != null) {
      final List<dynamic> notificationsList = jsonDecode(notificationsJson);
      _notifications = notificationsList
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    }
  }

  /// Get notifications for a specific user
  static List<NotificationModel> getNotificationsForUser(String userId) {
    return _notifications
        .where((notification) => notification.userId == userId)
        .toList();
  }

  /// Get unread notifications for a user
  static List<NotificationModel> getUnreadNotificationsForUser(String userId) {
    return _notifications
        .where((notification) => notification.userId == userId && !notification.isRead)
        .toList();
  }

  /// Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
    }
  }

  /// Mark all notifications as read for a user
  static Future<void> markAllAsRead(String userId) async {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].userId == userId) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    await _saveNotifications();
  }

  /// Add a new notification
  static Future<void> addNotification(NotificationModel notification) async {
    _notifications.add(notification);
    await _saveNotifications();
  }

  /// Generate notifications based on user activities and events
  static Future<void> generateNotificationsForUser(User user, List<EventModel> events) async {
    final List<NotificationModel> newNotifications = [];
    final now = DateTime.now();

    // Generate event reminders for upcoming events
    for (final eventId in user.participatedEventIds) {
      final event = events.where((e) => e.id == eventId).firstOrNull;
      if (event != null && !event.isPast) {
        final daysUntilEvent = event.date.difference(now).inDays;
        
        // Reminder 1 day before
        if (daysUntilEvent == 1) {
          newNotifications.add(NotificationModel(
            id: 'reminder_1day_${event.id}_${user.id}',
            userId: user.id,
            title: 'Event Tomorrow!',
            message: '${event.name} is happening tomorrow at ${event.formattedTime}. Don\'t forget to attend!',
            type: 'event_reminder',
            timestamp: now,
            metadata: {'eventId': event.id},
          ));
        }
        
        // Reminder 1 hour before
        final hoursUntilEvent = event.date.difference(now).inHours;
        if (hoursUntilEvent == 1) {
          newNotifications.add(NotificationModel(
            id: 'reminder_1hour_${event.id}_${user.id}',
            userId: user.id,
            title: 'Event Starting Soon!',
            message: '${event.name} starts in 1 hour. Make sure you\'re ready!',
            type: 'event_reminder',
            timestamp: now,
            metadata: {'eventId': event.id},
          ));
        }
      }
    }

    // Generate ticket purchase notifications with actual purchase dates
    final userInvoices = InvoiceService.getInvoicesForUser(user.id);
    for (final invoice in userInvoices) {
      final existingNotification = _notifications.any((n) => 
        n.metadata?['invoiceId'] == invoice.id && n.type == 'ticket_purchase');
      
      if (!existingNotification) {
        newNotifications.add(NotificationModel(
          id: 'purchase_${invoice.id}_${user.id}',
          userId: user.id,
          title: 'Ticket Purchased!',
          message: 'Your ticket for ${invoice.eventName} has been purchased successfully. Invoice: ${invoice.id}',
          type: 'ticket_purchase',
          timestamp: invoice.purchaseDate, // Use actual purchase date
          metadata: {
            'invoiceId': invoice.id,
            'eventId': invoice.eventId,
            'ticketId': invoice.ticketId,
          },
        ));
      }
    }

    // Generate new event notifications (for events user might be interested in)
    for (final event in events) {
      if (!event.isPast && !user.participatedEventIds.contains(event.id)) {
        // Check if event is recent (within last 30 days instead of 7)
        final daysSinceCreation = now.difference(event.date).inDays.abs();
        if (daysSinceCreation <= 30) {
          final existingNotification = _notifications.any((n) => 
            n.metadata?['eventId'] == event.id && n.type == 'new_event');
          
          if (!existingNotification) {
            newNotifications.add(NotificationModel(
              id: 'new_event_${event.id}_${user.id}',
              userId: user.id,
              title: 'New Event Available!',
              message: '${event.name} is now available for registration. ${event.description.substring(0, 50)}...',
              type: 'new_event',
              timestamp: event.date, // Use event creation date
              metadata: {'eventId': event.id},
            ));
          }
        }
      }
    }

    // Generate event update notifications with actual event dates
    for (final event in events) {
      if (!event.isPast && user.participatedEventIds.contains(event.id)) {
        // Simulate event updates (in real app, this would check for actual updates)
        final existingUpdateNotification = _notifications.any((n) => 
          n.metadata?['eventId'] == event.id && n.type == 'event_update');
        
        if (!existingUpdateNotification && event.category == 'Technology') {
          // Simulate a lineup update for tech events - use event date as reference
          final updateDate = event.date.subtract(const Duration(days: 7)); // 1 week before event
          if (now.isAfter(updateDate)) {
            newNotifications.add(NotificationModel(
              id: 'update_${event.id}_${user.id}',
              userId: user.id,
              title: 'Event Update',
              message: '${event.name} has updated its speaker lineup and schedule. Check the latest details!',
              type: 'event_update',
              timestamp: updateDate, // Use actual update date
              metadata: {'eventId': event.id},
            ));
          }
        }
      }
    }

    // Generate news notifications with actual news dates
    for (final event in events) {
      if (event.news.isNotEmpty) {
        for (final news in event.news) {
          final existingNewsNotification = _notifications.any((n) => 
            n.metadata?['newsId'] == '${event.id}_${news.date.millisecondsSinceEpoch}' && n.type == 'news');
          
          if (!existingNewsNotification && now.isAfter(news.date)) {
            newNotifications.add(NotificationModel(
              id: 'news_${event.id}_${news.date.millisecondsSinceEpoch}_${user.id}',
              userId: user.id,
              title: 'Event News',
              message: '${news.title} - ${news.message.substring(0, 80)}...',
              type: 'news',
              timestamp: news.date, // Use actual news date
              metadata: {
                'newsId': '${event.id}_${news.date.millisecondsSinceEpoch}',
                'eventId': event.id,
              },
            ));
          }
        }
      }
    }

    // Add new notifications
    for (final notification in newNotifications) {
      await addNotification(notification);
    }
  }

  /// Save notifications to SharedPreferences
  static Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = jsonEncode(_notifications.map((n) => n.toJson()).toList());
    await prefs.setString(_notificationsKey, notificationsJson);
  }

  /// Clear all notifications for a user
  static Future<void> clearNotificationsForUser(String userId) async {
    _notifications.removeWhere((notification) => notification.userId == userId);
    await _saveNotifications();
  }

  /// Clean up very old notifications (older than 2 years) to prevent storage bloat
  static Future<void> cleanupOldNotifications() async {
    final twoYearsAgo = DateTime.now().subtract(const Duration(days: 730));
    _notifications.removeWhere((notification) => notification.timestamp.isBefore(twoYearsAgo));
    await _saveNotifications();
  }

  /// Get notification count for a user
  static int getNotificationCount(String userId) {
    return _notifications.where((n) => n.userId == userId).length;
  }

  /// Get unread notification count for a user
  static int getUnreadNotificationCount(String userId) {
    return _notifications.where((n) => n.userId == userId && !n.isRead).length;
  }
} 