import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock notifications
    final notifications = [
      {
        'title': 'Event Reminder',
        'message': 'Tech Conference 2024 starts in 2 days',
        'time': '2 hours ago',
        'icon': Icons.event,
      },
      {
        'title': 'New Event',
        'message': 'Art Exhibition registration is now open',
        'time': '1 day ago',
        'icon': Icons.art_track,
      },
      {
        'title': 'Event Update',
        'message': 'Music Festival lineup has been updated',
        'time': '3 days ago',
        'icon': Icons.music_note,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF00B388),
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Card(
            child: ListTile(
              leading: Icon(notif['icon'] as IconData, color: const Color(0xFF00B388)),
              title: Text(notif['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif['message'] as String),
                  const SizedBox(height: 4),
                  Text(notif['time'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 