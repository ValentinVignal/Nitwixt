import 'dart:async';

class IndexedListProvider<T> {
  Stream<List<T>> stream;
  bool hasMore;
  T Function(Map map) dataBuilder;

  bool _isLoading;
  List<Map> _data;
  StreamController<List<Map>> _controller;

  IndexedListProvider({
    this.dataBuilder
  }) {
    _data = List<Map>();
    _controller = StreamController<List<Map>>.broadcast();
    _isLoading = false;
    stream = _controller.stream.map<List<T>>((List<Map> postsData) {
      return postsData.map<T>(this.dataBuilder).toList();
    });
    hasMore = true;
    refresh();
  }

  Future<void> refresh() {
    return loadMore(clearCacheData: true);
  }

  Future<void> loadMore({bool clearCacheData = false}) {
    if (clearCacheData) {
      _data = List<Map>();
      hasMore = true;
      if (_isLoading || !hasMore) {
        return Future.value();
      }
      _isLoading = true;
      // TODO : Add a stream
    }
  }
}