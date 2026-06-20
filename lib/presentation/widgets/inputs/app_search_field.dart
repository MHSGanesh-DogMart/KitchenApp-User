import 'package:flutter/material.dart';

import '../../../core/utils/debouncer.dart';
import 'app_text_field.dart';

class AppSearchField extends StatefulWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hint = 'Search',
    required this.onSearch,
    this.debounce = const Duration(milliseconds: 400),
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String> onSearch;
  final Duration debounce;
  final bool autofocus;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late final TextEditingController _ctrl =
      widget.controller ?? TextEditingController();
  late final Debouncer _debouncer = Debouncer(delay: widget.debounce);
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onChanged);
  }

  void _onChanged() {
    final has = _ctrl.text.isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
    _debouncer.run(() => widget.onSearch(_ctrl.text.trim()));
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onChanged);
    _debouncer.dispose();
    if (widget.controller == null) _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _ctrl,
      hintText: widget.hint,
      prefixIcon: const Icon(Icons.search),
      textInputAction: TextInputAction.search,
      autoTrim: false,
      suffixIcon: _hasText
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _ctrl.clear();
                widget.onSearch('');
              },
            )
          : null,
    );
  }
}
