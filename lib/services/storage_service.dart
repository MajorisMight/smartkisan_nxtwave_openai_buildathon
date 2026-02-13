import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final ImagePicker _picker = ImagePicker();

  // Picks a smaller image directly from gallery to reduce memory pressure.
  Future<File?> pickAndCompressImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: true,
      );
      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      debugPrint('Image pick failed: $e');
      return null;
    }
  }
}
