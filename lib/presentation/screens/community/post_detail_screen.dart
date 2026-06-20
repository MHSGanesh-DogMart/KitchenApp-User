import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../padosi/mock/mock_data.dart';

/// Mockup 42 — Post detail (redesigned).
///
/// New layout — closer to a magazine spread than a card stack:
///   1. Full-bleed 4:3 hero photo at the top with floating white
///      back/save/share circle buttons and a tier ribbon overlay.
///   2. Author strip that "lifts" over the hero (Material elevation,
///      20r card) with avatar + name + meta + tangerine Order pill.
///   3. Body text on the page (no card wrapper) for editorial feel.
///   4. Engagement bar — big tap targets for like / comment / share,
///      ink counts.
///   5. Comments thread: count header, vertical guide line on the
///      left, name/time/body rows.
///   6. Sticky comment composer at the bottom (cream input + tangerine
///      send circle).
class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool _liked = false;
  bool _saved = false;
  int _likes = 64;
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cook = MockData.cooks[3]; // Jain Rasoi
    final initials = cook.name
        .split(' ')
        .take(2)
        .map((s) => s.isNotEmpty ? s[0] : '')
        .join();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Scrollable body ──
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Full-bleed hero ──
              SliverToBoxAdapter(
                child: _Hero(
                  imageUrl: cook.image,
                  tier: cook.tier,
                  onBack: () => Navigator.maybePop(context),
                  saved: _saved,
                  onSave: () => setState(() => _saved = !_saved),
                  onShare: () {},
                ),
              ),

              // ── Author strip (sits cleanly below the hero) ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    cook.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink,
                                      letterSpacing: -.3,
                                    ),
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
                              'Tier 1 · Home Chef · 2h ago',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11.5.sp,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Order pill
                      Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(99.r),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(99.r),
                          onTap: () => Navigator.pushNamed(
                            context,
                            RouteNames.cookDetail,
                            arguments: cook,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 9.h,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Order',
                                  style: GoogleFonts.spaceGrotesk(
                                    color: Colors.white,
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14.sp,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 18.h)),

              // ── Editorial body (no card) ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Block 5 — lunch from a Jain home kitchen.',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          letterSpacing: -.4,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Pure Jain food, cooked fresh daily. No onion, no '
                        'garlic — just authentic home-style flavours, the '
                        'way our grandmothers used to make. Lunch orders '
                        'now open in Block 5! 🙏',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          color: AppColors.inkSoft,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Tags row
                      Wrap(
                        spacing: 6.w,
                        runSpacing: 6.h,
                        children: const [
                          _Hashtag('#JainFood'),
                          _Hashtag('#Block5'),
                          _Hashtag('#HomeChef'),
                          _Hashtag('#NoOnionNoGarlic'),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      Divider(height: 1, color: AppColors.line),
                      SizedBox(height: 6.h),
                    ],
                  ),
                ),
              ),

              // ── Engagement bar ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Row(
                    children: [
                      _EngageBtn(
                        icon: _liked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        label: '$_likes',
                        color: _liked
                            ? AppColors.primary
                            : AppColors.ink,
                        onTap: () => setState(() {
                          _liked = !_liked;
                          _likes += _liked ? 1 : -1;
                        }),
                      ),
                      _EngageBtn(
                        icon: Icons.mode_comment_outlined,
                        label: '9',
                        color: AppColors.ink,
                        onTap: () {},
                      ),
                      _EngageBtn(
                        icon: Icons.send_outlined,
                        label: 'Share',
                        color: AppColors.ink,
                        onTap: () {},
                      ),
                      const Spacer(),
                      _EngageBtn(
                        icon: _saved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        label: _saved ? 'Saved' : 'Save',
                        color: _saved
                            ? AppColors.secondary
                            : AppColors.ink,
                        onTap: () => setState(() => _saved = !_saved),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Divider(
                    height: 1,
                    color: AppColors.line,
                  ),
                ),
              ),

              // ── Comments thread ──
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 140.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Section header
                    Row(
                      children: [
                        Text(
                          'Comments',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                            letterSpacing: -.3,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cream,
                            borderRadius: BorderRadius.circular(99.r),
                          ),
                          child: Text(
                            '9',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.inkSoft,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Newest',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16.sp,
                          color: AppColors.muted,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    _CommentRow(
                      name: 'Anita',
                      body: 'Finally! Been looking for this in our area.',
                      timeAgo: '1h',
                      likes: 4,
                    ),
                    _CommentRow(
                      name: 'Ravi K.',
                      body:
                          'Tried it yesterday — the kadhi was perfect, just '
                          'like my dadi used to make. ❤️',
                      timeAgo: '30m',
                      likes: 12,
                      isReply: false,
                    ),
                    _CommentRow(
                      name: 'Jain Rasoi',
                      body: 'Thank you Ravi! Lunch ready by 12:30 tomorrow 🙏',
                      timeAgo: '20m',
                      likes: 3,
                      isReply: true,
                      isAuthor: true,
                    ),
                    _CommentRow(
                      name: 'Sneha',
                      body: 'Can I order for tomorrow lunch?',
                      timeAgo: '10m',
                      likes: 0,
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // ── Sticky composer ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _Composer(controller: _commentCtrl),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── hero ─────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({
    required this.imageUrl,
    required this.tier,
    required this.onBack,
    required this.saved,
    required this.onSave,
    required this.onShare,
  });
  final String imageUrl;
  final int tier;
  final VoidCallback onBack;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onShare;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Photo
        AspectRatio(
          aspectRatio: 4 / 3,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, _) => Shimmer.fromColors(
              baseColor: AppColors.line,
              highlightColor: Colors.white,
              child: Container(color: AppColors.line),
            ),
            errorWidget: (_, _, _) => Container(
              color: AppColors.cream,
              alignment: Alignment.center,
              child: Icon(
                Icons.restaurant_rounded,
                color: AppColors.muted,
                size: 48.sp,
              ),
            ),
          ),
        ),
        // Top→bottom gradient for chip + button legibility
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: Container(
            height: 100.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: .25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Floating top bar (SafeArea-aware)
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 0),
            child: Row(
              children: [
                _CircleBtn(icon: Icons.arrow_back_rounded, onTap: onBack),
                const Spacer(),
                _CircleBtn(
                  icon: saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  onTap: onSave,
                ),
                SizedBox(width: 10.w),
                _CircleBtn(
                  icon: Icons.ios_share_rounded,
                  onTap: onShare,
                ),
              ],
            ),
          ),
        ),
        // Tier ribbon floating bottom-left
        Positioned(
          left: 16.w,
          bottom: 14.h,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(99.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              tier == 1
                  ? '🏠 Tier 1 · Home Kitchen'
                  : '✓ Tier 2 · Licensed Kitchen',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: tier == 1 ? AppColors.tier1 : AppColors.tier2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40.w,
          height: 40.w,
          child: Icon(icon, color: AppColors.ink, size: 19.sp),
        ),
      ),
    );
  }
}

// ────────────────────── hashtag chip ─────────────────────

class _Hashtag extends StatelessWidget {
  const _Hashtag(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(99.r),
      ),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11.5.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.inkSoft,
        ),
      ),
    );
  }
}

// ─────────────────────── engage button ───────────────────

class _EngageBtn extends StatelessWidget {
  const _EngageBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: color),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────── comment row ─────────────────────

class _CommentRow extends StatelessWidget {
  const _CommentRow({
    required this.name,
    required this.body,
    required this.timeAgo,
    required this.likes,
    this.isReply = false,
    this.isAuthor = false,
  });
  final String name;
  final String body;
  final String timeAgo;
  final int likes;
  final bool isReply;
  final bool isAuthor;
  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0] : '?';
    return Padding(
      padding: EdgeInsets.only(left: isReply ? 36.w : 0, bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar with optional vertical guide for replies
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: isAuthor ? AppColors.primary : AppColors.cream,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: GoogleFonts.spaceGrotesk(
                color: isAuthor ? Colors.white : AppColors.ink,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 11.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name row
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    if (isAuthor) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(99.r),
                        ),
                        child: Text(
                          'AUTHOR',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: .6,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(width: 6.w),
                    Text(
                      '· $timeAgo',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  body,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    color: AppColors.inkSoft,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 14.sp,
                      color: AppColors.muted,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      likes == 0 ? 'Like' : '$likes',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      'Reply',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────── sticky composer ───────────────────

/// Premium floating composer — same surface DNA as the global cart
/// bar. White 20r card with soft shadow, two quick-react chips
/// (👍 / ❤️) on the left, ink underline-style input in the middle,
/// tangerine send pill on the right. Active state grows the send
/// pill into "Send →" when the field has text.
class _Composer extends StatefulWidget {
  const _Composer({required this.controller});
  final TextEditingController controller;
  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  bool get _hasText => widget.controller.text.trim().isNotEmpty;

  void _quickReact(String emoji) {
    widget.controller.text = '$emoji ${widget.controller.text}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
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
          padding: EdgeInsets.fromLTRB(8.w, 6.h, 6.w, 6.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Tangerine avatar (post author = "you" here)
              Container(
                width: 36.w,
                height: 36.w,
                decoration: const BoxDecoration(
                  color: AppColors.tier1,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  'P',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              // Underline-style input (no pill bg — feels lighter)
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  cursorColor: AppColors.primary,
                  textInputAction: TextInputAction.send,
                  minLines: 1,
                  maxLines: 4,
                  style: GoogleFonts.inter(
                    fontSize: 13.5.sp,
                    color: AppColors.ink,
                    height: 1.4,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 10.h,
                    ),
                    hintText: 'Write something kind…',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13.5.sp,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ),
              // Quick reactions — fade out when the user starts typing
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: _hasText
                    ? const SizedBox.shrink()
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ReactDot(
                            emoji: '👍',
                            onTap: () => _quickReact('👍'),
                          ),
                          SizedBox(width: 4.w),
                          _ReactDot(
                            emoji: '❤️',
                            onTap: () => _quickReact('❤️'),
                          ),
                          SizedBox(width: 4.w),
                        ],
                      ),
              ),
              // Send pill — grows label in when there's text.
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                height: 40.h,
                child: Material(
                  color: _hasText
                      ? AppColors.primary
                      : AppColors.cream,
                  borderRadius: BorderRadius.circular(99.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(99.r),
                    onTap: _hasText ? () => widget.controller.clear() : null,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.send_rounded,
                            color: _hasText ? Colors.white : AppColors.muted,
                            size: 16.sp,
                          ),
                          if (_hasText) ...[
                            SizedBox(width: 6.w),
                            Text(
                              'Send',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12.5.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
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

/// Small cream emoji circle used as a quick reaction in the composer.
class _ReactDot extends StatelessWidget {
  const _ReactDot({required this.emoji, required this.onTap});
  final String emoji;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cream,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 32.w,
          height: 32.w,
          child: Center(
            child: Text(emoji, style: TextStyle(fontSize: 16.sp)),
          ),
        ),
      ),
    );
  }
}
