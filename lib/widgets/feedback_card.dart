import 'package:flutter/material.dart';
import '../models/feedback_model.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import 'base_card.dart';

/// Card widget for displaying feedback
class FeedbackCard extends BaseCard {
  final FeedbackModel feedback;
  final EventModel event;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const FeedbackCard({
    super.key,
    required this.feedback,
    required this.event,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and actions
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Your Feedback',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onEdit != null || onDelete != null) ...[
                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 20),
                      tooltip: 'Edit your feedback',
                    ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      tooltip: 'Delete your feedback',
                    ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Event information
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Event ID: ${event.id}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Rating stars
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < feedback.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 20,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '${feedback.rating}/5',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'Comments:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              feedback.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Timestamp
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Submitted: ${_formatTimestamp(feedback.timestamp)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Event: ${event.category}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Format timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

/// Content widget for feedback card
class _FeedbackCardContent extends StatefulWidget {
  final FeedbackModel feedback;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FeedbackCardContent({
    required this.feedback,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_FeedbackCardContent> createState() => _FeedbackCardContentState();
}

class _FeedbackCardContentState extends State<_FeedbackCardContent> {
  final EventService _eventService = EventService();
  EventModel? _event;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  /// Load the associated event
  Future<void> _loadEvent() async {
    await _eventService.initialize();
    final event = _eventService.getEventById(widget.feedback.eventId);
    if (mounted) {
      setState(() {
        _event = event;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardState = _FeedbackCardState();

    return cardState.buildCard(
      child: cardState.buildColumn(
        children: [
          _buildHeader(cardState),
          const SizedBox(height: 8),
          if (_event != null) ...[
            _buildEventInfo(cardState),
            const SizedBox(height: 8),
          ],
          _buildDescription(cardState),
          const SizedBox(height: 12),
          _buildFooter(cardState),
        ],
      ),
    );
  }

  /// Build the header section with title and menu
  Widget _buildHeader(_FeedbackCardState cardState) {
    return cardState.buildRow(
      children: [
        Expanded(
          child: cardState.buildText(
            widget.feedback.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildPopupMenu(cardState),
      ],
    );
  }

  /// Build event information section
  Widget _buildEventInfo(_FeedbackCardState cardState) {
    if (_event == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: cardState.buildRow(
        children: [
          Icon(Icons.event, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(
            child: cardState.buildText(
              _event!.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.blue[700],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(12),
            ),
            child: cardState.buildText(
              _event!.category,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the description section
  Widget _buildDescription(_FeedbackCardState cardState) {
    return cardState.buildText(
      widget.feedback.description,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.grey,
      ),
    );
  }

  /// Build the footer section with rating and timestamp
  Widget _buildFooter(_FeedbackCardState cardState) {
    return cardState.buildRow(
      children: [
        // Timestamp
        cardState.buildText(
          cardState.formatRelativeTime(widget.feedback.timestamp),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  /// Build the popup menu
  Widget _buildPopupMenu(_FeedbackCardState cardState) {
    return cardState.buildPopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          widget.onEdit();
        } else if (value == 'delete') {
          widget.onDelete();
        }
      },
      itemBuilder: (context) => [
        cardState.buildPopupMenuItem(
          value: 'edit',
          child: const Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        cardState.buildPopupMenuItem(
          value: 'delete',
          child: const Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete'),
            ],
          ),
        ),
      ],
    );
  }
}

/// State class for feedback card
class _FeedbackCardState extends BaseCardState<FeedbackCard> {
  // This class provides the base card functionality
} 