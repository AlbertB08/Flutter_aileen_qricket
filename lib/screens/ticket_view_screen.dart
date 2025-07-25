import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TicketViewScreen extends StatelessWidget {
  final EventModel event;
  final User? user;
  const TicketViewScreen({Key? key, required this.event, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generate a unique ticket ID based on event and user
    final ticketId = 'TICKET-${event.id}-${user?.id ?? "unknown"}';
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Details')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // QR code placeholder
              QrImageView(
                data: 'event:${event.id};user:${user?.id ?? "unknown"}',
                size: 200.0,
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 24),
              Text('Event: ${event.name}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Event ID: ${event.id}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              Text('User: ${user?.name ?? "Unknown"}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('User ID: ${user?.id ?? "Unknown"}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              Text('Ticket ID: $ticketId', style: const TextStyle(fontSize: 16, color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }
} 