import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../controllers/address_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../models/address.dart';
import '../auth/_auth_widgets.dart';
import '../../widgets/padosi/padosi_confirm_dialog.dart';

/// Mockup 34 — Saved addresses (server-backed, premium list).
class AddressesListScreen extends StatefulWidget {
  const AddressesListScreen({super.key});
  @override
  State<AddressesListScreen> createState() => _AddressesListScreenState();
}

class _AddressesListScreenState extends State<AddressesListScreen> {
  @override
  void initState() {
    super.initState();
    AddressController.instance.fetch();
  }

  IconData _iconFor(String label) {
    switch (label.toLowerCase()) {
      case 'work':
        return Icons.work_rounded;
      case 'other':
        return Icons.place_rounded;
      default:
        return Icons.cottage_rounded;
    }
  }

  Future<void> _addNew() async {
    await Navigator.pushNamed(context, RouteNames.addAddress);
    if (mounted) AddressController.instance.fetch();
  }

  Future<void> _delete(Address a) async {
    final ok = await PadosiConfirmDialog.show(
      context,
      icon: Icons.delete_outline_rounded,
      title: 'Delete this address?',
      message: '"${a.label} · ${a.summary}" will be removed.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (ok == true) await AddressController.instance.remove(a.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Hero header ──
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 20.w, 12.h),
              child: ListenableBuilder(
                listenable: AddressController.instance,
                builder: (context, _) {
                  final n = AddressController.instance.addresses.length;
                  return Row(
                    children: [
                      const AuthBackButton(),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saved addresses',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -.5,
                                color: AppColors.ink,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              n == 0 ? 'Add where we should deliver' : '$n saved ${n == 1 ? 'place' : 'places'}',
                              style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: AddressController.instance,
                builder: (context, _) {
                  final ctrl = AddressController.instance;
                  if (ctrl.loading && ctrl.addresses.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (ctrl.addresses.isEmpty) return const _EmptyState();
                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 110.h),
                    itemCount: ctrl.addresses.length,
                    separatorBuilder: (_, _) => SizedBox(height: 12.h),
                    itemBuilder: (_, i) {
                      final a = ctrl.addresses[i];
                      return _AddrCard(
                        addr: a,
                        icon: _iconFor(a.label),
                        onSetDefault: a.isDefault ? null : () => AddressController.instance.setDefault(a.id),
                        onDelete: () => _delete(a),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
        child: SafeArea(
          top: false,
          child: AuthButton(label: '+  Add new address', onPressed: _addNew),
        ),
      ),
    );
  }
}

class _AddrCard extends StatelessWidget {
  const _AddrCard({
    required this.addr,
    required this.icon,
    required this.onSetDefault,
    required this.onDelete,
  });
  final Address addr;
  final IconData icon;
  final VoidCallback? onSetDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: addr.isDefault ? AppColors.primary : AppColors.line,
          width: addr.isDefault ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 6.w, 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: addr.isDefault ? AppColors.primarySoft : AppColors.cream,
                    borderRadius: BorderRadius.circular(13.r),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: addr.isDefault ? AppColors.primary : AppColors.inkSoft, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            addr.label,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              letterSpacing: -.2,
                            ),
                          ),
                          if (addr.isDefault) ...[
                            SizedBox(width: 7.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(99.r),
                              ),
                              child: Text(
                                'DEFAULT',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 8.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  letterSpacing: .6,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        addr.summary,
                        style: GoogleFonts.inter(fontSize: 12.sp, color: AppColors.inkSoft, height: 1.45),
                      ),
                      if (addr.pincode?.isNotEmpty ?? false) ...[
                        SizedBox(height: 1.h),
                        Text(
                          'Pincode ${addr.pincode}',
                          style: GoogleFonts.inter(fontSize: 11.sp, color: AppColors.muted),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, size: 19.sp, color: AppColors.inkSoft),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  onSelected: (v) {
                    if (v == 'default') onSetDefault?.call();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    if (onSetDefault != null)
                      const PopupMenuItem(
                        value: 'default',
                        child: Row(children: [
                          Icon(Icons.star_rounded, size: 18, color: AppColors.primary),
                          SizedBox(width: 10),
                          Text('Set as default'),
                        ]),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Contact footer (only if a receiver was added)
          if ((addr.receiverName?.isNotEmpty ?? false) || (addr.receiverPhone?.isNotEmpty ?? false))
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: AppColors.cream.withValues(alpha: .5),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_rounded, size: 13.sp, color: AppColors.muted),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      [addr.receiverName, addr.receiverPhone].whereType<String>().where((s) => s.isNotEmpty).join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 11.sp, fontWeight: FontWeight.w600, color: AppColors.inkSoft),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84.w,
              height: 84.w,
              decoration: const BoxDecoration(color: AppColors.cream, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Icon(Icons.location_on_rounded, color: AppColors.primary, size: 36.sp),
            ),
            SizedBox(height: 18.h),
            Text(
              'No saved addresses',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: -.3,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Add a delivery address to check out\nfaster next time.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12.5.sp, color: AppColors.muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
