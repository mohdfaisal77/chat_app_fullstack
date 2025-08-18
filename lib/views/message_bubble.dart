import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageBubble extends StatelessWidget {
  final bool isMe;
  final String text;
  final DateTime timestamp;
  const MessageBubble({super.key, required this.isMe, required this.text, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('hh:mm a').format(timestamp);
    final bg = isMe ? Theme.of(context).colorScheme.primary : Colors.grey.shade200;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = isMe
        ? const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomLeft: Radius.circular(12))
        : const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12), bottomRight: Radius.circular(12));

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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: align,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(text, style: TextStyle(color: isMe ? Colors.white : Colors.black87)),
                const SizedBox(height: 6),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(time, style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.black54)),
                  const SizedBox(width: 6),
                  if (isMe) const Icon(Icons.done_all, size: 12, color: Colors.white70),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
