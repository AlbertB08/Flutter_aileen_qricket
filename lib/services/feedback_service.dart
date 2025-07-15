import '../models/feedback_model.dart';
import 'storage_service.dart';

/// Service class responsible for managing feedback operations
class FeedbackService {
  final StorageService _storageService;
  final List<FeedbackModel> _feedbacks = [];
  bool _isInitialized = false;

  /// Constructor with dependency injection
  FeedbackService({StorageService? storageService})
      : _storageService = storageService ?? SharedPreferencesStorageService();

  /// Get all feedbacks (read-only)
  List<FeedbackModel> get feedbacks => List.unmodifiable(_feedbacks);

  /// Get feedback count
  int get feedbackCount => _feedbacks.length;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the service and load data
  Future<void> initialize({bool force = false}) async {
    if (_isInitialized && !force) return;
    try {
      await _storageService.initialize();
      await _loadFeedbacks();
      _isInitialized = true;
    } catch (e) {
      throw FeedbackServiceException('Failed to initialize service: $e');
    }
  }

  /// Load feedbacks from storage
  Future<void> _loadFeedbacks() async {
    try {
      final loadedFeedbacks = await _storageService.loadData();
      _feedbacks.clear();
      _feedbacks.addAll(loadedFeedbacks);
    } catch (e) {
      throw FeedbackServiceException('Failed to load feedbacks: $e');
    }
  }

  /// Save feedbacks to storage
  Future<void> _saveFeedbacks() async {
    try {
      await _storageService.saveData(_feedbacks);
    } catch (e) {
      throw FeedbackServiceException('Failed to save feedbacks: $e');
    }
  }

  /// Add new feedback
  Future<void> addFeedback(FeedbackModel feedback) async {
    _ensureInitialized();
    
    try {
      _feedbacks.add(feedback);
      await _saveFeedbacks();
    } catch (e) {
      // Rollback on error
      _feedbacks.remove(feedback);
      throw FeedbackServiceException('Failed to add feedback: $e');
    }
  }

  /// Update existing feedback
  Future<void> updateFeedback(FeedbackModel feedback) async {
    _ensureInitialized();
    
    try {
      final index = _feedbacks.indexWhere((f) => f.id == feedback.id);
      if (index == -1) {
        throw FeedbackServiceException('Feedback not found with id: ${feedback.id}');
      }
      
      final oldFeedback = _feedbacks[index];
      _feedbacks[index] = feedback;
      
      try {
        await _saveFeedbacks();
      } catch (e) {
        // Rollback on error
        _feedbacks[index] = oldFeedback;
        throw e;
      }
    } catch (e) {
      throw FeedbackServiceException('Failed to update feedback: $e');
    }
  }

  /// Delete feedback by id
  Future<void> deleteFeedback(String id) async {
    _ensureInitialized();
    
    try {
      final feedback = _feedbacks.firstWhere((f) => f.id == id);
      _feedbacks.remove(feedback);
      await _saveFeedbacks();
    } catch (e) {
      throw FeedbackServiceException('Failed to delete feedback: $e');
    }
  }

  /// Get feedback by id
  FeedbackModel? getFeedbackById(String id) {
    _ensureInitialized();
    
    try {
      return _feedbacks.firstWhere((feedback) => feedback.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear all feedbacks
  Future<void> clearAllFeedbacks() async {
    _ensureInitialized();
    
    try {
      _feedbacks.clear();
      await _saveFeedbacks();
    } catch (e) {
      throw FeedbackServiceException('Failed to clear feedbacks: $e');
    }
  }

  /// Search feedbacks by title or description
  List<FeedbackModel> searchFeedbacks(String query) {
    _ensureInitialized();
    
    if (query.isEmpty) return feedbacks;
    
    final lowercaseQuery = query.toLowerCase();
    return _feedbacks.where((feedback) {
      return feedback.title.toLowerCase().contains(lowercaseQuery) ||
             feedback.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Get feedbacks sorted by date (newest first)
  List<FeedbackModel> getFeedbacksSortedByDate() {
    _ensureInitialized();
    
    final sortedFeedbacks = List<FeedbackModel>.from(_feedbacks);
    sortedFeedbacks.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedFeedbacks;
  }

  /// Get average rating
  double get averageRating {
    _ensureInitialized();
    
    if (_feedbacks.isEmpty) return 0.0;
    
    final totalRating = _feedbacks.fold<int>(0, (sum, feedback) => sum + feedback.rating);
    return totalRating / _feedbacks.length;
  }

  /// Get feedbacks by event id
  List<FeedbackModel> getFeedbacksByEvent(String eventId) {
    _ensureInitialized();
    
    return _feedbacks.where((feedback) => feedback.eventId == eventId).toList();
  }

  /// Get average rating for a specific event
  double getAverageRatingForEvent(String eventId) {
    _ensureInitialized();
    
    final eventFeedbacks = getFeedbacksByEvent(eventId);
    if (eventFeedbacks.isEmpty) return 0.0;
    
    final totalRating = eventFeedbacks.fold<int>(0, (sum, feedback) => sum + feedback.rating);
    return totalRating / eventFeedbacks.length;
  }

  /// Get feedback count for a specific event
  int getFeedbackCountForEvent(String eventId) {
    _ensureInitialized();
    
    return getFeedbacksByEvent(eventId).length;
  }

  /// Ensure service is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw FeedbackServiceException('Service not initialized. Call initialize() first.');
    }
  }
}

/// Custom exception for feedback service operations
class FeedbackServiceException implements Exception {
  final String message;
  
  FeedbackServiceException(this.message);
  
  @override
  String toString() => 'FeedbackServiceException: $message';
} 