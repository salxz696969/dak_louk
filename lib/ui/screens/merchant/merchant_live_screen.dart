import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/domain/services/merchant/live_stream_service.dart';
import 'package:dak_louk/ui/widgets/merchant/live_streams/live_stream_create_form.dart';
import 'package:dak_louk/ui/widgets/merchant/live_streams/live_stream_edit_form.dart';
import 'package:dak_louk/ui/widgets/merchant/live_streams/live_stream_item.dart';
import 'package:flutter/material.dart';

class MerchantLiveScreen extends StatefulWidget {
  const MerchantLiveScreen({super.key});

  @override
  State<MerchantLiveScreen> createState() => _MerchantLiveScreenState();
}

class _MerchantLiveScreenState extends State<MerchantLiveScreen> {
  final LiveStreamService _liveStreamService = LiveStreamService();
  late Future<List<MerchantLiveStreamsVM>> _liveStreamsFuture;

  @override
  void initState() {
    super.initState();
    _loadLiveStreams();
  }

  void _loadLiveStreams() {
    setState(() {
      _liveStreamsFuture = _liveStreamService.getAllLiveStreams();
    });
  }

  Future<void> _handleCreate() async {
    final result = await Navigator.push<CreateLiveStreamDTO>(
      context,
      MaterialPageRoute(builder: (context) => const LiveStreamCreateForm()),
    );

    if (result != null) {
      try {
        await _liveStreamService.createLiveStream(result);
        _loadLiveStreams();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Live stream created successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create live stream: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleEdit(MerchantLiveStreamsVM liveStream) async {
    final result = await Navigator.push<UpdateLiveStreamDTO>(
      context,
      MaterialPageRoute(
        builder: (context) => LiveStreamEditForm(liveStream: liveStream),
      ),
    );

    if (result != null) {
      try {
        await _liveStreamService.updateLiveStream(liveStream.id, result);
        _loadLiveStreams();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Live stream updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update live stream: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleDelete(int id) async {
    try {
      await _liveStreamService.deleteLiveStream(id);
      _loadLiveStreams();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Live stream deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete live stream: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // for bottom right floating button
      floatingActionButton: FloatingActionButton(
        onPressed: _handleCreate,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<MerchantLiveStreamsVM>>(
        future: _liveStreamsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final liveStreams = snapshot.data ?? [];

          if (liveStreams.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.live_tv_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No live streams yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first live stream',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80), // Space for FAB
            itemCount: liveStreams.length,
            itemBuilder: (context, index) {
              final liveStream = liveStreams[index];
              return LiveStreamItem(
                liveStream: liveStream,
                onEdit: () => _handleEdit(liveStream),
                onDelete: () => _handleDelete(liveStream.id),
              );
            },
          );
        },
      ),
    );
  }
}
