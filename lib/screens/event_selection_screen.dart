import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/feedback_model.dart';
import '../services/event_service.dart';
import '../services/feedback_service.dart';
import '../services/auth_service.dart';
import '../widgets/event_card.dart';
import 'feedback_screen.dart';
import 'base_screen.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _initAndLoadData();
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
    _participatedEventIds = await SharedPreferencesStorageService.getParticipatedEventIds();
    await _loadData();
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
        builder: (context) => FeedbackScreen(selectedEvent: event),
      ),
    );
    // Always reload data and update state after returning
    await _loadData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF00B388),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Q',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Qricket'),
          ],
        ),
        backgroundColor: const Color(0xFF00B388),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
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
                    final participated = _participatedEventIds.contains(event.id);
                    return EventCard(
                      event: event,
                      feedbackList: _feedbackList,
                      onTap: () => _navigateToEventFeedback(event),
                      participated: participated,
                    );
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1) {
            _logout();
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
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
      ),
    );
  }
} 