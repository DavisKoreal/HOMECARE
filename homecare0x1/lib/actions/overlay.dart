import 'package:flutter/material.dart';

// Utility class to manage overlay notifications in the Flutter app.
class OverlayUtils {
  // Private variable to store the current overlay entry, nullable as it may not always exist.
  OverlayEntry? _overlayEntry;

  // Displays a temporary overlay notification with a message.
  // Parameters:
  // - context: The BuildContext required to access the Overlay widget.
  // - message: The text to display in the overlay.
  // - isError: Boolean flag to determine the overlay's appearance (red for errors, green for success).
  void showOverlay(BuildContext context, String message, {bool isError = false}) {
    // Remove any existing overlay before showing a new one to prevent stacking.
    _removeOverlay();

    // Create a new OverlayEntry with a positioned Material widget for the notification.
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // Position the overlay 50 pixels from the bottom and 20 pixels from the sides.
        bottom: 50,
        left: 20,
        right: 20,
        child: Material(
          // Add elevation for a shadow effect, giving a raised appearance.
          elevation: 8,
          // Apply rounded corners for a modern look.
          borderRadius: BorderRadius.circular(12),
          child: Container(
            // Add padding for content spacing.
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            // Set background color based on error status (red for errors, green for success).
            decoration: BoxDecoration(
              color: isError ? Colors.red : Colors.green[700],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Display an icon based on the error status (error or info).
                Icon(
                  isError ? Icons.error_outline : Icons.info_outline,
                  color: Colors.white,
                  size: 24,
                ),
                // Add spacing between the icon and text.
                const SizedBox(width: 12),
                // Expanded widget ensures the text takes available space and wraps if needed.
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Insert the overlay into the widget tree using the provided context.
    Overlay.of(context).insert(_overlayEntry!);

    // Automatically remove the overlay after 3 seconds.
    Future.delayed(const Duration(seconds: 3), _removeOverlay);
  }

  // Removes the current overlay from the screen, if it exists.
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Cleans up resources by removing any active overlay.
  // Should be called when the widget using this class is disposed.
  void dispose() {
    _removeOverlay();
  }
}