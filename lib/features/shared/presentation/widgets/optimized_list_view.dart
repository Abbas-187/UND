import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/optimized_repository.dart';
import '../../../../core/error/error_boundary.dart';

/// Optimized list view with lazy loading and pagination
class OptimizedListView<T> extends ConsumerStatefulWidget {
  const OptimizedListView({
    required this.itemBuilder,
    required this.dataProvider,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.separatorBuilder,
    this.refreshable = true,
    this.searchable = false,
    this.filterBuilder,
    this.pageSize = 20,
    this.preloadThreshold = 5,
    this.cacheSize = 100,
    super.key,
  });

  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final AsyncValue<PaginatedResult<T>> Function(QueryParams params)
      dataProvider;
  final Widget Function()? loadingBuilder;
  final Widget Function(Object error, VoidCallback retry)? errorBuilder;
  final Widget Function()? emptyBuilder;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final bool refreshable;
  final bool searchable;
  final Widget Function(Function(QueryParams) onFilter)? filterBuilder;
  final int pageSize;
  final int preloadThreshold;
  final int cacheSize;

  @override
  ConsumerState<OptimizedListView<T>> createState() =>
      _OptimizedListViewState<T>();
}

class _OptimizedListViewState<T> extends ConsumerState<OptimizedListView<T>> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final List<T> _items = [];
  final Map<int, T> _itemCache = {};

  QueryParams _currentParams = const QueryParams();
  bool _isLoading = false;
  bool _hasMore = true;
  String? _lastError;
  Timer? _searchDebouncer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebouncer?.cancel();
    super.dispose();
  }

  /// Handle scroll events for pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  /// Handle search input changes with debouncing
  void _onSearchChanged() {
    _searchDebouncer?.cancel();
    _searchDebouncer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_searchController.text);
    });
  }

  /// Load initial data
  Future<void> _loadInitialData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _lastError = null;
    });

    try {
      await _loadData(reset: true);
    } catch (e) {
      setState(() {
        _lastError = e.toString();
      });

      // Track error
      ErrorAnalytics.trackError(
        e,
        StackTrace.current,
        context: 'OptimizedListView.loadInitialData',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Load more data for pagination
  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _loadData(reset: false);
    } catch (e) {
      // Track error but don't show UI error for pagination
      ErrorAnalytics.trackError(
        e,
        StackTrace.current,
        context: 'OptimizedListView.loadMoreData',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Load data with caching and optimization
  Future<void> _loadData({required bool reset}) async {
    final params = _currentParams.copyWith(
      limit: widget.pageSize,
      offset: reset ? 0 : _items.length,
    );

    final result = widget.dataProvider(params);

    await result.when(
      data: (paginatedResult) async {
        setState(() {
          if (reset) {
            _items.clear();
            _itemCache.clear();
          }

          _items.addAll(paginatedResult.items);
          _hasMore = paginatedResult.hasMore;

          // Update cache
          for (int i = 0; i < paginatedResult.items.length; i++) {
            final index =
                reset ? i : _items.length - paginatedResult.items.length + i;
            _itemCache[index] = paginatedResult.items[i];
          }

          // Maintain cache size
          if (_itemCache.length > widget.cacheSize) {
            final keysToRemove =
                _itemCache.keys.take(_itemCache.length - widget.cacheSize);
            for (final key in keysToRemove) {
              _itemCache.remove(key);
            }
          }
        });
      },
      loading: () {
        // Handle loading state
      },
      error: (error, stackTrace) {
        throw error;
      },
    );
  }

  /// Perform search
  Future<void> _performSearch(String query) async {
    final newParams = _currentParams.copyWith(
      searchTerm: query.isEmpty ? null : query,
    );

    if (newParams != _currentParams) {
      setState(() {
        _currentParams = newParams;
      });
      await _loadInitialData();
    }
  }

  /// Apply filters
  void _applyFilters(QueryParams params) {
    setState(() {
      _currentParams = params;
    });
    _loadInitialData();
  }

  /// Refresh data
  Future<void> _refresh() async {
    await _loadInitialData();
  }

  /// Get cached item or from list
  T? _getItem(int index) {
    return _itemCache[index] ?? (index < _items.length ? _items[index] : null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        if (widget.searchable) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],

        // Filter bar
        if (widget.filterBuilder != null) ...[
          widget.filterBuilder!(_applyFilters),
        ],

        // List content
        Expanded(
          child: _buildListContent(),
        ),
      ],
    );
  }

  Widget _buildListContent() {
    // Error state
    if (_lastError != null && _items.isEmpty) {
      return widget.errorBuilder?.call(
            _lastError!,
            _refresh,
          ) ??
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $_lastError'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refresh,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
    }

    // Loading state (initial)
    if (_isLoading && _items.isEmpty) {
      return widget.loadingBuilder?.call() ??
          const Center(
            child: CircularProgressIndicator(),
          );
    }

    // Empty state
    if (_items.isEmpty && !_isLoading) {
      return widget.emptyBuilder?.call() ??
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No items found'),
              ],
            ),
          );
    }

    // List with refresh capability
    Widget listView = ListView.separated(
      controller: _scrollController,
      itemCount: _items.length + (_hasMore ? 1 : 0),
      separatorBuilder:
          widget.separatorBuilder ?? (context, index) => const Divider(),
      itemBuilder: (context, index) {
        // Loading indicator at the end
        if (index >= _items.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final item = _getItem(index);
        if (item == null) {
          return const SizedBox.shrink();
        }

        // Preload more data when approaching end
        if (index >= _items.length - widget.preloadThreshold && !_isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadMoreData();
          });
        }

        return widget.itemBuilder(context, item, index);
      },
    );

    // Wrap with refresh indicator if enabled
    if (widget.refreshable) {
      listView = RefreshIndicator(
        onRefresh: _refresh,
        child: listView,
      );
    }

    return listView;
  }
}

/// Optimized grid view with similar features
class OptimizedGridView<T> extends ConsumerStatefulWidget {
  const OptimizedGridView({
    required this.itemBuilder,
    required this.dataProvider,
    required this.crossAxisCount,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.refreshable = true,
    this.searchable = false,
    this.filterBuilder,
    this.pageSize = 20,
    this.preloadThreshold = 5,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    super.key,
  });

  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final AsyncValue<PaginatedResult<T>> Function(QueryParams params)
      dataProvider;
  final int crossAxisCount;
  final Widget Function()? loadingBuilder;
  final Widget Function(Object error, VoidCallback retry)? errorBuilder;
  final Widget Function()? emptyBuilder;
  final bool refreshable;
  final bool searchable;
  final Widget Function(Function(QueryParams) onFilter)? filterBuilder;
  final int pageSize;
  final int preloadThreshold;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  @override
  ConsumerState<OptimizedGridView<T>> createState() =>
      _OptimizedGridViewState<T>();
}

class _OptimizedGridViewState<T> extends ConsumerState<OptimizedGridView<T>> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final List<T> _items = [];

  QueryParams _currentParams = const QueryParams();
  bool _isLoading = false;
  bool _hasMore = true;
  String? _lastError;
  Timer? _searchDebouncer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchDebouncer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  void _onSearchChanged() {
    _searchDebouncer?.cancel();
    _searchDebouncer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_searchController.text);
    });
  }

  Future<void> _loadInitialData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _lastError = null;
    });

    try {
      await _loadData(reset: true);
    } catch (e) {
      setState(() {
        _lastError = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _loadData(reset: false);
    } catch (e) {
      // Silent error for pagination
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadData({required bool reset}) async {
    final params = _currentParams.copyWith(
      limit: widget.pageSize,
      offset: reset ? 0 : _items.length,
    );

    final result = widget.dataProvider(params);

    await result.when(
      data: (paginatedResult) async {
        setState(() {
          if (reset) {
            _items.clear();
          }

          _items.addAll(paginatedResult.items);
          _hasMore = paginatedResult.hasMore;
        });
      },
      loading: () {},
      error: (error, stackTrace) {
        throw error;
      },
    );
  }

  Future<void> _performSearch(String query) async {
    final newParams = _currentParams.copyWith(
      searchTerm: query.isEmpty ? null : query,
    );

    if (newParams != _currentParams) {
      setState(() {
        _currentParams = newParams;
      });
      await _loadInitialData();
    }
  }

  void _applyFilters(QueryParams params) {
    setState(() {
      _currentParams = params;
    });
    _loadInitialData();
  }

  Future<void> _refresh() async {
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.searchable) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
        if (widget.filterBuilder != null) ...[
          widget.filterBuilder!(_applyFilters),
        ],
        Expanded(
          child: _buildGridContent(),
        ),
      ],
    );
  }

  Widget _buildGridContent() {
    if (_lastError != null && _items.isEmpty) {
      return widget.errorBuilder?.call(_lastError!, _refresh) ??
          Center(child: Text('Error: $_lastError'));
    }

    if (_isLoading && _items.isEmpty) {
      return widget.loadingBuilder?.call() ??
          const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty && !_isLoading) {
      return widget.emptyBuilder?.call() ??
          const Center(child: Text('No items found'));
    }

    Widget gridView = GridView.builder(
      controller: _scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        childAspectRatio: widget.childAspectRatio,
        crossAxisSpacing: widget.crossAxisSpacing,
        mainAxisSpacing: widget.mainAxisSpacing,
      ),
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Center(child: CircularProgressIndicator());
        }

        if (index >= _items.length - widget.preloadThreshold && !_isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadMoreData();
          });
        }

        return widget.itemBuilder(context, _items[index], index);
      },
    );

    if (widget.refreshable) {
      gridView = RefreshIndicator(
        onRefresh: _refresh,
        child: gridView,
      );
    }

    return gridView;
  }
}
