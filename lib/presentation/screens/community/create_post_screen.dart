import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../widgets/padosi/padosi_photo_picker.dart';

/// Mockup 43 — Create post (redesigned).
///
/// Editorial composer that mirrors the post detail screen:
///   1. Hero header — back · audience selector (centered) · Post pill.
///   2. Author strip — inline avatar + name + verified tick.
///   3. Big borderless body editor — feels like writing on a page,
///      not into a form. No card wrapper.
///   4. Photo strip below the editor (compact rail when empty, big
///      4:3 preview for the first photo + thumbs for the rest).
///   5. Tag-a-cook row card.
///   6. Sticky toolbar at the bottom with quick actions
///      (photo / tag / hashtag / mood) and a tangerine character
///      counter.
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  static const int _maxPhotos = 4;
  static const int _maxChars = 500;

  final _ctrl = TextEditingController(text: 'Just had the best Andhra meals…');
  final _focus = FocusNode();
  final _picker = ImagePicker();

  String? _tagged;
  String _audience = 'Public';
  final List<String> _photos = [];

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onChange);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onChange);
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChange() => setState(() {});

  int get _charCount => _ctrl.text.length;
  bool get _canPost =>
      _ctrl.text.trim().isNotEmpty && _charCount <= _maxChars;

  Future<void> _pickFromCamera() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1600,
      );
      if (x != null && mounted) {
        setState(() => _photos.add(x.path));
      }
    } catch (_) {
      if (mounted) _toast('Could not open camera');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final remaining = _maxPhotos - _photos.length;
      if (remaining <= 0) return;
      final xs = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1600,
        limit: remaining,
      );
      if (xs.isNotEmpty && mounted) {
        setState(() =>
            _photos.addAll(xs.take(remaining).map((e) => e.path)));
      }
    } catch (_) {
      if (mounted) _toast('Could not open gallery');
    }
  }

  void _toast(String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.ink,
        ),
      );

  void _showAudienceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AudienceSheet(
        selected: _audience,
        onSelect: (v) => setState(() => _audience = v),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _Header(
                  audience: _audience,
                  canPost: _canPost,
                  onBack: () => Navigator.maybePop(context),
                  onAudienceTap: _showAudienceSheet,
                  onPost: _canPost
                      ? () => Navigator.pop(context, _ctrl.text)
                      : null,
                ),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 110.h),
                    children: [
                      // ── Author strip (matches post_detail) ──
                      Row(
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: const BoxDecoration(
                              color: AppColors.tier1,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'PM',
                              style: GoogleFonts.spaceGrotesk(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Priya Mehta',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                        letterSpacing: -.3,
                                      ),
                                    ),
                                    SizedBox(width: 5.w),
                                    Icon(
                                      Icons.verified_rounded,
                                      size: 14.sp,
                                      color: AppColors.secondary,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Posting as you · just now',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5.sp,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 18.h),

                      // ── Editorial body editor (no card) ──
                      TextField(
                        controller: _ctrl,
                        focusNode: _focus,
                        autofocus: false,
                        maxLines: null,
                        minLines: 5,
                        cursorColor: AppColors.primary,
                        cursorRadius: const Radius.circular(2),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18.sp,
                          color: AppColors.ink,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -.3,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText:
                              'What did you love today?\n\nA dish, a cook, a memory — share it with your neighbours.',
                          hintStyle: GoogleFonts.spaceGrotesk(
                            fontSize: 18.sp,
                            color: AppColors.muted,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // ── Photo preview / picker ──
                      if (_photos.isEmpty) ...[
                        _SectionKicker(
                          label: 'ADD PHOTOS',
                          trailing: '0/$_maxPhotos',
                        ),
                        SizedBox(height: 10.h),
                        PadosiPhotoPicker(
                          photos: _photos,
                          maxPhotos: _maxPhotos,
                          onPickCamera: _pickFromCamera,
                          onPickGallery: _pickFromGallery,
                          onRemove: (i) =>
                              setState(() => _photos.removeAt(i)),
                        ),
                      ] else
                        _PhotoGallery(
                          photos: _photos,
                          maxPhotos: _maxPhotos,
                          onAdd: _pickFromGallery,
                          onRemove: (i) =>
                              setState(() => _photos.removeAt(i)),
                        ),

                      SizedBox(height: 24.h),

                      // ── Tag a cook ──
                      _SectionKicker(label: 'TAG A COOK'),
                      SizedBox(height: 10.h),
                      _TagCookRow(
                        tagged: _tagged,
                        onTap: () =>
                            setState(() => _tagged = 'Sunita Aunty'),
                        onClear: () => setState(() => _tagged = null),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Sticky toolbar ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _Toolbar(
              charCount: _charCount,
              maxChars: _maxChars,
              onCamera: _pickFromCamera,
              onGallery: _pickFromGallery,
              onTag: () => setState(() => _tagged = 'Sunita Aunty'),
              onHash: () {
                final t = _ctrl.text;
                _ctrl.text = '$t ';
                _ctrl.selection = TextSelection.fromPosition(
                  TextPosition(offset: _ctrl.text.length),
                );
                _focus.requestFocus();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── header ───────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.audience,
    required this.canPost,
    required this.onBack,
    required this.onAudienceTap,
    required this.onPost,
  });
  final String audience;
  final bool canPost;
  final VoidCallback onBack;
  final VoidCallback onAudienceTap;
  final VoidCallback? onPost;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 6.h, 12.w, 6.h),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.ink,
            iconSize: 22.sp,
          ),
          // Centered audience selector
          Expanded(
            child: Center(
              child: Material(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(99.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(99.r),
                  onTap: onAudienceTap,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          audience == 'Public'
                              ? Icons.public_rounded
                              : Icons.people_rounded,
                          size: 14.sp,
                          color: AppColors.ink,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          audience,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 15.sp,
                          color: AppColors.inkSoft,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Post pill
          Material(
            color: canPost
                ? AppColors.primary
                : AppColors.line.withValues(alpha: .5),
            borderRadius: BorderRadius.circular(99.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(99.r),
              onTap: onPost,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 18.w,
                  vertical: 9.h,
                ),
                child: Text(
                  'Post',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: canPost ? Colors.white : AppColors.muted,
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

// ─────────────────────── section kicker ─────────────────────

class _SectionKicker extends StatelessWidget {
  const _SectionKicker({required this.label, this.trailing});
  final String label;
  final String? trailing;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              letterSpacing: 1.2,
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: 6.w),
            Text(
              trailing!,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.inkSoft,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────── photo gallery ──────────────────────

class _PhotoGallery extends StatelessWidget {
  const _PhotoGallery({
    required this.photos,
    required this.maxPhotos,
    required this.onAdd,
    required this.onRemove,
  });
  final List<String> photos;
  final int maxPhotos;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  @override
  Widget build(BuildContext context) {
    final first = photos.first;
    final rest = photos.skip(1).toList();
    final canAdd = photos.length < maxPhotos;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionKicker(
          label: 'PHOTOS',
          trailing: '${photos.length}/$maxPhotos',
        ),
        SizedBox(height: 10.h),
        // Big 4:3 hero preview
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: _photoWidget(first),
              ),
            ),
            Positioned(
              top: 10.h,
              right: 10.w,
              child: Material(
                color: Colors.black.withValues(alpha: .55),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => onRemove(0),
                  child: SizedBox(
                    width: 30.w,
                    height: 30.w,
                    child: Icon(Icons.close_rounded,
                        color: Colors.white, size: 16.sp),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (rest.isNotEmpty || canAdd) ...[
          SizedBox(height: 10.h),
          SizedBox(
            height: 70.w,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: rest.length + (canAdd ? 1 : 0),
              separatorBuilder: (_, _) => SizedBox(width: 8.w),
              itemBuilder: (_, i) {
                if (canAdd && i == rest.length) {
                  return Material(
                    color: AppColors.cream,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      side: const BorderSide(color: AppColors.line),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.r),
                      onTap: onAdd,
                      child: SizedBox(
                        width: 70.w,
                        height: 70.w,
                        child: Icon(Icons.add_rounded,
                            color: AppColors.ink, size: 22.sp),
                      ),
                    ),
                  );
                }
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: SizedBox(
                        width: 70.w,
                        height: 70.w,
                        child: _photoWidget(rest[i]),
                      ),
                    ),
                    Positioned(
                      top: -4.h,
                      right: -4.w,
                      child: Material(
                        color: AppColors.ink,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => onRemove(i + 1),
                          child: SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: Icon(Icons.close_rounded,
                                color: Colors.white, size: 12.sp),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _photoWidget(String src) {
    final isNetwork = src.startsWith('http');
    if (isNetwork) {
      return Image.network(src, fit: BoxFit.cover);
    }
    return Image.file(File(src), fit: BoxFit.cover);
  }
}

// ─────────────────────── tag-a-cook row ─────────────────────

class _TagCookRow extends StatelessWidget {
  const _TagCookRow({
    required this.tagged,
    required this.onTap,
    required this.onClear,
  });
  final String? tagged;
  final VoidCallback onTap;
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: const BorderSide(color: AppColors.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                alignment: Alignment.center,
                child: Text('🍴', style: TextStyle(fontSize: 18.sp)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tagged ?? 'Tag a cook',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: tagged == null
                            ? AppColors.muted
                            : AppColors.ink,
                        letterSpacing: -.2,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      tagged == null
                          ? 'Mention the home chef'
                          : 'Tagged in this post',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (tagged == null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 11.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                  child: Text(
                    'Add',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                )
              else
                IconButton(
                  onPressed: onClear,
                  icon: Icon(Icons.close_rounded,
                      color: AppColors.muted, size: 18.sp),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── audience sheet ─────────────────────

class _AudienceSheet extends StatelessWidget {
  const _AudienceSheet({required this.selected, required this.onSelect});
  final String selected;
  final ValueChanged<String> onSelect;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'Who can see this?',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  letterSpacing: -.3,
                ),
              ),
              SizedBox(height: 14.h),
              _row(
                context,
                icon: Icons.public_rounded,
                label: 'Public',
                sub: 'Anyone on Padosi can see your post',
                value: 'Public',
              ),
              SizedBox(height: 8.h),
              _row(
                context,
                icon: Icons.people_rounded,
                label: 'Neighbours',
                sub: 'Only people in your neighbourhood',
                value: 'Neighbours',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String sub,
    required String value,
  }) {
    final isSelected = selected == value;
    return Material(
      color: isSelected ? AppColors.primarySoft : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.line,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () {
          onSelect(value);
          Navigator.pop(context);
        },
        child: Padding(
          padding: EdgeInsets.all(13.w),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19.sp,
                color: isSelected ? AppColors.primary : AppColors.ink,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      sub,
                      style: GoogleFonts.inter(
                        fontSize: 11.5.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded,
                    color: AppColors.primary, size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────── sticky toolbar ─────────────────────

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.charCount,
    required this.maxChars,
    required this.onCamera,
    required this.onGallery,
    required this.onTag,
    required this.onHash,
  });
  final int charCount;
  final int maxChars;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onTag;
  final VoidCallback onHash;
  @override
  Widget build(BuildContext context) {
    final near = charCount > maxChars - 50;
    final over = charCount > maxChars;
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 14.h),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: AppColors.line),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withValues(alpha: .08),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(8.w, 6.h, 14.w, 6.h),
          child: Row(
            children: [
              _ToolBtn(icon: Icons.photo_camera_rounded, onTap: onCamera),
              _ToolBtn(icon: Icons.photo_library_rounded, onTap: onGallery),
              _ToolBtn(icon: Icons.alternate_email_rounded, onTap: onTag),
              _ToolBtn(icon: Icons.tag_rounded, onTap: onHash),
              const Spacer(),
              // Char counter
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: over
                      ? AppColors.primary
                      : (near
                          ? AppColors.primarySoft
                          : AppColors.cream),
                  borderRadius: BorderRadius.circular(99.r),
                ),
                child: Text(
                  '$charCount/$maxChars',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: over
                        ? Colors.white
                        : (near ? AppColors.primary : AppColors.inkSoft),
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

class _ToolBtn extends StatelessWidget {
  const _ToolBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40.w,
          height: 40.w,
          child: Icon(icon, color: AppColors.ink, size: 20.sp),
        ),
      ),
    );
  }
}
