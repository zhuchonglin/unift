typedef VoidCallback = void Function();

abstract mixin class Dispose {
  /// 是否已销毁
  bool _isDisposed = false;

  /// 返回bool,false代表当前监听已销毁
  bool get isDisposed {
    return _isDisposed;
  }

  /// 销毁之前的回调
  final List<VoidCallback> _onDisposedCallback = [];

  /// 销毁实例
  void dispose() {
    if (!_isDisposed) {
      if (_onDisposedCallback.isNotEmpty) {
        // 遍历监听销毁回调事件列表
        for (var callback in _onDisposedCallback) {
          callback.call();
        }
        // 清空回调记录器
        _onDisposedCallback.clear();
      }
      _isDisposed = true;
    }
  }

  /// 监听销毁
  void onDisposed(VoidCallback callback) {
    _onDisposedCallback.add(callback);
  }
}
