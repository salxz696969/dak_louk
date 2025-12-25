import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';

Future<String?> thumbnailGenerator(String videoPath) async {
  final dir = await Directory.systemTemp.createTemp();

  return await VideoThumbnail.thumbnailFile(
    video: videoPath,
    thumbnailPath: dir.path,
    imageFormat: ImageFormat.JPEG,
    quality: 100,
    timeMs: 1000,
  );
}
