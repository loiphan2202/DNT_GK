import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static Future<dynamic> pickImage({
    ImageSource source = ImageSource.gallery,
    int maxWidth = 800,
    int maxHeight = 800,
    int imageQuality = 85,
  }) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
      );

      if (pickedFile == null) return null;

      if (kIsWeb) {
        return pickedFile;
      }

      return File(pickedFile.path);
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  static dynamic getImageProvider(dynamic imageFile, String? networkUrl) {
    if (imageFile == null && (networkUrl == null || networkUrl.isEmpty)) {
      return null;
    }

    if (imageFile != null) {
      if (kIsWeb) {
        return NetworkImage(imageFile.path);
      } else {

        return FileImage(imageFile as File);
      }
    }

    return NetworkImage(networkUrl!);
  }
}
