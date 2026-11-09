import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Interface language. [system] follows the phone and falls back to English.
enum AppLanguage {
  system(null),
  english(Locale('en')),
  russian(Locale('ru'));

  const AppLanguage(this.locale);

  /// Null means "let Flutter pick from the system languages".
  final Locale? locale;
}

/// User preferences, persisted between launches.
class AppSettings extends ChangeNotifier {
  /// Volume gain: 1.0 is the file's own loudness, values above it amplify.
  static const double minVolume = 0.5;
  static const double maxVolume = 5.0;
  static const double defaultVolume = 1.0;

  static const double minSpeed = 0.5;
  static const double maxSpeed = 5.0;
  static const double defaultSpeed = 1.0;

  static const String _languageKey = 'settings.language';
  static const String _glassKey = 'settings.glass';
  static const String _volumeKey = 'settings.volume';
  static const String _speedKey = 'settings.speed';

  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  AppLanguage _language = AppLanguage.system;
  bool _glassEnabled = true;
  double _volume = defaultVolume;
  double _speed = defaultSpeed;

  AppLanguage get language => _language;
  bool get glassEnabled => _glassEnabled;
  double get volume => _volume;
  double get speed => _speed;

  Future<void> load() async {
    final values = await Future.wait([
      _preferences.getString(_languageKey),
      _preferences.getBool(_glassKey),
      _preferences.getDouble(_volumeKey),
      _preferences.getDouble(_speedKey),
    ]);
    _language = AppLanguage.values.firstWhere(
      (language) => language.name == values[0],
      orElse: () => AppLanguage.system,
    );
    _glassEnabled = values[1] as bool? ?? true;
    _volume = _clamp(values[2] as double?, minVolume, maxVolume, defaultVolume);
    _speed = _clamp(values[3] as double?, minSpeed, maxSpeed, defaultSpeed);
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) {
    if (language == _language) return Future.value();
    _language = language;
    notifyListeners();
    return _preferences.setString(_languageKey, language.name);
  }

  Future<void> setGlassEnabled(bool enabled) {
    if (enabled == _glassEnabled) return Future.value();
    _glassEnabled = enabled;
    notifyListeners();
    return _preferences.setBool(_glassKey, enabled);
  }

  Future<void> setVolume(double volume) {
    final value = _clamp(volume, minVolume, maxVolume, defaultVolume);
    if (value == _volume) return Future.value();
    _volume = value;
    notifyListeners();
    return _preferences.setDouble(_volumeKey, value);
  }

  Future<void> setSpeed(double speed) {
    final value = _clamp(speed, minSpeed, maxSpeed, defaultSpeed);
    if (value == _speed) return Future.value();
    _speed = value;
    notifyListeners();
    return _preferences.setDouble(_speedKey, value);
  }

  static double _clamp(double? value, double min, double max, double fallback) {
    if (value == null || value.isNaN) return fallback;
    return value.clamp(min, max).toDouble();
  }
}
