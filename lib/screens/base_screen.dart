import 'package:flutter/material.dart';

/// Abstract base class for screens with common functionality
abstract class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});
}

/// Abstract state class for screens
abstract class BaseScreenState<T extends BaseScreen> extends State<T> {
  bool _isLoading = false;
  String? _errorMessage;

  /// Check if screen is loading
  bool get isLoading => _isLoading;

  /// Get current error message
  String? get errorMessage => _errorMessage;

  /// Set loading state
  set isLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  /// Set error message
  set errorMessage(String? value) {
    setState(() {
      _errorMessage = value;
    });
  }

  /// Show loading indicator
  void showLoading() {
    isLoading = true;
    errorMessage = null;
  }

  /// Hide loading indicator
  void hideLoading() {
    isLoading = false;
  }

  /// Show error message
  void showError(String message) {
    errorMessage = message;
    hideLoading();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Show success message
  void showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Show confirmation dialog
  Future<bool> showConfirmationDialog({
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: confirmColor ?? Colors.red,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Build loading widget
  Widget buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  /// Build error widget
  Widget buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build empty state widget
  Widget buildEmptyStateWidget({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// Build app bar with common styling
  PreferredSizeWidget buildAppBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
  }) {
    return AppBar(
      title: Text(title),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  /// Build floating action button with common styling
  Widget? buildFloatingActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    String? tooltip,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: Icon(icon),
    );
  }

  /// Handle async operation with loading and error handling
  Future<void> handleAsyncOperation(
    Future<void> Function() operation, {
    String? errorMessage,
  }) async {
    try {
      showLoading();
      await operation();
      hideLoading();
    } catch (e) {
      showError(errorMessage ?? 'An error occurred: $e');
    }
  }
} 