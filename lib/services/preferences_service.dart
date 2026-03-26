import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _hasSeenWelcomeKey = 'has_seen_welcome';

  Future<void> setHasSeenWelcome(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenWelcomeKey, value);
  }

  Future<bool> getHasSeenWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenWelcomeKey) ?? false;
  }
}