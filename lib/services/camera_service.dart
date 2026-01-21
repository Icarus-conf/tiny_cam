import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera_macos/camera_macos.dart';
import 'package:fc_native_video_thumbnail/fc_native_video_thumbnail.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'filter_service.dart';

class CameraService {
  final _thumbnailPlugin = FcNativeVideoThumbnail();
  Future<String?> takePictureAndSave(
    CameraMacOSController controller, {
    FilterType filter = FilterType.none,
  }) async {
    try {
      // Capture photo
      CameraMacOSFile? file = await controller.takePicture();
      if (file == null || file.bytes == null) return null;

      // Get Downloads directory
      final downloadsDirectory = await getDownloadsDirectory();
      if (downloadsDirectory == null) throw Exception('Could not access Downloads directory');

      final directory = Directory('${downloadsDirectory.path}/MyCameraAppImages');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${directory.path}/photo_$timestamp.png';
      final savedFile = File(path);

      // Apply Filter if needed
      if (filter != FilterType.none) {
        img.Image? image = img.decodeImage(file.bytes!);
        if (image != null) {
          image = FilterService.applyFilter(image, filter);
          await savedFile.writeAsBytes(img.encodePng(image));
          return path;
        }
      }

      // Save raw bytes if no filter or decode failed
      await savedFile.writeAsBytes(file.bytes!);

      return path;
    } catch (e) {
      log('Error saving picture: $e');
      return null;
    }
  }

  Future<List<File>> getCapturedImages() async {
    try {
      final downloadsDirectory = await getDownloadsDirectory();
      if (downloadsDirectory == null) return [];

      final directory = Directory('${downloadsDirectory.path}/MyCameraAppImages');
      if (!await directory.exists()) {
        return [];
      }

      final files = directory.listSync().whereType<File>().where((file) {
        return file.path.split('/').last.startsWith('photo_') && file.path.endsWith('.png');
      }).toList();

      // Sort by creation time (newest first)
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      return files;
    } catch (e) {
      log('Error listing images: $e');
      return [];
    }
  }

  Future<String?> saveVideo(CameraMacOSFile file) async {
    try {
      if (file.bytes == null) return null;

      // Get Downloads directory
      final downloadsDirectory = await getDownloadsDirectory();
      if (downloadsDirectory == null) throw Exception('Could not access Downloads directory');

      final directory = Directory('${downloadsDirectory.path}/MyCameraAppVideos');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${directory.path}/video_$timestamp.mp4';
      final savedFile = File(path);

      await savedFile.writeAsBytes(file.bytes!);

      return path;
    } catch (e) {
      log('Error saving video: $e');
      return null;
    }
  }

  Future<List<File>> getCapturedVideos() async {
    try {
      final downloadsDirectory = await getDownloadsDirectory();
      if (downloadsDirectory == null) return [];

      final directory = Directory('${downloadsDirectory.path}/MyCameraAppVideos');
      if (!await directory.exists()) {
        return [];
      }

      final files = directory.listSync().whereType<File>().where((file) {
        return file.path.split('/').last.startsWith('video_') && file.path.endsWith('.mp4');
      }).toList();

      // Sort by creation time (newest first)
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      return files;
    } catch (e) {
      log('Error listing videos: $e');
      return [];
    }
  }

  Future<List<File>> getAllMedia() async {
    final images = await getCapturedImages();
    final videos = await getCapturedVideos();
    final all = [...images, ...videos];
    all.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return all;
  }

  Future<String?> getVideoThumbnail(String videoPath) async {
    try {
      final file = File(videoPath);
      if (!await file.exists()) {
        log('Video file does not exist: $videoPath');
        return null;
      }

      final appSupportDir = await getApplicationSupportDirectory();
      final thumbDir = Directory('${appSupportDir.path}/thumbnails');
      if (!await thumbDir.exists()) {
        await thumbDir.create(recursive: true);
      }

      // Use a consistent name based on the video filename
      final fileName = videoPath.split('/').last.split('.').first;
      final thumbnailPath = '${thumbDir.path}/$fileName.jpg';

      // Cache: Check if thumbnail already exists
      if (await File(thumbnailPath).exists()) {
        return thumbnailPath;
      }

      log('Generating thumbnail: $videoPath -> $thumbnailPath');

      await _thumbnailPlugin.getVideoThumbnail(
        srcFile: videoPath,
        destFile: thumbnailPath,
        width: 300,
        height: 300,
        format: 'jpeg',
        quality: 75,
        keepAspectRatio: true,
      );

      // Verify if it was actually created
      if (await File(thumbnailPath).exists()) {
        log('Thumbnail successfully generated: $thumbnailPath');
        return thumbnailPath;
      } else {
        log('Thumbnail was not found at $thumbnailPath after generation');
        return null;
      }
    } catch (e) {
      log('Error generating thumbnail for $videoPath: $e');
      return null;
    }
  }

  Future<Uint8List?> getVideoThumbnailData(String videoPath) async {
    try {
      final path = await getVideoThumbnail(videoPath);
      if (path != null) {
        return await File(path).readAsBytes();
      }
      return null;
    } catch (e) {
      log('Error reading thumbnail data for $videoPath: $e');
      return null;
    }
  }
}
