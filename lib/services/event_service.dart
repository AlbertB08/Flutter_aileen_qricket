import '../models/event_model.dart';
import '../models/news_model.dart' as news;
import 'storage_service.dart';
import 'data_service.dart';

/// Service class responsible for managing event operations
class EventService {
  final StorageService _storageService;
  final List<EventModel> _events = [];
  bool _isInitialized = false;

  /// Constructor with dependency injection
  EventService({StorageService? storageService})
      : _storageService = storageService ?? SharedPreferencesStorageService();

  /// Get all events (read-only)
  List<EventModel> get events => List.unmodifiable(_events);

  /// Get event count
  int get eventCount => _events.length;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the service and load data
  Future<void> initialize({bool force = false}) async {
    if (_isInitialized && !force) return;
    try {
      await _storageService.initialize();
      await _loadEvents();
      
      // If no events exist, load from JSON data
      if (_events.isEmpty) {
        await _loadEventsFromJson();
      }
      
      _isInitialized = true;
    } catch (e) {
      throw EventServiceException('Failed to initialize service: $e');
    }
  }

  /// Load events from storage
  Future<void> _loadEvents() async {
    try {
      final loadedEvents = await _storageService.loadEvents();
      _events.clear();
      _events.addAll(loadedEvents);
    } catch (e) {
      throw EventServiceException('Failed to load events: $e');
    }
  }

  /// Load events from JSON data
  Future<void> _loadEventsFromJson() async {
    try {
      await DataService.loadInitialData();
      _events.clear();
      _events.addAll(DataService.events);
      await _saveEvents();
    } catch (e) {
      throw EventServiceException('Failed to load events from JSON: $e');
    }
  }

  /// Save events to storage
  Future<void> _saveEvents() async {
    try {
      await _storageService.saveEvents(_events);
    } catch (e) {
      throw EventServiceException('Failed to save events: $e');
    }
  }

  /// Add new event
  Future<void> addEvent(EventModel event) async {
    _ensureInitialized();
    
    try {
      _events.add(event);
      await _saveEvents();
    } catch (e) {
      // Rollback on error
      _events.remove(event);
      throw EventServiceException('Failed to add event: $e');
    }
  }

  /// Update existing event
  Future<void> updateEvent(EventModel event) async {
    _ensureInitialized();
    
    try {
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index == -1) {
        throw EventServiceException('Event not found with id: ${event.id}');
      }
      
      final oldEvent = _events[index];
      _events[index] = event;
      
      try {
        await _saveEvents();
      } catch (e) {
        // Rollback on error
        _events[index] = oldEvent;
        throw e;
      }
    } catch (e) {
      throw EventServiceException('Failed to update event: $e');
    }
  }

  /// Delete event by id
  Future<void> deleteEvent(String id) async {
    _ensureInitialized();
    
    try {
      final event = _events.firstWhere((e) => e.id == id);
      _events.remove(event);
      await _saveEvents();
    } catch (e) {
      throw EventServiceException('Failed to delete event: $e');
    }
  }

  /// Get event by id
  EventModel? getEventById(String id) {
    _ensureInitialized();
    
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get events by category
  List<EventModel> getEventsByCategory(String category) {
    _ensureInitialized();
    
    return _events.where((event) => event.category.toLowerCase() == category.toLowerCase()).toList();
  }

  /// Get future events
  List<EventModel> getFutureEvents() {
    _ensureInitialized();
    
    return _events.where((event) => event.isFuture).toList();
  }

  /// Get past events
  List<EventModel> getPastEvents() {
    _ensureInitialized();
    
    return _events.where((event) => event.isPast).toList();
  }

  /// Get today's events
  List<EventModel> getTodayEvents() {
    _ensureInitialized();
    
    return _events.where((event) => event.isToday).toList();
  }

  /// Search events by name or description
  List<EventModel> searchEvents(String query) {
    _ensureInitialized();
    
    if (query.isEmpty) return events;
    
    final lowercaseQuery = query.toLowerCase();
    return _events.where((event) {
      return event.name.toLowerCase().contains(lowercaseQuery) ||
             event.description.toLowerCase().contains(lowercaseQuery) ||
             event.category.toLowerCase().contains(lowercaseQuery) ||
             event.location.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Get events sorted by date (newest first)
  List<EventModel> getEventsSortedByDate() {
    _ensureInitialized();
    
    final sortedEvents = List<EventModel>.from(_events);
    sortedEvents.sort((a, b) => b.date.compareTo(a.date));
    return sortedEvents;
  }

  /// Get unique categories
  List<String> getCategories() {
    _ensureInitialized();
    
    final categories = _events.map((event) => event.category).toSet();
    return categories.toList()..sort();
  }

  /// Ensure service is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw EventServiceException('Service not initialized. Call initialize() first.');
    }
  }
}

/// Custom exception for event service operations
class EventServiceException implements Exception {
  final String message;
  
  EventServiceException(this.message);
  
  @override
  String toString() => 'EventServiceException: $message';
} 