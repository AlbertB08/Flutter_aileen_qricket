import 'package:flutter/material.dart';
import '../models/feedback_model.dart';
import '../models/event_model.dart';
import '../services/feedback_service.dart';
import '../services/event_service.dart';
import '../widgets/feedback_form.dart';
import '../widgets/feedback_card.dart';
import '../widgets/existing_comment_card.dart';
import 'base_screen.dart';
import '../services/storage_service.dart';

/// Screen for managing feedback for a specific event
class FeedbackScreen extends BaseScreen {
  final EventModel selectedEvent;

  const FeedbackScreen({
    super.key,
    required this.selectedEvent,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends BaseScreenState<FeedbackScreen> {
  final FeedbackService _feedbackService = FeedbackService();
  final EventService _eventService = EventService();
  List<FeedbackModel> _feedbackList = [];
  List<EventModel> _events = [];
  bool _isLoading = true;
  String? _userId;
  List<String> _participatedEventIds = [];

  @override
  void initState() {
    super.initState();
    _initUserIdAndLoadData();
  }

  Future<void> _initUserIdAndLoadData() async {
    _userId = await SharedPreferencesStorageService.getOrCreateUserId();
    _participatedEventIds = await SharedPreferencesStorageService.getParticipatedEventIds();
    await _loadData();
  }

  /// Load feedback and events data
  Future<void> _loadData() async {
    try {
      showLoading();
      await _feedbackService.initialize();
      await _eventService.initialize();
      
      _feedbackList = _feedbackService.feedbacks;
      _events = _eventService.events;
      
      hideLoading();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      hideLoading();
      showError('Failed to load data: $e');
    }
  }

  /// Get feedback for the selected event and current user
  List<FeedbackModel> get _filteredFeedback {
    if (_userId == null) return [];
    return _feedbackList.where((f) => f.eventId == widget.selectedEvent.id && f.userId == _userId).toList();
  }

  /// Get event for a feedback item
  EventModel _getEventForFeedback(FeedbackModel feedback) {
    return widget.selectedEvent; // Always return the selected event
  }

  /// Add new feedback
  Future<void> _addFeedback() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Add Feedback'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FeedbackForm(
              event: widget.selectedEvent,
              onSubmit: _saveFeedback,
            ),
          ),
        ),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  /// Edit existing feedback
  Future<void> _editFeedback(FeedbackModel feedback) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Edit Feedback'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FeedbackForm(
              feedback: feedback,
              event: widget.selectedEvent,
              onSubmit: _updateFeedback,
            ),
          ),
        ),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  /// Delete feedback
  Future<void> _deleteFeedback(FeedbackModel feedback) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Feedback'),
        content: const Text('Are you sure you want to delete this feedback?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        showLoading();
        await _feedbackService.deleteFeedback(feedback.id);
        hideLoading();
        _loadData();
        showSuccess('Feedback deleted successfully');
      } catch (e) {
        hideLoading();
        showError('Failed to delete feedback: $e');
      }
    }
  }

  /// Save new feedback
  Future<void> _saveFeedback(FeedbackModel feedback) async {
    try {
      showLoading();
      await _feedbackService.addFeedback(feedback);
      hideLoading();
      Navigator.of(context).pop(true);
      showSuccess('Feedback added successfully');
    } catch (e) {
      hideLoading();
      showError('Failed to save feedback: $e');
    }
  }

  /// Update existing feedback
  Future<void> _updateFeedback(FeedbackModel feedback) async {
    try {
      showLoading();
      await _feedbackService.updateFeedback(feedback);
      hideLoading();
      Navigator.of(context).pop(true);
      showSuccess('Feedback updated successfully');
    } catch (e) {
      hideLoading();
      showError('Failed to update feedback: $e');
    }
  }

  /// Build statistics section
  Widget _buildStatistics() {
    final userFeedback = _filteredFeedback;
    final existingComments = widget.selectedEvent.existingComments;
    
    // Calculate total feedback count (existing + user)
    final totalFeedbackCount = existingComments.length + userFeedback.length;
    
    // Calculate total rating including existing comments
    double totalRating = 0.0;
    int totalRatings = 0;
    
    // Add existing comment ratings
    for (final comment in existingComments) {
      totalRating += (comment['rating'] as int).toDouble();
      totalRatings++;
    }
    
    // Add user feedback ratings
    for (final feedback in userFeedback) {
      totalRating += feedback.rating.toDouble();
      totalRatings++;
    }
    
    final averageRating = totalRatings > 0 ? totalRating / totalRatings : 0.0;
    final userFeedbackCount = userFeedback.length;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics for ${widget.selectedEvent.name}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.feedback,
                    label: 'Total Feedback',
                    value: totalFeedbackCount.toString(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.star,
                    label: 'Average Rating',
                    value: averageRating.toStringAsFixed(1),
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build a statistics item
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build add feedback prompt section
  Widget _buildAddFeedbackPrompt() {
    final hasUserFeedback = _filteredFeedback.isNotEmpty;
    
    if (hasUserFeedback) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.blue[700],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Feedback Submitted',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'You have already submitted feedback for this event. You can edit or delete your feedback below.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.add_circle,
                color: Colors.green[700],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Share Your Experience',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rate this event and share your thoughts! You can submit one feedback per event.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.green[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _addFeedback,
            icon: const Icon(Icons.star),
            label: const Text('Rate & Comment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Build existing comments section
  Widget _buildExistingCommentsSection() {
    return Column(
      children: [
        // Existing comments header
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.comment,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Existing Comments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'These are the predefined comments for this event. Add your own feedback below!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        // Existing comments list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.selectedEvent.existingComments.length,
          itemBuilder: (context, index) {
            final commentData = widget.selectedEvent.existingComments[index];
            final comment = commentData['comment'] as String;
            final title = commentData['title'] as String? ?? 'Feedback ${index + 1}'; // Fallback title
            final rating = commentData['rating'] as int;
            return ExistingCommentCard(
              comment: comment,
              title: title, // Pass title to the widget
              index: index,
              rating: rating,
            );
          },
        ),
      ],
    );
  }

  /// Build user feedback section
  Widget _buildUserFeedbackSection() {
    return Column(
      children: [
        // User feedback header
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.feedback,
                    color: Colors.green[700],
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Your Feedback',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'These are your submitted feedback for this event. You can edit or delete them.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        // User feedback list
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredFeedback.length,
          itemBuilder: (context, index) {
            final feedback = _filteredFeedback[index];
             
            return FeedbackCard(
              feedback: feedback,
              event: widget.selectedEvent,
              onEdit: () => _editFeedback(feedback),
              onDelete: () => _deleteFeedback(feedback),
            );
          },
        ),
      ],
    );
  }

  bool get _userParticipatedInEvent => _participatedEventIds.contains(widget.selectedEvent.id);

  @override
  Widget build(BuildContext context) {
    final hasUserFeedback = _filteredFeedback.isNotEmpty;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback - ${widget.selectedEvent.name}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: (!hasUserFeedback && _userParticipatedInEvent)
          ? FloatingActionButton.extended(
              onPressed: _addFeedback,
              icon: const Icon(Icons.add),
              label: const Text('Add Your Feedback'),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatistics(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Add feedback prompt section - only show if no user feedback and participated
                        if (!hasUserFeedback && _userParticipatedInEvent) _buildAddFeedbackPrompt(),
                        if (!hasUserFeedback && !_userParticipatedInEvent)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.grey[700]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'You can only add feedback for events you have participated in.',
                                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        // Existing comments section - always visible
                        _buildExistingCommentsSection(),
                        // User feedback section
                        if (hasUserFeedback) ...[
                          const SizedBox(height: 16),
                          _buildUserFeedbackSection(),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
} 