import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final bool isMe;
  final String text;
  final DateTime timestamp;
  final bool isSeen; // New parameter for seen status
  const MessageBubble({
    super.key,
    required this.isMe,
    required this.text,
    required this.timestamp,
    this.isSeen = false, // Default to false
  });

  String _formatTimeToIST(DateTime dateTime) {
    // Convert to IST (UTC+5:30)
    final istDateTime = dateTime.toUtc().add(const Duration(hours: 5, minutes: 30));

    // Format time in 12-hour format with AM/PM
    final timeFormat = DateFormat('hh:mm a');
    return timeFormat.format(istDateTime);
  }

  String _formatDateTimeToIST(DateTime dateTime) {
    // Convert to IST (UTC+5:30)
    final istDateTime = dateTime.toUtc().add(const Duration(hours: 5, minutes: 30));

    final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(istDateTime.year, istDateTime.month, istDateTime.day);

    if (messageDate == today) {
      // Today - show only time
      return DateFormat('hh:mm a').format(istDateTime);
    } else if (messageDate == yesterday) {
      // Yesterday - show "Yesterday HH:mm AM/PM"
      return 'Yesterday ${DateFormat('hh:mm a').format(istDateTime)}';
    } else if (now.difference(istDateTime).inDays < 7) {
      // This week - show "Day HH:mm AM/PM"
      return DateFormat('EEE hh:mm a').format(istDateTime);
    } else {
      // Older - show full date
      return DateFormat('dd/MM/yy hh:mm a').format(istDateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = _formatDateTimeToIST(timestamp);
    final bg = isMe ? Theme.of(context).colorScheme.primary : Colors.grey.shade200;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = isMe
        ? const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
        bottomLeft: Radius.circular(12)
    )
        : const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(12)
    );

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2)
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: align,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    text,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                      fontSize: 14,
                    )
                ),
                const SizedBox(height: 6),
                Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          time,
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe ? Colors.white70 : Colors.black54,
                            fontWeight: FontWeight.w400,
                          )
                      ),
                      const SizedBox(width: 6),
                      if (isMe) Icon(
                          Icons.done_all,
                          size: 12,
                          color: // Blue when seen
                              isMe ? Colors.white70 : Colors.black54
                        // Change color based on seen status
                          // color: isSeen
                          //     ? Colors.lightBlue // Blue when seen
                          //     : (isMe ? Colors.white70 : Colors.black54) // Default color when not seen
                      ),
                    ]
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}