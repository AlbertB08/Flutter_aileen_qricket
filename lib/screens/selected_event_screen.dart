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
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'ticket_purchase_screen.dart';
import '../models/invoice_model.dart';
import '../services/invoice_service.dart';

class SelectedEventScreen extends BaseScreen {
  final EventModel selectedEvent;

  const SelectedEventScreen({
    super.key,
    required this.selectedEvent,
  });

  @override
  State<SelectedEventScreen> createState() => _SelectedEventScreenState();
}

class _SelectedEventScreenState extends BaseScreenState<SelectedEventScreen> with SingleTickerProviderStateMixin {
  final FeedbackService _feedbackService = FeedbackService();
  final EventService _eventService = EventService();
  List<FeedbackModel> _feedbackList = [];
  List<EventModel> _events = [];
  bool _isLoading = true;
  String? _userId;
  User? _currentUser;
  late TabController _tabController;
  bool _isEventSaved = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initUserAndLoadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initUserAndLoadData() async {
    _userId = await SharedPreferencesStorageService.getOrCreateUserId();
    _currentUser = AuthService.currentUser;
    await _loadData();
    _checkIfEventSaved();
  }

  void _checkIfEventSaved() {
    if (_currentUser != null) {
      setState(() {
        _isEventSaved = _currentUser!.bookmarkedEventIds.contains(widget.selectedEvent.id);
      });
    }
  }

  Future<void> _buyTicket() async {
    if (_currentUser == null) return;
    
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TicketPurchaseScreen(
          event: widget.selectedEvent,
          user: _currentUser!,
        ),
      ),
    );
    
    // Refresh user data after returning from ticket purchase
    if (result == true) {
      // Purchase was successful, refresh user data
      _currentUser = AuthService.currentUser;
      setState(() {});
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ticket purchased successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _toggleSaveEvent() async {
    if (_currentUser == null) return;
    
    final updatedBookmarks = List<String>.from(_currentUser!.bookmarkedEventIds);
    if (_isEventSaved) {
      updatedBookmarks.remove(widget.selectedEvent.id);
    } else {
      updatedBookmarks.add(widget.selectedEvent.id);
    }
    
    final updatedUser = _currentUser!.copyWith(bookmarkedEventIds: updatedBookmarks);
    await AuthService.updateCurrentUser(updatedUser);
    
    setState(() {
      _currentUser = updatedUser;
      _isEventSaved = !_isEventSaved;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEventSaved ? 'Event saved!' : 'Event removed from saved'),
        backgroundColor: _isEventSaved ? Colors.green : Colors.orange,
      ),
    );
  }

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

  List<FeedbackModel> get _filteredFeedback {
    if (_userId == null) return [];
    return _feedbackList.where((f) => f.eventId == widget.selectedEvent.id && f.userId == _userId).toList();
  }

  bool get _userParticipatedInEvent => _currentUser?.participatedEventIds.contains(widget.selectedEvent.id) ?? false;

  @override
  Widget build(BuildContext context) {
    final hasUserFeedback = _filteredFeedback.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectedEvent.name),
        backgroundColor: const Color(0xFF00B388),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Top: Event image, summary, and action buttons
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      // Grayscale thumbnail background (full cover)
                      if (widget.selectedEvent.thumbnail != null && widget.selectedEvent.thumbnail!.isNotEmpty)
                        Positioned.fill(
                          child: ColorFiltered(
                            colorFilter: const ColorFilter.matrix([
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0, 0, 0, 1, 0,
                            ]),
                            child: widget.selectedEvent.thumbnail!.startsWith('http')
                                ? Image.network(
                                    widget.selectedEvent.thumbnail!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  )
                                : Image.asset(
                                    widget.selectedEvent.thumbnail!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                          ),
                        ),
                      // Black overlay for readability
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.45),
                        ),
                      ),
                      // Foreground content centered vertically
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                                // Poster image with white border
                                if (widget.selectedEvent.poster != null && widget.selectedEvent.poster!.isNotEmpty)
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white, width: 4),
                                    ),
                                    child: _buildEventImage(),
                                  )
                                else if (widget.selectedEvent.thumbnail != null && widget.selectedEvent.thumbnail!.isNotEmpty)
                                  _buildEventImage()
                                else
                      Container(
                        width: 120,
                                    height: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                        ),
                        child: const Center(
                          child: Text(
                            'PLACEHOLDER',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Event summary/info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.selectedEvent.name,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                                      Text('Event ID: ${widget.selectedEvent.id}', style: TextStyle(fontSize: 10, color: Colors.grey[300])),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.selectedEvent.category,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blue),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.selectedEvent.description,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[200]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                          Icon(Icons.calendar_today, size: 16, color: Colors.grey[200]),
                                const SizedBox(width: 4),
                                          Text(widget.selectedEvent.formattedDate, style: TextStyle(fontSize: 14, color: Colors.grey[200])),
                                const SizedBox(width: 16),
                                          Icon(Icons.access_time, size: 16, color: Colors.grey[200]),
                                const SizedBox(width: 4),
                                          Text(widget.selectedEvent.formattedTime, style: TextStyle(fontSize: 14, color: Colors.grey[200])),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                          Icon(Icons.location_on, size: 16, color: Colors.grey[200]),
                                const SizedBox(width: 4),
                                Expanded(
                                            child: Text(widget.selectedEvent.location, style: TextStyle(fontSize: 14, color: Colors.grey[200]), overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                          Icon(Icons.people, size: 16, color: Colors.grey[200]),
                                const SizedBox(width: 4),
                                          Text('${widget.selectedEvent.maxParticipants} max participants', style: TextStyle(fontSize: 14, color: Colors.grey[200])),
                              ],
                            ),
                          ],
                        ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Action Buttons (Buy Ticket, Save Event)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: [
                                // Buy Ticket Button
                                if (!widget.selectedEvent.isPast && !_userParticipatedInEvent && _currentUser != null)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _buyTicket(),
                                      icon: const Icon(Icons.confirmation_number),
                                      label: const Text('Buy Ticket'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF00B388),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (!widget.selectedEvent.isPast && !_userParticipatedInEvent && _currentUser != null)
                                  const SizedBox(width: 12),
                                // Save Event Button
                                if (_currentUser != null)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () => _toggleSaveEvent(),
                                      icon: Icon(
                                        _isEventSaved ? Icons.bookmark : Icons.bookmark_border,
                                        color: _isEventSaved ? Colors.orange : Colors.grey[700],
                                      ),
                                      label: Text(
                                        _isEventSaved ? 'Saved' : 'Save Event',
                                        style: TextStyle(
                                          color: _isEventSaved ? Colors.orange : Colors.grey[700],
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[100],
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Tabs
                Container(
                  color: const Color(0xFF006400),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: const [
                      Tab(text: 'EVENT INFO'),
                      Tab(text: 'NEWS'),
                    ],
                  ),
                ),
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // EVENT INFO TAB
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            // Render eventInfo sections above comments/feedback
                            ...widget.selectedEvent.eventInfo.map((info) => _buildEventInfoSection(info)).toList(),
                            // Only show statistics for participated events
                            if (_userParticipatedInEvent && widget.selectedEvent.isPast) _buildStatistics(),
                            // Only show feedback sections if user participated in the event AND event is past
                            if (_userParticipatedInEvent && widget.selectedEvent.isPast) ...[
                            // Add feedback prompt section - only show if no user feedback and participated
                              if (!hasUserFeedback) _buildAddFeedbackPrompt(),
                              // Existing comments section - only visible for participated events
                              _buildExistingCommentsSection(),
                              // User feedback section - only visible for participated events
                              if (hasUserFeedback) ...[
                                const SizedBox(height: 16),
                                _buildUserFeedbackSection(),
                              ],
                            ] else if (_userParticipatedInEvent && !widget.selectedEvent.isPast) ...[
                              // Show message for participated but upcoming events
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.schedule, color: Colors.blue[700]),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Feedback will be available after the event ends.',
                                          style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              // Show message for non-participated events
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.orange[700]),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'You can only view and add feedback for events you have participated in.',
                                          style: TextStyle(fontSize: 14, color: Colors.orange[700]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // NEWS TAB
                      _buildNewsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNewsTab() {
    final newsList = widget.selectedEvent.news;
    if (newsList.isEmpty) {
      return const Center(child: Text('No news available for this event.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: newsList.length,
      itemBuilder: (context, index) {
        final news = newsList[index];
        return _FacebookStyleNewsCard(news: news);
      },
    );
  }

  Widget _buildStatistics() {
    final userFeedback = _filteredFeedback;
    final existingComments = widget.selectedEvent.existingComments;
    final totalFeedbackCount = existingComments.length + userFeedback.length;
    double totalRating = 0.0;
    int totalRatings = 0;
    for (final comment in existingComments) {
      totalRating += (comment['rating'] as int).toDouble();
      totalRatings++;
    }
    for (final feedback in userFeedback) {
      totalRating += feedback.rating.toDouble();
      totalRatings++;
    }
    final averageRating = totalRatings > 0 ? totalRating / totalRatings : 0.0;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Removed statistics title
            const SizedBox(height: 0),
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

  Widget _buildStatItem({required IconData icon, required String label, required String value, required Color color}) {
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
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: color), textAlign: TextAlign.center),
        ],
      ),
    );
  }

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
                Icon(Icons.check_circle, color: Colors.blue[700], size: 24),
                const SizedBox(width: 8),
                Text('Feedback Submitted', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[700])),
              ],
            ),
            const SizedBox(height: 8),
            Text('You have already submitted feedback for this event. You can edit or delete your feedback below.', style: TextStyle(fontSize: 14, color: Colors.blue[600]), textAlign: TextAlign.center),
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
              Icon(Icons.add_circle, color: Colors.green[700], size: 24),
              const SizedBox(width: 8),
              Text('Share Your Experience', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700])),
            ],
          ),
          const SizedBox(height: 8),
          Text('Rate this event and share your thoughts! You can submit one feedback per event.', style: TextStyle(fontSize: 14, color: Colors.green[600]), textAlign: TextAlign.center),
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

  void _addFeedback() async {
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

  Widget _buildExistingCommentsSection() {
    return Column(
      children: [
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
                  Icon(Icons.comment, color: Colors.blue[700], size: 24),
                  const SizedBox(width: 8),
                  Text('Existing Comments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[700])),
                ],
              ),
              const SizedBox(height: 8),
              Text('These are the predefined comments for this event. Add your own feedback below!', style: TextStyle(fontSize: 14, color: Colors.blue[600]), textAlign: TextAlign.center),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.selectedEvent.existingComments.length,
          itemBuilder: (context, index) {
            final commentData = widget.selectedEvent.existingComments[index];
            final comment = commentData['comment'] as String;
            final title = commentData['title'] as String? ?? 'Feedback  [38;5;9m${index + 1} [0m';
            final rating = commentData['rating'] as int;
            return ExistingCommentCard(
              comment: comment,
              title: title,
              index: index,
              rating: rating,
            );
          },
        ),
      ],
    );
  }

  Widget _buildUserFeedbackSection() {
    return Column(
      children: [
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
                  Icon(Icons.feedback, color: Colors.green[700], size: 24),
                  const SizedBox(width: 8),
                  Text('Your Feedback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[700])),
                ],
              ),
              const SizedBox(height: 8),
              Text('These are your submitted feedback for this event. You can edit or delete them.', style: TextStyle(fontSize: 14, color: Colors.green[600]), textAlign: TextAlign.center),
            ],
          ),
        ),
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

  void _editFeedback(FeedbackModel feedback) async {
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

  void _deleteFeedback(FeedbackModel feedback) async {
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

  Widget _buildEventInfoSection(EventInfoSection info) {
    switch (info.layout) {
      case 'image-left':
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 9,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _buildFlexibleImage(info.details['image'], fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 11,
                child: Text(
                  info.details['text'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        );
      case 'image-right':
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 11,
                child: Text(
                  info.details['text'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 9,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _buildFlexibleImage(info.details['image'], fit: BoxFit.cover),
                ),
              ),
            ],
          ),
        );
      case 'image-top':
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildFlexibleImage(info.details['image'], width: double.infinity, height: 160, fit: BoxFit.cover),
              const SizedBox(height: 12),
              Text(
                info.details['text'] ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      case 'carousel-only':
        final List images = info.details['images'] ?? [];
        final PageController _carouselController = PageController();
        int _carouselIndex = 0;
        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  child: PageView.builder(
                    controller: _carouselController,
                    itemCount: images.length,
                    onPageChanged: (index) => setState(() => _carouselIndex = index),
                    itemBuilder: (context, index) {
                      return _buildFlexibleImage(images[index], width: double.infinity, height: 180, fit: BoxFit.cover);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _carouselIndex == index ? Colors.blueAccent : Colors.grey[400],
                    ),
                  )),
                ),
              ],
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFlexibleImage(String? imagePath, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, color: Colors.white70),
      );
    }
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.white70),
        ),
      );
    } else {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.white70),
        ),
      );
    }
  }

  Widget _buildEventImage() {
    if (widget.selectedEvent.poster != null && widget.selectedEvent.poster!.isNotEmpty) {
      // Prioritize poster for event detail view
      if (widget.selectedEvent.poster!.startsWith('http')) {
        return Image.network(
          widget.selectedEvent.poster!,
          width: 120,
          height: 150,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 120,
              height: 150,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            width: 120,
            height: 150,
            color: Colors.grey[300],
            child: const Center(
              child: Text(
                'PLACEHOLDER',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      } else {
        return Image.asset(
          widget.selectedEvent.poster!,
          width: 120,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 120,
            height: 150,
            color: Colors.grey[300],
            child: const Center(
              child: Text(
                'PLACEHOLDER',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }
    } else if (widget.selectedEvent.thumbnail != null && widget.selectedEvent.thumbnail!.isNotEmpty) {
      // Fallback to thumbnail if poster is not available
      if (widget.selectedEvent.thumbnail!.startsWith('http')) {
        return Image.network(
          widget.selectedEvent.thumbnail!,
          width: 120,
          height: 150,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 120,
              height: 150,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            width: 120,
            height: 150,
            color: Colors.grey[300],
            child: const Center(
              child: Text(
                'PLACEHOLDER',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      } else {
        return Image.asset(
          widget.selectedEvent.thumbnail!,
          width: 120,
          height: 150,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 120,
            height: 150,
            color: Colors.grey[300],
            child: const Center(
              child: Text(
                'PLACEHOLDER',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }
    } else {
      return Container(
        width: 120,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'PLACEHOLDER',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }
}

class _FacebookStyleNewsCard extends StatefulWidget {
  final dynamic news;
  const _FacebookStyleNewsCard({Key? key, required this.news}) : super(key: key);

  @override
  State<_FacebookStyleNewsCard> createState() => _FacebookStyleNewsCardState();
}

class _FacebookStyleNewsCardState extends State<_FacebookStyleNewsCard> {
  bool _expanded = false;
  static const int maxLength = 180;

  @override
  Widget build(BuildContext context) {
    final isLong = widget.news.message.length > maxLength;
    final displayText = !_expanded && isLong
        ? widget.news.message.substring(0, maxLength) + '...'
        : widget.news.message;
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.news.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '${widget.news.date.day}/${widget.news.date.month}/${widget.news.date.year}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  displayText,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (isLong && !_expanded)
                  TextButton(
                    onPressed: () => setState(() => _expanded = true),
                    child: const Text('View more'),
                  ),
                if (isLong && _expanded)
                  TextButton(
                    onPressed: () => setState(() => _expanded = false),
                    child: const Text('Show less'),
                  ),
              ],
            ),
          ),
          // Image at the bottom
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            child: widget.news.image.isNotEmpty
                ? _buildNewsImage(widget.news.image)
                : Container(
                    width: double.infinity,
                    height: 180,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 60, color: Colors.white70),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsImage(String imagePath) {
    // Check if it's a network URL or local asset
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: double.infinity,
                      height: 180,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 60, color: Colors.white70),
                    ),
      );
    } else {
      return Image.asset(
        imagePath,
        width: double.infinity,
        height: 180,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 180,
                    color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 60, color: Colors.white70),
      ),
    );
    }
  }
} 