import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/chat_service.dart';
import 'package:dak_louk/ui/widgets/screens/user/chat/chat_input.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  final int chatRoomId;
  Chat({super.key, required this.chatRoomId});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  late TextEditingController _controller;
  late ScrollController _scrollController;
  final ChatService _chatService = ChatService();
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSend(String text) async {
    await _chatService.createChat(
      CreateChatDTO(chatRoomId: widget.chatRoomId, text: text),
    );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChatVM>>(
      future: _chatService.getChatsByChatRoomId(widget.chatRoomId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final chats = snapshot.data!;

        // Scroll to bottom when chat is opened or new data arrives
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 100.0,
                  top: 8.0,
                  left: 8.0,
                  right: 8.0,
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];

                    return Align(
                      alignment: chat.isMine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: chat.isMine
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.grey.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                chat.text,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                chat.createdAt.toLocal().toString().split(
                                  " ",
                                )[0],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            ChatInput(onSend: (text) => _handleSend(text)),
          ],
        );
      },
    );
  }
}
