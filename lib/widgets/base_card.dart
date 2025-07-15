import 'package:flutter/material.dart';

/// Abstract base class for card widgets with common functionality
abstract class BaseCard extends StatelessWidget {
  const BaseCard({super.key});
}

/// Abstract base class for card state
abstract class BaseCardState<T extends BaseCard> {
  /// Build card with common styling
  Widget buildCard({
    required Widget child,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    double? elevation,
  }) {
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: elevation ?? 2,
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  /// Build text with common styling
  Widget buildText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Build icon with common styling
  Widget buildIcon(
    IconData icon, {
    double? size,
    Color? color,
    VoidCallback? onPressed,
  }) {
    if (onPressed != null) {
      return IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: size, color: color),
      );
    }
    return Icon(icon, size: size, color: color);
  }

  /// Build row with common styling
  Widget buildRow({
    required List<Widget> children,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
  }) {
    return Row(
      children: children,
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
    );
  }

  /// Build column with common styling
  Widget buildColumn({
    required List<Widget> children,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
  }) {
    return Column(
      children: children,
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
    );
  }

  /// Build popup menu button with common styling
  Widget buildPopupMenuButton<T>({
    required PopupMenuItemBuilder<T> itemBuilder,
    required PopupMenuItemSelected<T> onSelected,
    Widget? child,
    String? tooltip,
  }) {
    return PopupMenuButton<T>(
      onSelected: onSelected,
      itemBuilder: itemBuilder,
      tooltip: tooltip,
      child: child ?? const Icon(Icons.more_vert),
    );
  }

  /// Build popup menu item with common styling
  PopupMenuItem<T> buildPopupMenuItem<T>({
    required T value,
    required Widget child,
  }) {
    return PopupMenuItem<T>(
      value: value,
      child: child,
    );
  }

  /// Format date to relative time string
  String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  /// Build star rating widget
  Widget buildStarRating({
    required int rating,
    required int maxRating,
    double size = 20,
    Color? color,
    VoidCallback? onStarPressed,
  }) {
    return Row(
      children: List.generate(maxRating, (index) {
        return GestureDetector(
          onTap: onStarPressed != null ? () => onStarPressed() : null,
          child: Icon(
            index < rating ? Icons.star : Icons.star_border,
            color: color ?? Colors.amber,
            size: size,
          ),
        );
      }),
    );
  }
} 