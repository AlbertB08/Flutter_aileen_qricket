import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/feedback_model.dart';
import '../services/event_service.dart';
import '../services/feedback_service.dart';
import '../services/auth_service.dart';
import '../widgets/event_card.dart';
import 'selected_event_screen.dart';
import 'base_screen.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';
import '../models/user_model.dart';
import 'account_settings_screen.dart';
import 'ticket_screen.dart';
import 'dart:io';

/// Main screen for event selection and navigation
class EventSelectionScreen extends BaseScreen {
  const EventSelectionScreen({super.key});

  @override
  State<EventSelectionScreen> createState() => _EventSelectionScreenState();
}

class _EventSelectionScreenState extends BaseScreenState<EventSelectionScreen> {
  final EventService _eventService = EventService();
  final FeedbackService _feedbackService = FeedbackService();
  List<EventModel> _events = [];
  List<FeedbackModel> _feedbackList = [];
  bool _isLoading = true;
  List<String> _participatedEventIds = [];
  int _currentIndex = 0;
  void _navigateToTicketScreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TicketScreen(user: _currentUser),
      ),
    );
  }
  User? _currentUser;
  String _searchQuery = '';
  String? _selectedCategory;
  List<String> _categories = [];
  String _sortOption = 'Default';

  @override
  void initState() {
    super.initState();
    _initAndLoadData();
    _loadCurrentUser();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    await _eventService.initialize();
    setState(() {
      _categories = _eventService.getCategories();
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _initAndLoadData() async {
    await _loadData();
  }

  Future<void> _loadCurrentUser() async {
    final user = AuthService.currentUser;
    setState(() {
      _currentUser = user;
    });
  }

  /// Load events and feedback data
  Future<void> _loadData() async {
    try {
      showLoading();
      await _eventService.initialize(force: true);
      await _feedbackService.initialize(force: true);
      
      _events = _eventService.events;
      _feedbackList = _feedbackService.feedbacks;
      
      hideLoading();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      hideLoading();
      showError('Failed to load data: $e');
    }
  }

  /// Navigate to feedback screen for selected event
  void _navigateToEventFeedback(EventModel event) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelectedEventScreen(selectedEvent: event),
      ),
    );
    // Always reload data and update state after returning
    await _loadData();
    setState(() {});
  }

  void _navigateToAccountSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccountSettingsScreen(
          onUserInfoChanged: _loadCurrentUser,
        ),
      ),
    );
    _loadCurrentUser();
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationItem(
              'Event Reminder',
              'Tech Conference 2024 starts in 2 days',
              '2 hours ago',
              Icons.event,
            ),
            const SizedBox(height: 12),
            _buildNotificationItem(
              'New Event',
              'Art Exhibition registration is now open',
              '1 day ago',
              Icons.art_track,
            ),
            const SizedBox(height: 12),
            _buildNotificationItem(
              'Event Update',
              'Music Festival lineup has been updated',
              '3 days ago',
              Icons.music_note,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read')),
              );
            },
            child: const Text('Mark All Read'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String message, String time, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF00B388), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                  style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (_currentUser != null) ...[
              GestureDetector(
                onTap: _navigateToAccountSettings,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: (_currentUser?.profileImagePath != null && (_currentUser?.profileImagePath?.isNotEmpty ?? false))
                      ? FileImage(File(_currentUser!.profileImagePath!))
                      : null,
                  child: (_currentUser?.profileImagePath == null || (_currentUser?.profileImagePath?.isEmpty ?? true))
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _currentUser!.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              ),
            ]
          ],
        ),
        backgroundColor: const Color(0xFF00B388),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [],
      ),
      body: _currentIndex == 0
          ? (_isLoading
              ? const Center(child: CircularProgressIndicator())
              : _events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No events available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: 'Search events...',
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              DropdownButton<String>(
                                value: _selectedCategory,
                                hint: const Text('Filter'),
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: null,
                                    child: Text('All'),
                                  ),
                                  ..._categories.map((cat) => DropdownMenuItem<String>(
                                        value: cat,
                                        child: Text(cat),
                                      )),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCategory = value;
                                  });
                                },
                              ),
                              const SizedBox(width: 12),
                              DropdownButton<String>(
                                value: _sortOption,
                                items: const [
                                  DropdownMenuItem(value: 'Default', child: Text('Default')),
                                  DropdownMenuItem(value: 'DateNewest', child: Text('Date: Newest')),
                                  DropdownMenuItem(value: 'DateOldest', child: Text('Date: Oldest')),
                                  DropdownMenuItem(value: 'NameAZ', child: Text('Name: A-Z')),
                                  DropdownMenuItem(value: 'NameZA', child: Text('Name: Z-A')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _sortOption = value ?? 'Default';
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              List<EventModel> filtered = _events;
                              if (_searchQuery.isNotEmpty) {
                                filtered = _eventService.searchEvents(_searchQuery);
                              }
                              if (_selectedCategory != null) {
                                filtered = filtered.where((e) => e.category == _selectedCategory).toList();
                              }
                              filtered = [...filtered]; // Make a copy before sorting
                              // Sorting
                              switch (_sortOption) {
                                case 'DateNewest':
                                  filtered.sort((a, b) => b.date.compareTo(a.date));
                                  break;
                                case 'DateOldest':
                                  filtered.sort((a, b) => a.date.compareTo(b.date));
                                  break;
                                case 'NameAZ':
                                  filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                                  break;
                                case 'NameZA':
                                  filtered.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
                                  break;
                                case 'Default':
                                default:
                                  break;
                              }
                              if (filtered.isEmpty) {
                                return const Center(child: Text('No events found.'));
                              }
                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final event = filtered[index];
                                  final participated = _currentUser?.participatedEventIds.contains(event.id) ?? false;
                                  return EventCard(
                                    event: event,
                                    feedbackList: _feedbackList,
                                    onTap: () => _navigateToEventFeedback(event),
                                    participated: participated,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ))
          : _currentIndex == 1
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications, size: 64, color: Color(0xFF00B388)),
                      const SizedBox(height: 16),
                      const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // Show notification items
                      _buildNotificationItem(
                        'Event Reminder',
                        'Tech Conference 2024 starts in 2 days',
                        '2 hours ago',
                        Icons.event,
                      ),
                      const SizedBox(height: 12),
                      _buildNotificationItem(
                        'New Event',
                        'Art Exhibition registration is now open',
                        '1 day ago',
                        Icons.art_track,
                      ),
                      const SizedBox(height: 12),
                      _buildNotificationItem(
                        'Event Update',
                        'Music Festival lineup has been updated',
                        '3 days ago',
                        Icons.music_note,
                      ),
                    ],
                  ),
                )
              : _currentIndex == 2
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.confirmation_number, size: 64, color: Color(0xFF00B388)),
                          SizedBox(height: 16),
                          Text('Your Tickets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Text('Ticket feature coming soon!'),
                        ],
                      ),
                    )
                  : (_isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No events available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    final event = _events[index];
                    final participated = _currentUser?.participatedEventIds.contains(event.id) ?? false;
                    return EventCard(
                      event: event,
                      feedbackList: _feedbackList,
                      onTap: () => _navigateToEventFeedback(event),
                      participated: participated,
                    );
                  },
                            )),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 2) {
            _navigateToTicketScreen();
          } else {
            setState(() {
              _currentIndex = index;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00B388),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Ticket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
      ),
    );
  }
} 