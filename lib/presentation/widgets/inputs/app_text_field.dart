import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Single all-in-one form field.
///
/// Pass one of the `is*` flags to get the matching keyboard, input
/// formatters, max-length, capitalization and validator. Anything you
/// pass explicitly (validator, keyboardType, maxLength, inputFormatters)
/// overrides the flag-based defaults.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hintText,
    this.errorText,

    // Behavior
    this.isRequired = false,
    this.isEditable = true,
    this.obscureText = false,
    this.autoTrim = true,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.textCapitalization,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.validator,
    this.autoValidateMode = AutovalidateMode.onUserInteraction,

    // Field-type flags
    this.isEmail = false,
    this.isMobile = false,
    this.isFullName = false,
    this.isAmount = false,
    this.isPincode = false,
    this.isGST = false,
    this.isPAN = false,
    this.isAadhaar = false,
    this.isFSSAI = false,
    this.isIFSC = false,
    this.isNumber = false,
    this.isHouseNumber = false,
    this.isFloorNumber = false,
    this.isLandmark = false,
    this.isApartment = false,
    this.isContactNumber = false,

    // Decoration
    this.filled = true,
    this.fillColor,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,

    // Alignment
    this.textAlign = TextAlign.start,

    // Callbacks
    this.onChanged,
    this.onTap,
    this.onFieldSubmitted,
    this.focusNode,
    this.nextFocus,
  });

  // Core
  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? hintText;
  final String? errorText;

  // Behavior
  final bool isRequired;
  final bool isEditable;
  final bool obscureText;
  final bool autoTrim;
  final int? maxLength;
  final int maxLines;
  final int? minLines;
  final TextCapitalization? textCapitalization;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final AutovalidateMode autoValidateMode;

  // Field-type flags
  final bool isEmail;
  final bool isMobile;
  final bool isFullName;
  final bool isAmount;
  final bool isPincode;
  final bool isGST;
  final bool isPAN;
  final bool isAadhaar;
  final bool isFSSAI;
  final bool isIFSC;
  final bool isNumber;
  final bool isHouseNumber;
  final bool isFloorNumber;
  final bool isLandmark;
  final bool isApartment;
  final bool isContactNumber;

  // Decoration
  final bool filled;
  final Color? fillColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;

  // Alignment
  final TextAlign textAlign;

  // Callbacks
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      readOnly: !isEditable,
      onTap: onTap,
      obscureText: obscureText,
      autovalidateMode: autoValidateMode,
      maxLength: maxLength ?? _defaultMaxLength,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      keyboardType: keyboardType ?? _defaultKeyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters ?? _defaultFormatters,
      textCapitalization: textCapitalization ?? _defaultCapitalization,
      textAlign: textAlign,
      onChanged: onChanged,
      onFieldSubmitted: (v) {
        onFieldSubmitted?.call(v);
        if (nextFocus != null && textInputAction == TextInputAction.next) {
          FocusScope.of(context).requestFocus(nextFocus);
        }
      },
      validator: (raw) {
        final value = autoTrim ? raw?.trim() : raw;
        // Caller-supplied validator wins.
        if (validator != null) return validator!(value);
        return _defaultValidator(value);
      },
      decoration: InputDecoration(
        
        labelText: label,
        hintText: hintText,
        filled: filled,
        fillColor: fillColor,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding,
        counterText: '',
      ),
    );
  }

  // ───────────── defaults driven by flags ─────────────

  int? get _defaultMaxLength {
    if (isMobile || isContactNumber) return 10;
    if (isPincode) return 6;
    if (isPAN || isFSSAI && false) return 10; // see below
    if (isPAN) return 10;
    if (isAadhaar) return 12;
    if (isFSSAI) return 14;
    if (isIFSC) return 11;
    if (isGST) return 15;
    return null;
  }

  TextInputType get _defaultKeyboardType {
    if (isEmail) return TextInputType.emailAddress;
    if (isMobile ||
        isContactNumber ||
        isAadhaar ||
        isPincode ||
        isFSSAI ||
        isNumber ||
        isAmount ||
        isHouseNumber ||
        isFloorNumber) {
      return TextInputType.number;
    }
    return TextInputType.text;
  }

  TextCapitalization get _defaultCapitalization {
    if (isPAN || isGST || isIFSC || isFSSAI) {
      return TextCapitalization.characters;
    }
    if (isFullName || isLandmark || isApartment) {
      return TextCapitalization.words;
    }
    return TextCapitalization.none;
  }

  List<TextInputFormatter> get _defaultFormatters {
    if (isMobile ||
        isContactNumber ||
        isAadhaar ||
        isPincode ||
        isFSSAI ||
        isNumber ||
        isHouseNumber ||
        isFloorNumber) {
      return [FilteringTextInputFormatter.digitsOnly];
    }
    if (isAmount) {
      return [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))];
    }
    if (isFullName) {
      return [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))];
    }
    if (isPAN) {
      return [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
        _UpperCaseFormatter(),
      ];
    }
    if (isGST || isIFSC) {
      return [
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
        _UpperCaseFormatter(),
      ];
    }
    return const [];
  }

  // ───────────── built-in validators ─────────────

  String? _defaultValidator(String? value) {
    final empty = value == null || value.isEmpty;
    if (isRequired && empty) {
      return errorText ?? _requiredMessage();
    }
    if (empty) return null;

    if (isEmail && !_reEmail.hasMatch(value)) return 'Enter a valid email';
    if ((isMobile || isContactNumber) && !_reMobileIN.hasMatch(value)) {
      return 'Enter a valid mobile number';
    }
    if (isPincode && !_rePincodeIN.hasMatch(value)) {
      return 'Enter a valid pincode';
    }
    if (isFullName && !_reFullName.hasMatch(value)) {
      return 'Enter a valid name';
    }
    if (isAmount && !_reAmount.hasMatch(value)) {
      return 'Enter a valid amount';
    }
    if (isGST && !_reGST.hasMatch(value.toUpperCase())) {
      return 'Enter a valid GST number';
    }
    if (isPAN && !_rePAN.hasMatch(value.toUpperCase())) {
      return 'Enter a valid PAN';
    }
    if (isAadhaar && !_reAadhaar.hasMatch(value)) {
      return 'Enter a valid Aadhaar number';
    }
    if (isFSSAI && !_reFSSAI.hasMatch(value)) {
      return 'Enter a valid FSSAI number';
    }
    if (isIFSC && !_reIFSC.hasMatch(value.toUpperCase())) {
      return 'Enter a valid IFSC code';
    }
    return null;
  }

  String _requiredMessage() {
    if (isMobile || isContactNumber) return 'Enter mobile number';
    if (isEmail) return 'Enter email';
    if (isPincode) return 'Enter pincode';
    if (isAmount) return 'Enter amount';
    if (isFullName) return 'Enter full name';
    if (isPAN) return 'Enter PAN';
    if (isAadhaar) return 'Enter Aadhaar number';
    if (isFSSAI) return 'Enter FSSAI number';
    if (isGST) return 'Enter GST number';
    if (isIFSC) return 'Enter IFSC code';
    if (isHouseNumber) return 'Enter house number';
    if (isFloorNumber) return 'Enter floor number';
    if (isLandmark) return 'Enter landmark';
    if (isApartment) return 'Enter apartment name';
    return 'This field is required';
  }

  // ───────────── regex ─────────────
  static final _reEmail =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final _reMobileIN = RegExp(r'^[6-9]\d{9}$');
  static final _rePincodeIN = RegExp(r'^[1-9][0-9]{5}$');
  static final _reFullName = RegExp(r'^[a-zA-Z\s]+$');
  static final _reAmount = RegExp(r'^[0-9]+(\.[0-9]{1,2})?$');
  static final _rePAN = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
  static final _reAadhaar = RegExp(r'^[2-9][0-9]{11}$');
  static final _reFSSAI = RegExp(r'^[0-9]{14}$');
  static final _reGST = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$');
  static final _reIFSC = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      newValue.copyWith(
        text: newValue.text.toUpperCase(),
        selection: newValue.selection,
      );
}
