import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../states/app_loader.dart';
import '../states/empty_state.dart';
import '../states/error_state.dart';

typedef PageFetcher<T> = Future<List<T>> Function(int page);

class PaginatedList<T> extends StatefulWidget {
  const PaginatedList({
    super.key,
    required this.fetchPage,
    required this.itemBuilder,
    this.separator,
    this.padding,
    this.pageSize = 20,
    this.emptyTitle,
    this.emptySubtitle,
    this.scrollController,
  });

  final PageFetcher<T> fetchPage;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final Widget? separator;
  final EdgeInsetsGeometry? padding;
  final int pageSize;
  final String? emptyTitle;
  final String? emptySubtitle;
  final ScrollController? scrollController;

  @override
  State<PaginatedList<T>> createState() => _PaginatedListState<T>();
}

class _PaginatedListState<T> extends State<PaginatedList<T>> {
  final List<T> _items = [];
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  Object? _error;
  late final ScrollController _ctrl =
      widget.scrollController ?? ScrollController();

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onScroll);
    _load(reset: true);
  }

  void _onScroll() {
    if (!_ctrl.hasClients) return;
    if (_ctrl.position.pixels >= _ctrl.position.maxScrollExtent - 200 &&
        !_loading &&
        _hasMore) {
      _load();
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    if (!mounted) return;
    setState(() {
      _loading = true;
      if (reset) {
        _error = null;
        _page = 1;
        _hasMore = true;
        _items.clear();
      }
    });
    try {
      final fetched = await widget.fetchPage(_page);
      if (!mounted) return;
      setState(() {
        _items.addAll(fetched);
        _hasMore = fetched.length >= widget.pageSize;
        _page += 1;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _refresh() => _load(reset: true);

  @override
  void dispose() {
    _ctrl.removeListener(_onScroll);
    if (widget.scrollController == null) _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty && _loading) {
      return const Center(child: AppLoader());
    }
    if (_items.isEmpty && _error != null) {
      return ErrorStateView(error: _error, onRetry: _refresh);
    }
    if (_items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.sizeOf(context).height * .2),
            EmptyState(
              title: widget.emptyTitle ?? 'Nothing here yet',
              subtitle: widget.emptySubtitle ?? '',
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _ctrl,
        padding: widget.padding ?? EdgeInsets.symmetric(vertical: AppSizes.sm),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _items.length + (_hasMore ? 1 : 0),
        itemBuilder: (c, i) {
          Widget item;
          if (i >= _items.length) {
            item = Padding(
              padding: EdgeInsets.all(AppSizes.lg),
              child: const Center(child: AppLoader(size: 22)),
            );
          } else {
            item = widget.itemBuilder(c, _items[i], i);
          }

          if (i < _items.length + (_hasMore ? 1 : 0) - 1) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                item,
                widget.separator ?? SizedBox(height: AppSizes.sm),
              ],
            );
          }
          return item;
        },
      ),
    );
  }
}
