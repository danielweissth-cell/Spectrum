import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Recently played links, newest first, persisted between launches.
class HistoryStore extends ChangeNotifier {
  static const String _storageKey = 'history.urls';
  static const int maxEntries = 100;

  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  List<String> _urls = const [];

  List<String> get urls => _urls;

  Future<void> load() async {
    _urls = await _preferences.getStringList(_storageKey) ?? const [];
    notifyListeners();
  }

  /// Moves [url] to the top, adding it if it is new.
  Future<void> record(String url) {
    final updated = [url, ..._urls.where((existing) => existing != url)];
    return _save(updated.take(maxEntries).toList());
  }

  Future<void> remove(String url) =>
      _save(_urls.where((existing) => existing != url).toList());

  Future<void> clear() => _save(const []);

  Future<void> _save(List<String> urls) async {
    _urls = List.unmodifiable(urls);
    notifyListeners();
    await _preferences.setStringList(_storageKey, _urls);
  }
}
