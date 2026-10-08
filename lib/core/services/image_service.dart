import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  const ImageService();

  Future<String?> compressAndSave(File source) async {
    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${dir.path}/product_images');
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final targetPath =
        '${imagesDir.path}/${const Uuid().v4()}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      source.absolute.path,
      targetPath,
      quality: 70,
      minWidth: 800,
      minHeight: 800,
    );

    if (result == null) return null;

    final file = File(result.path);
    if (await file.length() > 150 * 1024) {
      final smaller = await FlutterImageCompress.compressAndGetFile(
        result.path,
        '${imagesDir.path}/${const Uuid().v4()}_sm.jpg',
        quality: 40,
        minWidth: 600,
        minHeight: 600,
      );
      if (smaller != null) {
        await file.delete();
        return smaller.path;
      }
    }
    return result.path;
  }
}
