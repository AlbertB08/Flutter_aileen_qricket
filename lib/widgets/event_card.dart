import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../models/feedback_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'base_card.dart';
import '../screens/ticket_purchase_screen.dart';

/// Card widget for displaying events
class EventCard extends BaseCard {
  final EventModel event;
  final List<FeedbackModel> feedbackList;
  final VoidCallback? onTap;
  final bool participated;
  final bool isBookmarked;
  final VoidCallback? onBookmark;
  final User? user;
  final VoidCallback? onRefresh; // Add refresh callback

  const EventCard({
    super.key,
    required this.event,
    required this.feedbackList,
    this.onTap,
    this.participated = false,
    this.isBookmarked = false,
    this.onBookmark,
    this.user,
    this.onRefresh, // Add refresh callback parameter
  });

  @override
  Widget build(BuildContext context) {
    final eventFeedback = feedbackList.where((f) => f.eventId == event.id).toList();
    final userFeedbackCount = eventFeedback.length;
    final existingCommentsCount = event.existingComments.length;
    final totalFeedbackCount = userFeedbackCount + existingCommentsCount;
    
    // Calculate average rating including existing comments
    double totalRating = 0.0;
    int totalRatings = 0;
    
    // Add existing comment ratings
    for (final comment in event.existingComments) {
      totalRating += (comment['rating'] as int).toDouble();
      totalRatings++;
    }
    
    // Add user feedback ratings
    for (final feedback in eventFeedback) {
      totalRating += feedback.rating.toDouble();
      totalRatings++;
    }
    
    final averageRating = totalRatings > 0 ? totalRating / totalRatings : 0.0;

    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 3,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event poster image
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildEventImage(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Header with title and category
                  Stack(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.name,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Event ID: ${event.id}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(event.category).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getCategoryIcon(event.category),
                                        size: 16,
                                        color: _getCategoryColor(event.category),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        event.category,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: _getCategoryColor(event.category),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                          tooltip: 'More options',
                          onSelected: (value) {
                            if (value == 'saved') {
                              onBookmark?.call();
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem<String>(
                              value: 'saved',
                              child: Row(
                                children: [
                                  Icon(
                                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                    color: isBookmarked ? Colors.orange : Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isBookmarked ? 'Remove from Saved' : 'Save Event',
                                    style: TextStyle(
                                      color: isBookmarked ? Colors.orange : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    event.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Event details
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        event.formattedDate,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        event.formattedTime,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${event.maxParticipants} max participants',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Rating statistics - only show for participated events that are past
                  if (participated && event.isPast) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 20,
                            color: Colors.amber[700],
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$totalFeedbackCount total feedback',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.amber[700],
                                ),
                              ),
                              if (userFeedbackCount > 0)
                                Text(
                                  '$userFeedbackCount user feedback',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.amber[600],
                                  ),
                                ),
                              if (totalRatings > 0)
                                Text(
                                  '${averageRating.toStringAsFixed(1)} avg rating',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.amber[600],
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          if (totalRatings > 0) ...[
                            ...List.generate(5, (index) {
                              return Icon(
                                index < averageRating.round() ? Icons.star : Icons.star_border,
                                color: Colors.amber[700],
                                size: 16,
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Event status
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(event).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(event),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getStatusColor(event),
                      ),
                    ),
                  ),
                  
                  // Buy Ticket Button for upcoming events
                  if (!event.isPast && !participated && user != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TicketPurchaseScreen(
                                event: event,
                                user: user!,
                              ),
                            ),
                          );
                          // Call refresh callback if purchase was successful
                          if (result == true && onRefresh != null) {
                            print('EventCard: Ticket purchase successful, calling refresh callback');
                            onRefresh!();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B388),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Buy Ticket',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (participated)
          Positioned(
            top: 8,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.85),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Participated',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Get color based on event category
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return Colors.blue;
      case 'entertainment':
        return Colors.purple;
      case 'business':
        return Colors.green;
      case 'education':
        return Colors.orange;
      case 'sports':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get icon based on event category
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return Icons.computer;
      case 'entertainment':
        return Icons.music_note;
      case 'business':
        return Icons.business;
      case 'education':
        return Icons.school;
      case 'sports':
        return Icons.sports_soccer;
      default:
        return Icons.event;
    }
  }

  /// Get status color based on event date
  Color _getStatusColor(EventModel event) {
    if (event.isPast) {
      return Colors.grey;
    } else if (event.isToday) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  /// Get status text based on event date
  String _getStatusText(EventModel event) {
    if (event.isPast) {
      return 'Past Event';
    } else if (event.isToday) {
      return 'Today';
    } else {
      return 'Upcoming';
    }
  }

  Widget _buildEventImage() {
    // Use thumbnail if available, else poster, else placeholder
    final String? imagePath = (event.thumbnail != null && event.thumbnail!.isNotEmpty)
        ? event.thumbnail
        : (event.poster != null && event.poster!.isNotEmpty)
            ? event.poster
            : null;

    if (imagePath != null) {
      if (imagePath.startsWith('http')) {
        return Image.network(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      } else {
        return Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      }
    } else {
      return _buildPlaceholder();
    }
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image, size: 60, color: Colors.white70),
      ),
    );
  }
} 