import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';

class TicketViewScreen extends StatelessWidget {
  final EventModel event;
  final User? user;
  const TicketViewScreen({Key? key, required this.event, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Details')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // QR code placeholder
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code, size: 120, color: Colors.black54),
                ),
              ),
              const SizedBox(height: 24),
              Text('Event: ${event.name}', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Event ID: ${event.id}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              Text('User: ${user?.name ?? "Unknown"}', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text('User ID: ${user?.id ?? "Unknown"}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
} 