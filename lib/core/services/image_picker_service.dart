import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/app_sizes.dart';
import 'navigation_service.dart';
import 'permission_service.dart';

class ImagePickerService {
  ImagePickerService._();

  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickFromSheet({
    int imageQuality = 85,
    double? maxWidth = 1600,
  }) async {
    final ctx = NavigationService.context;
    if (ctx == null) return null;

    final source = await showModalBottomSheet<ImageSource>(
      context: ctx,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
      ),
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(c, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(c, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return null;

    final ok = source == ImageSource.camera
        ? await PermissionService.camera()
        : await PermissionService.photos();
    if (!ok) return null;

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: imageQuality,
      maxWidth: maxWidth,
    );
    if (picked == null) return null;
    return _compress(File(picked.path));
  }

  static Future<List<File>> pickMultiple({
    int imageQuality = 85,
    int limit = 10,
  }) async {
    final ok = await PermissionService.photos();
    if (!ok) return [];
    final picked = await _picker.pickMultiImage(imageQuality: imageQuality, limit: limit);
    final result = <File>[];
    for (final x in picked) {
      final f = await _compress(File(x.path));
      if (f != null) result.add(f);
    }
    return result;
  }

  static Future<File?> _compress(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final target =
          '${dir.path}/c_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        target,
        quality: 80,
        minWidth: 1080,
      );
      return result != null ? File(result.path) : file;
    } catch (_) {
      return file;
    }
  }
}
