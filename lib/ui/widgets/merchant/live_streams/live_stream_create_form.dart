import 'dart:io';

import 'package:dak_louk/core/enums/media_type_enum.dart';
import 'package:dak_louk/core/media/media_picker_sheet.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/ui/widgets/merchant/merchant_app_bar.dart';
import 'package:flutter/material.dart';

class LiveStreamCreateForm extends StatefulWidget {
  const LiveStreamCreateForm({super.key});

  @override
  State<LiveStreamCreateForm> createState() => _LiveStreamCreateFormState();
}

class _LiveStreamCreateFormState extends State<LiveStreamCreateForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  String streamUrl = '';
  String? thumbnailUrl;

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (streamUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a video file')),
        );
        return;
      }

      final dto = CreateLiveStreamDTO(
        title: titleController.text,
        streamUrl: streamUrl,
        thumbnailUrl: thumbnailUrl,
      );

      Navigator.pop(context, dto);
    }
  }

  Future<void> _pickVideo() async {
    final path = await MediaPickerSheet.show(
      context,
      type: MediaType.video,
      folder: 'live_streams',
    );
    if (path != null) {
      setState(() => streamUrl = path);
    }
  }

  Future<void> _pickThumbnail() async {
    final path = await MediaPickerSheet.show(
      context,
      type: MediaType.image,
      folder: 'live_stream_thumbnails',
    );
    if (path != null) {
      setState(() => thumbnailUrl = path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MerchantAppBar(
        title: 'Create Live Stream',
        actions: [
          IconButton(onPressed: _handleSubmit, icon: const Icon(Icons.check)),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _pickVideo,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        streamUrl.isEmpty
                            ? Icons.video_file
                            : Icons.check_circle,
                        color: streamUrl.isEmpty ? Colors.grey : Colors.green,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          streamUrl.isEmpty
                              ? 'Tap to select video file'
                              : '${streamUrl.split('/').last}', // for vid file name
                          style: TextStyle(
                            color: streamUrl.isEmpty
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              InkWell(
                onTap: _pickThumbnail,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      thumbnailUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(thumbnailUrl!),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.image, color: Colors.grey),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          thumbnailUrl == null
                              ? 'Tap to select thumbnail (optional)'
                              : '${thumbnailUrl!.split('/').last}',
                          style: TextStyle(
                            color: thumbnailUrl == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
