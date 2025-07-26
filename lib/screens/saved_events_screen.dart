import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/feedback_model.dart';
import '../models/user_model.dart';
import '../services/event_service.dart';
import '../services/feedback_service.dart';
import '../services/auth_service.dart';
import '../widgets/event_card.dart';
import 'selected_event_screen.dart';
import 'base_screen.dart';
import 'dart:io';

class SavedEventsScreen extends BaseScreen {
  const SavedEventsScreen({super.key});

  @override
  State<SavedEventsScreen> createState() => _SavedEventsScreenState();
}

class _SavedEventsScreenState extends BaseScreenState<SavedEventsScreen> {
  final EventService _eventService = EventService();
  final FeedbackService _feedbackService = FeedbackService();
  List<EventModel> _allEvents = [];
  List<EventModel> _savedEvents = [];
  List<FeedbackModel> _feedbackList = [];
  bool _isLoading = true;
  User? _currentUser;
  String _searchQuery = '';
  String? _selectedCategory;
  List<String> _categories = [];
  String _sortOption = 'DateNewest';

  @override
  void initState() {
    super.initState();
    _initAndLoadData();
    _loadCurrentUser();
    _loadCategories();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh user data when dependencies change
    _loadCurrentUser();
    _loadSavedEvents();
  }

  Future<void> _loadCurrentUser() async {
    final user = AuthService.currentUser;
    setState(() {
      _currentUser = user;
    });
    _loadSavedEvents();
  }

  Future<void> _loadCategories() async {
    await _eventService.initialize();
    setState(() {
      _categories = _eventService.getCategories();
    });
  }

  Future<void> _initAndLoadData() async {
    await _loadData();
  }

  Future<void> _loadData() async {
    try {
      showLoading();
      await _eventService.initialize(force: true);
      await _feedbackService.initialize(force: true);
      
      _allEvents = _eventService.events;
      _feedbackList = _feedbackService.feedbacks;
      
      hideLoading();
      setState(() {
        _isLoading = false;
      });
      _loadSavedEvents();
    } catch (e) {
      hideLoading();
      showError('Failed to load data: $e');
    }
  }

  void _loadSavedEvents() {
    if (_currentUser == null) {
      setState(() {
        _savedEvents = [];
      });
      return;
    }

    final savedEventIds = _currentUser!.bookmarkedEventIds;
    setState(() {
      _savedEvents = _allEvents.where((event) => savedEventIds.contains(event.id)).toList();
      _applyFiltersAndSort();
    });
  }

  void _applyFiltersAndSort() {
    List<EventModel> filtered = [..._savedEvents];

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((event) =>
        event.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        event.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        event.category.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply category filter
    if (_selectedCategory != null) {
      filtered = filtered.where((event) => event.category == _selectedCategory).toList();
    }

    // Apply sorting
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
      case 'Category':
        filtered.sort((a, b) => a.category.toLowerCase().compareTo(b.category.toLowerCase()));
        break;
    }

    setState(() {
      _savedEvents = filtered;
    });
  }

  void _navigateToEventDetails(EventModel event) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelectedEventScreen(selectedEvent: event),
      ),
    );
    // Refresh data after returning
    _loadCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Events'),
        backgroundColor: const Color(0xFF00B388),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedEvents.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No saved events',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Events you save will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Search and Filter Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Search Bar
                          TextField(
                            decoration: const InputDecoration(
                              hintText: 'Search saved events...',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                              _applyFiltersAndSort();
                            },
                          ),
                          const SizedBox(height: 12),
                          // Filter and Sort Row
                          Row(
                            children: [
                              // Category Filter
                              Expanded(
                                child: DropdownButton<String>(
                                  value: _selectedCategory,
                                  hint: const Text('All Categories'),
                                  isExpanded: true,
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('All Categories'),
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
                                    _applyFiltersAndSort();
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Sort Dropdown
                              Expanded(
                                child: DropdownButton<String>(
                                  value: _sortOption,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: 'DateNewest', child: Text('Date: Newest')),
                                    DropdownMenuItem(value: 'DateOldest', child: Text('Date: Oldest')),
                                    DropdownMenuItem(value: 'NameAZ', child: Text('Name: A-Z')),
                                    DropdownMenuItem(value: 'NameZA', child: Text('Name: Z-A')),
                                    DropdownMenuItem(value: 'Category', child: Text('Category')),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _sortOption = value ?? 'DateNewest';
                                    });
                                    _applyFiltersAndSort();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Events List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _savedEvents.length,
                          itemBuilder: (context, index) {
                            final event = _savedEvents[index];
                            final participated = _currentUser?.participatedEventIds.contains(event.id) ?? false;
                            final isBookmarked = _currentUser?.bookmarkedEventIds.contains(event.id) ?? false;
                            return EventCard(
                              event: event,
                              feedbackList: _feedbackList,
                              onTap: () => _navigateToEventDetails(event),
                              participated: participated,
                              isBookmarked: isBookmarked,
                              user: _currentUser,
                              onBookmark: () async {
                                if (_currentUser == null) return;
                                final updatedBookmarks = List<String>.from(_currentUser!.bookmarkedEventIds);
                                if (isBookmarked) {
                                  updatedBookmarks.remove(event.id);
                                } else {
                                  updatedBookmarks.add(event.id);
                                }
                                final updatedUser = _currentUser!.copyWith(bookmarkedEventIds: updatedBookmarks);
                                await AuthService.updateCurrentUser(updatedUser);
                                setState(() {
                                  _currentUser = updatedUser;
                                });
                                _loadSavedEvents();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
} 