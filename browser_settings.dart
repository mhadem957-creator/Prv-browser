import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

/// App-wide, persisted user settings. Registered as a [ChangeNotifier] via
/// `provider` so any screen can read/watch it.
class BrowserSettings extends ChangeNotifier {
  String searxngUrl = AppConstants.defaultSearxngUrl;
  String homePage = AppConstants.defaultHomePage;
  String dohProviderUrl = AppConstants.dohProviders.first['url']!;
  bool dohEnabled = true;
  bool adBlockEnabled = true;
  bool trackerBlockEnabled = true;
  bool javascriptEnabled = true;
  bool desktopMode = false;

  bool _loaded = false;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    searxngUrl =
        prefs.getString(AppConstants.prefsSearxngUrl) ?? AppConstants.defaultSearxngUrl;
    homePage =
        prefs.getString(AppConstants.prefsHomePage) ?? AppConstants.defaultHomePage;
    dohProviderUrl = prefs.getString(AppConstants.prefsDohProvider) ??
        AppConstants.dohProviders.first['url']!;
    dohEnabled = prefs.getBool(AppConstants.prefsDohEnabled) ?? true;
    adBlockEnabled = prefs.getBool(AppConstants.prefsAdBlockEnabled) ?? true;
    trackerBlockEnabled =
        prefs.getBool(AppConstants.prefsTrackerBlockEnabled) ?? true;
    javascriptEnabled = prefs.getBool(AppConstants.prefsJsEnabled) ?? true;
    desktopMode = prefs.getBool(AppConstants.prefsDesktopMode) ?? false;
    _loaded = true;
    notifyListeners();
  }

  Future<void> updateSearxngUrl(String value) async {
    if (value.trim().isEmpty) return;
    searxngUrl = value.trim();
    await _saveString(AppConstants.prefsSearxngUrl, searxngUrl);
  }

  Future<void> updateHomePage(String value) async {
    if (value.trim().isEmpty) return;
    homePage = value.trim();
    await _saveString(AppConstants.prefsHomePage, homePage);
  }

  Future<void> updateDohProvider(String value) async {
    dohProviderUrl = value;
    await _saveString(AppConstants.prefsDohProvider, value);
  }

  Future<void> toggleDoh(bool value) async {
    dohEnabled = value;
    await _saveBool(AppConstants.prefsDohEnabled, value);
  }

  Future<void> toggleAdBlock(bool value) async {
    adBlockEnabled = value;
    await _saveBool(AppConstants.prefsAdBlockEnabled, value);
  }

  Future<void> toggleTrackerBlock(bool value) async {
    trackerBlockEnabled = value;
    await _saveBool(AppConstants.prefsTrackerBlockEnabled, value);
  }

  Future<void> toggleJavascript(bool value) async {
    javascriptEnabled = value;
    await _saveBool(AppConstants.prefsJsEnabled, value);
  }

  Future<void> toggleDesktopMode(bool value) async {
    desktopMode = value;
    await _saveBool(AppConstants.prefsDesktopMode, value);
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    notifyListeners();
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    notifyListeners();
  }
}
