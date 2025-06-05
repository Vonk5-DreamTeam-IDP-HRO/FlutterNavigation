import 'package:flutter/material.dart';

/// Utility class for displaying consistent feedback messages across the application.
/// 
/// Provides standardized methods for showing error and success messages using SnackBar.
/// This centralization ensures consistent styling and behavior for all user feedback.
class FeedbackUtil {
  /// Shows an error message using a SnackBar with error styling
  ///
  /// @param context The BuildContext to show the SnackBar
  /// @param message The error message to display
  /// @param duration Optional duration to show the message (defaults to 4 seconds)
  static void showErrorSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: duration,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Shows a success message using a SnackBar with success styling
  ///
  /// @param context The BuildContext to show the SnackBar
  /// @param message The success message to display
  /// @param duration Optional duration to show the message (defaults to 3 seconds)
  /// @param actionLabel Optional label for the action button (defaults to 'OK')
  /// @param onActionPressed Optional callback for when the action button is pressed
  static void showSuccessSnackbar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    String actionLabel = 'OK',
    VoidCallback? onActionPressed,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: duration,
        action: SnackBarAction(
          label: actionLabel,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            onActionPressed?.call();
          },
        ),
      ),
    );
  }
}
