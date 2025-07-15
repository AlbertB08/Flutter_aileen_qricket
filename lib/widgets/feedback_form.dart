import 'package:flutter/material.dart';
import '../models/feedback_model.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';
import '../screens/event_selection_screen.dart';
import '../services/storage_service.dart';

/// Form widget for creating and editing feedback
class FeedbackForm extends StatefulWidget {
  final FeedbackModel? feedback;
  final EventModel event;
  final Function(FeedbackModel) onSubmit;

  const FeedbackForm({
    super.key,
    this.feedback,
    required this.event,
    required this.onSubmit,
  });

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _rating = 5;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  /// Initialize form with existing feedback data if editing
  void _initializeForm() {
    if (widget.feedback != null) {
      _titleController.text = widget.feedback!.title;
      _descriptionController.text = widget.feedback!.description;
      _rating = widget.feedback!.rating;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Handle form submission
  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final userId = await SharedPreferencesStorageService.getOrCreateUserId();
      final newFeedback = widget.feedback != null
          ? widget.feedback!.copyWith(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              rating: _rating,
              userId: userId,
            )
          : FeedbackModel.create(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              eventId: widget.event.id,
              rating: _rating,
              userId: userId,
            );
      widget.onSubmit(newFeedback);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Event information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.feedback != null ? 'Editing Your Feedback for:' : 'Adding Your Feedback for:',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.event.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Category: ${widget.event.category}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Date: ${widget.event.formattedDate} at ${widget.event.formattedTime}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Your Feedback Title',
                border: OutlineInputBorder(),
                hintText: 'Give your feedback a descriptive title',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title for your feedback';
                }
                if (value.trim().length < 3) {
                  return 'Title must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Rating stars
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Rate Your Experience:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the stars to rate this event from 1 to 5',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        '$_rating out of 5 stars',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Your Comments & Feedback',
                border: OutlineInputBorder(),
                hintText: 'Share your detailed thoughts, suggestions, or experience about this event...',
                prefixIcon: Icon(Icons.comment),
                alignLabelWithHint: true,
              ),
              maxLines: null,
              minLines: 4,
              expands: false,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please share your comments and feedback';
                }
                if (value.trim().length < 10) {
                  return 'Please provide at least 10 characters of feedback';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Submit button
            ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.feedback != null ? 'Update Your Feedback' : 'Submit Your Feedback',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 