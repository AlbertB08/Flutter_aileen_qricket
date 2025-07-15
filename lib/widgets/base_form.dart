import 'package:flutter/material.dart';

/// Abstract base class for forms with common functionality
abstract class BaseForm extends StatefulWidget {
  const BaseForm({super.key});
}

/// Abstract state class for forms
abstract class BaseFormState<T extends BaseForm> extends State<T> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  /// Get the form key
  GlobalKey<FormState> get formFormKey => formKey;

  /// Check if form is currently submitting
  bool get isSubmitting => _isSubmitting;

  /// Set submitting state
  set isSubmitting(bool value) {
    setState(() {
      _isSubmitting = value;
    });
  }

  /// Validate the form
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  /// Reset the form
  void resetForm() {
    formKey.currentState?.reset();
  }

  /// Show loading indicator
  void showLoading() {
    isSubmitting = true;
  }

  /// Hide loading indicator
  void hideLoading() {
    isSubmitting = false;
  }

  /// Show error message
  void showError(String message) {
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
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Build loading button
  Widget buildLoadingButton({
    required String text,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(text, style: const TextStyle(fontSize: 16)),
    );
  }

  /// Build text form field with common styling
  Widget buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        hintText: hintText,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
    );
  }

  /// Build card with common styling
  Widget buildCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );
  }
} 