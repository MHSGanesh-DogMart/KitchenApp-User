import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../controllers/address_controller.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/address.dart';
import '../auth/_auth_widgets.dart';
import '../padosi/location/location_result.dart';
import '../padosi/location/select_location_screen.dart';

/// Add a delivery address: pin the spot on the free OSM map, the form
/// auto-fills from the reverse-geocode, then add flat / contact details.
class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});
  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _line1 = TextEditingController();
  final _area = TextEditingController();
  final _city = TextEditingController();
  final _pincode = TextEditingController();
  final _landmark = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();

  LocationResult? _picked;
  String _label = 'Home';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _pickOnMap());
  }

  @override
  void dispose() {
    for (final c in [_line1, _area, _city, _pincode, _landmark, _name, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickOnMap() async {
    final res = await Navigator.push<LocationResult>(
      context,
      MaterialPageRoute(builder: (_) => SelectLocationScreen(initial: _picked)),
    );
    if (res == null || !mounted) return;
    setState(() {
      _picked = res;
      // Auto-fill from the reverse-geocode (only fields the user hasn't typed).
      if (_line1.text.trim().isEmpty) {
        _line1.text = res.building ?? res.road ?? '';
      }
      if (_area.text.trim().isEmpty && (res.area?.isNotEmpty ?? false)) _area.text = res.area!;
      if (_city.text.trim().isEmpty && (res.city?.isNotEmpty ?? false)) _city.text = res.city!;
      if (_pincode.text.trim().isEmpty && (res.pincode?.isNotEmpty ?? false)) _pincode.text = res.pincode!;
    });
  }

  Future<void> _save() async {
    if (_picked == null) return _toast('Pin your location on the map first');
    if (_line1.text.trim().isEmpty) return _toast('Enter your flat / house number');
    if (_name.text.trim().isEmpty) return _toast('Enter the receiver name');
    if (_phone.text.trim().length < 10) return _toast('Enter a valid 10-digit phone');

    setState(() => _saving = true);
    final addr = await AddressController.instance.add({
      'label': _label,
      'line1': _line1.text.trim(),
      if (_landmark.text.trim().isNotEmpty) 'landmark': _landmark.text.trim(),
      if (_area.text.trim().isNotEmpty) 'area': _area.text.trim(),
      if (_city.text.trim().isNotEmpty) 'city': _city.text.trim(),
      if (_pincode.text.trim().isNotEmpty) 'pincode': _pincode.text.trim(),
      'receiverName': _name.text.trim(),
      'receiverPhone': _phone.text.trim(),
      'lat': _picked!.point.latitude,
      'lng': _picked!.point.longitude,
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (addr != null) Navigator.pop<Address>(context, addr);
  }

  void _toast(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.ink));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 6.h, 16.w, 6.h),
              child: Row(
                children: [
                  const AuthBackButton(),
                  SizedBox(width: 8.w),
                  Text(
                    'Add address',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      letterSpacing: -.5,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
                children: [
                  _LocationCard(picked: _picked, onTap: _pickOnMap),
                  SizedBox(height: 20.h),

                  _kicker('ADDRESS DETAILS'),
                  SizedBox(height: 10.h),
                  _Field(controller: _line1, label: 'Flat / House no., Building *', icon: Icons.home_work_rounded),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(child: _Field(controller: _area, label: 'Area / Locality', icon: Icons.location_city_rounded)),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _Field(
                          controller: _pincode,
                          label: 'Pincode',
                          icon: Icons.pin_drop_rounded,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _Field(controller: _city, label: 'City', icon: Icons.apartment_rounded),
                  SizedBox(height: 12.h),
                  _Field(controller: _landmark, label: 'Landmark (optional)', icon: Icons.signpost_rounded),

                  SizedBox(height: 22.h),
                  _kicker('CONTACT'),
                  SizedBox(height: 10.h),
                  _Field(controller: _name, label: 'Receiver name *', icon: Icons.person_rounded),
                  SizedBox(height: 12.h),
                  _Field(
                    controller: _phone,
                    label: 'Phone number *',
                    icon: Icons.call_rounded,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                  ),

                  SizedBox(height: 22.h),
                  _kicker('SAVE AS'),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      for (final l in ['Home', 'Work', 'Other']) ...[
                        _LabelChip(label: l, selected: _label == l, onTap: () => setState(() => _label = l)),
                        SizedBox(width: 8.w),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
              child: SafeArea(
                top: false,
                child: AuthButton(
                  label: _saving ? 'Saving…' : 'Save address',
                  onPressed: _saving ? null : _save,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kicker(String t) => Text(
        t,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
          letterSpacing: 1.2,
        ),
      );
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.picked, required this.onTap});
  final LocationResult? picked;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primarySoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: AppColors.primary.withValues(alpha: .35)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12.r)),
                alignment: Alignment.center,
                child: Icon(Icons.map_rounded, color: Colors.white, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      picked?.label ?? 'Pin your location on the map',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      picked?.detail ?? 'Tap to open the map',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 11.5.sp, color: AppColors.inkSoft, height: 1.35),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                picked == null ? 'Pick' : 'Change',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  const _LabelChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.ink : AppColors.surface,
      borderRadius: BorderRadius.circular(99.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(99.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 9.h),
          decoration: selected
              ? null
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(99.r),
                  border: Border.all(color: AppColors.line),
                ),
          child: Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.icon,
    this.keyboardType,
    this.maxLength,
  });
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final TextInputType? keyboardType;
  final int? maxLength;
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      inputFormatters: keyboardType == TextInputType.number || keyboardType == TextInputType.phone
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      cursorColor: AppColors.primary,
      style: GoogleFonts.inter(fontSize: 13.sp, color: AppColors.ink),
      decoration: InputDecoration(
        labelText: label,
        counterText: '',
        prefixIcon: icon == null ? null : Icon(icon, size: 18.sp, color: AppColors.muted),
        labelStyle: GoogleFonts.inter(fontSize: 12.5.sp, color: AppColors.muted),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
