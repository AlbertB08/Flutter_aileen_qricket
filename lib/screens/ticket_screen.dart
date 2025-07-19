import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import 'ticket_view_screen.dart';

class TicketScreen extends StatefulWidget {
  final User? user;
  const TicketScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  List<EventModel> _participatedEvents = [];
  bool _loading = true;
  String _sortOption = 'DateNewest';

  @override
  void initState() {
    super.initState();
    _loadParticipatedEvents();
  }

  Future<void> _loadParticipatedEvents() async {
    setState(() => _loading = true);
    final eventService = EventService();
    await eventService.initialize();
    final allEvents = eventService.events;
    final ids = widget.user?.participatedEventIds ?? [];
    setState(() {
      _participatedEvents = allEvents.where((e) => ids.contains(e.id)).toList();
      _sortEvents();
      _loading = false;
    });
  }

  void _sortEvents() {
    final events = [..._participatedEvents]; // Make a copy before sorting
    switch (_sortOption) {
      case 'DateNewest':
        events.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'DateOldest':
        events.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'NameAZ':
        events.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case 'NameZA':
        events.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case 'Category':
        events.sort((a, b) => a.category.toLowerCase().compareTo(b.category.toLowerCase()));
        break;
    }
    setState(() {
      _participatedEvents = events;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Tickets'),
        backgroundColor: const Color(0xFF00B388),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _participatedEvents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.confirmation_number_outlined,
                        size: 64,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tickets found',
                        style: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.grey[300] : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You haven\'t participated in any events yet',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Sorting Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.sort,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sort by:',
                            style: TextStyle(
                              color: isDark ? Colors.grey[300] : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF3A3A3A) : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                                ),
                              ),
                              child: DropdownButton<String>(
                                value: _sortOption,
                                isExpanded: true,
                                underline: Container(),
                                dropdownColor: isDark ? const Color(0xFF3A3A3A) : Colors.white,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'DateNewest',
                                    child: Text('Date: Newest First'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'DateOldest',
                                    child: Text('Date: Oldest First'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'NameAZ',
                                    child: Text('Name: A-Z'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'NameZA',
                                    child: Text('Name: Z-A'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Category',
                                    child: Text('Category'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _sortOption = value ?? 'DateNewest';
                                  });
                                  _sortEvents();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tickets List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _participatedEvents.length,
                        itemBuilder: (context, index) {
                          final event = _participatedEvents[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00B388).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.confirmation_number,
                                  color: Color(0xFF00B388),
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                event.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    event.category,
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${event.formattedDate} at ${event.formattedTime}',
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00B388).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.qr_code,
                                  color: Color(0xFF00B388),
                                  size: 20,
                                ),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => TicketViewScreen(event: event, user: widget.user),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
} 