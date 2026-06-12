import 'package:flutter/material.dart';

import '../models/chat_model.dart';

Widget chatMessageBubble(
  BuildContext context,
  ChatMessageModel msg,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Align(
    alignment: msg.isMe
        ? Alignment.centerRight
        : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: msg.isMe
            ? Colors.teal
            : (isDark
                ? Colors.grey.shade800
                : Colors.white),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(
            msg.isMe ? 16 : 0,
          ),
          bottomRight: Radius.circular(
            msg.isMe ? 0 : 16,
          ),
        ),
        border: msg.isMe
            ? null
            : Border.all(
                color: isDark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
              ),
      ),
      child: Column(
        crossAxisAlignment: msg.isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            msg.text,
            style: TextStyle(
              color: msg.isMe
                  ? Colors.white
                  : (isDark
                      ? Colors.white
                      : Colors.black87),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            msg.timeDisplay,
            style: TextStyle(
              fontSize: 10,
              color: msg.isMe
                  ? Colors.teal.shade100
                  : (isDark
                      ? Colors.grey.shade400
                      : Colors.grey),
            ),
          ),
        ],
      ),
    ),
  );
}
