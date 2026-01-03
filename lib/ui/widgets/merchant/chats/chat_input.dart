import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/merchant/chat_service.dart';
import 'package:flutter/material.dart';

class ChatInput extends StatelessWidget {
  ChatInput({super.key, required this.onSend});

  final Function(String) onSend;

  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();

  void handleSend(String text) {
    onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 16,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Message...",
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => handleSend(_controller.text),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Icon(
                  Icons.send_rounded,
                  size: 24,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
