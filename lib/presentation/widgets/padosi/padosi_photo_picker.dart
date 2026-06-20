import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';

/// Shared photo-picker row used by Create Post, Become Chef, Edit
/// Profile etc. — wherever the user adds photos.
///
/// Visual: a horizontally scrolling rail of 76×76 dashed-border tiles.
/// Tile 0 is the "Camera" capture, tile 1 is "Gallery", remaining
/// tiles show the selected thumbnails with a tiny close X.
///
/// The widget is purely visual — wire your image_picker /
/// file_picker call to [onPickCamera] and [onPickGallery]; you
/// control the list via [photos] and [onRemove].
class PadosiPhotoPicker extends StatelessWidget {
  const PadosiPhotoPicker({
    super.key,
    required this.photos,
    required this.onPickCamera,
    required this.onPickGallery,
    required this.onRemove,
    this.maxPhotos = 4,
  });

  /// Thumbnail sources (local path / network url / asset path).
  /// Empty = nothing picked yet.
  final List<String> photos;
  final VoidCallback onPickCamera;
  final VoidCallback onPickGallery;
  final void Function(int index) onRemove;
  final int maxPhotos;

  @override
  Widget build(BuildContext context) {
    final canAdd = photos.length < maxPhotos;
    return SizedBox(
      height: 76.w,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: photos.length + (canAdd ? 2 : 0),
        separatorBuilder: (_, _) => SizedBox(width: 10.w),
        itemBuilder: (_, i) {
          // Picker tiles
          if (canAdd && i == 0) {
            return _PickerTile(
              icon: Icons.photo_camera_rounded,
              label: 'Camera',
              onTap: onPickCamera,
            );
          }
          if (canAdd && i == 1) {
            return _PickerTile(
              icon: Icons.photo_library_rounded,
              label: 'Gallery',
              onTap: onPickGallery,
            );
          }
          final photoIndex = i - (canAdd ? 2 : 0);
          return _ThumbTile(
            src: photos[photoIndex],
            onRemove: () => onRemove(photoIndex),
          );
        },
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: AppColors.line,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: SizedBox(
          width: 76.w,
          height: 76.w,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.ink, size: 22.sp),
              SizedBox(height: 4.h),
              Text(
                label,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThumbTile extends StatelessWidget {
  const _ThumbTile({required this.src, required this.onRemove});
  final String src;
  final VoidCallback onRemove;

  bool get _isNetwork =>
      src.startsWith('http://') || src.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76.w,
      height: 76.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: SizedBox.expand(
              child: _isNetwork
                  ? Image.network(src, fit: BoxFit.cover)
                  : Container(
                      color: AppColors.cream,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.image_rounded,
                        color: AppColors.muted,
                        size: 28.sp,
                      ),
                    ),
            ),
          ),
          // Close button — top-right
          Positioned(
            top: -6.h,
            right: -6.w,
            child: Material(
              color: AppColors.ink,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 13.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
