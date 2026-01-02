import 'dart:io';
import 'package:dak_louk/core/enums/media_type_enum.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class MediaPicker {
  static final ImagePicker _picker = ImagePicker();

  /// Core method
  static Future<String?> pickAndStoreMedia({
    required MediaType type,
    required ImageSource source,
    String folder = 'media',
    int imageQuality = 85,
  }) async {
    XFile? picked;

    if (type == MediaType.image) {
      picked = await _picker.pickImage(
        source: source,
        imageQuality: imageQuality,
      );
    } else {
      picked = await _picker.pickVideo(source: source);
    }

    if (picked == null) return null;

    final Directory appDir = await getApplicationDocumentsDirectory();
    final String targetDir = p.join(appDir.path, folder);

    await Directory(targetDir).create(recursive: true);

    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';

    final String newPath = p.join(targetDir, fileName);

    final File savedFile = await File(picked.path).copy(newPath);

    return savedFile.path;
  }
}
