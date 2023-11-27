import 'ref.dart' show RefProxy;

/// ref响应式代理引用管理器
class RefQuoteTracker {
  static bool record = false;

  /// 引用列表获取应用列表都会清空该数组
  static final Map<RefProxy, List<Object?>> _quoteMap = {};

  /// 获取代码块中代理对象的引用记录用于可实现精细化更新状态
  static ({T result, Map<RefProxy, List<Object?>> tracks}) getQuoteTracks<T>(
      T Function() fn) {
    RefQuoteTracker.record = true;
    final result = fn();
    RefQuoteTracker.record = false;
    final tracks = Map<RefProxy, List<Object?>>.from(_quoteMap);
    RefQuoteTracker._quoteMap.clear();
    return (result: result, tracks: tracks);
  }

  /// 该方法提供给RefProxy代理对象内部调用
  static track({required RefProxy proxy, Object? event}) {
    if (RefQuoteTracker.record) {
      if (!RefQuoteTracker._quoteMap.containsKey(proxy)) {
        RefQuoteTracker._quoteMap[proxy] = [];
      }
      RefQuoteTracker._quoteMap[proxy]?.add(event);
    }
  }
}
