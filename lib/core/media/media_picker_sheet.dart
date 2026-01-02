import 'package:dak_louk/core/enums/media_type_enum.dart';
import 'package:dak_louk/core/media/media_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MediaPickerSheet {
  static Future<String?> show(
    BuildContext context, {
    MediaType type = MediaType.image,
    String folder = 'media',
  }) async {
    return await showModalBottomSheet<String>(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(
                  type == MediaType.image ? 'Pick Image' : 'Pick Video',
                ),
                onTap: () async {
                  Navigator.pop(
                    context,
                    await MediaPicker.pickAndStoreMedia(
                      type: type,
                      source: ImageSource.gallery,
                      folder: folder,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(
                  type == MediaType.image ? 'Take Photo' : 'Record Video',
                ),
                onTap: () async {
                  // attempted to make the simulator not crash when opening camera, but it still crash even with graceful handlong so it is what it is
                  try {
                    final result = await MediaPicker.pickAndStoreMedia(
                      type: type,
                      source: ImageSource.camera,
                      folder: folder,
                    );

                    if (!context.mounted) return;

                    Navigator.pop<String?>(context, result);
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to pick media')),
                    );

                    Navigator.pop<String?>(context, null);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
