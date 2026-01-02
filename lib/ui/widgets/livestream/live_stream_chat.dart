import 'dart:async';

import 'package:dak_louk/domain/models/models.dart';
import 'package:flutter/material.dart';

class LiveStreamChat extends StatefulWidget {
  final List<LiveStreamChatVM> liveStreamChats;

  const LiveStreamChat({required this.liveStreamChats});

  @override
  State<LiveStreamChat> createState() => _LiveStreamChatState();
}

class _LiveStreamChatState extends State<LiveStreamChat> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final List<LiveStreamChatVM> _visibleChats = [];

  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    if (widget.liveStreamChats.isNotEmpty) {
      _startStreaming();
    }
  }

  void _startStreaming() {
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (_index >= widget.liveStreamChats.length) {
        timer.cancel();
        return;
      }

      _visibleChats.insert(0, widget.liveStreamChats[_index]);
      _listKey.currentState?.insertItem(
        0,
        duration: const Duration(milliseconds: 600),
      );

      _index++;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      height: 400,
      child: AnimatedList(
        key: _listKey,
        reverse: true,
        initialItemCount: _visibleChats.length,
        itemBuilder: (context, index, animation) {
          final chat = _visibleChats[index];

          return SizeTransition(
            sizeFactor: animation,
            axisAlignment: 1.0,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${chat.username}: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                    TextSpan(
                      text: chat.text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
