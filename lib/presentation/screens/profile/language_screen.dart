import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/constants/app_colors.dart';
import '../auth/_auth_widgets.dart';
import '../discover/_discover_widgets.dart';

/// Mockup 39 — Language.
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});
  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'English';

  static const _langs = <(String, String?)>[
    ('English', 'Default'),
    ('తెలుగు (Telugu)', null),
    ('हिंदी (Hindi)', null),
    ('ಕನ್ನಡ (Kannada)', null),
    ('தமிழ் (Tamil)', null),
    ('मराठी (Marathi)', null),
  ];

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
                const PlainAppBar(title: 'Language'),
                Expanded(
                  child: ListView(
                    padding:
                        EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 110.h),
                    children: [
                      CardGroup(
                        children: _langs.map((l) {
                          final (name, sub) = l;
                          return RadioListRow(
                            title: name,
                            subtitle: sub,
                            selected: _selected == name,
                            onTap: () => setState(() => _selected = name),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StickyBar(
              child: AuthButton(
                label: 'Apply',
                onPressed: () => Navigator.pop(context, _selected),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
