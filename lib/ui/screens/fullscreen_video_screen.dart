import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/ui/widgets/user/livestream/live_stream.dart';
import 'package:flutter/material.dart';

class FullScreenVideoScreen extends StatefulWidget {
  final Future<LiveStreamVM> livestream;

  const FullScreenVideoScreen({super.key, required this.livestream});

  @override
  State<FullScreenVideoScreen> createState() => _FullScreenVideoScreenState();
}

class _FullScreenVideoScreenState extends State<FullScreenVideoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<LiveStreamVM>(
        future: widget.livestream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return LiveStream(livestream: snapshot.data!);
        },
      ),
    );
  }
}
