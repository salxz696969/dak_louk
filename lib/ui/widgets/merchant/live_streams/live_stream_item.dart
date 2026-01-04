import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/ui/screens/fullscreen_video_screen.dart';
import 'package:flutter/material.dart';

class LiveStreamItem extends StatelessWidget {
  final MerchantLiveStreamsVM liveStream;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const LiveStreamItem({
    super.key,
    required this.liveStream,
    required this.onDelete,
    this.onEdit,
  });

  Future<void> _showDeleteDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Live Stream'),
        content: const Text(
          'Are you sure you want to delete this live stream?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result == true) {
      onDelete();
    }
  }

  void _openFullScreen(BuildContext context) async {
    final liveStreamVM = await Future.value(
      LiveStreamVM.fromRaw(
        LiveStreamModel(
          id: liveStream.id,
          merchantId: 0, // This will be set by the service
          title: liveStream.title,
          streamUrl: liveStream.streamUrl,
          thumbnailUrl: liveStream.thumbnailUrl,
          viewCount: liveStream.viewCount,
          createdAt: liveStream.createdAt,
          updatedAt: liveStream.updatedAt,
        ),
      ),
    );

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              FullScreenVideoScreen(livestream: Future.value(liveStreamVM)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(liveStream.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        await _showDeleteDialog(context);
        return false; // Don't dismiss automatically, handle in callback
      },
      child: InkWell(
        onTap: () => _openFullScreen(context),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  liveStream.thumbnailUrl ?? 'assets/images/placeholder.png',
                  width: 80,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(Icons.live_tv, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      liveStream.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${liveStream.viewCount} views',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // Action icons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: onEdit,
                    iconSize: 20,
                  ),
                  const Icon(
                    Icons.play_circle_outline,
                    color: Colors.grey,
                    size: 24,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
