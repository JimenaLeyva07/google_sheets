import 'package:shared_preferences/shared_preferences.dart';

SharePreferencesProvider sharedPreferencesProvider = SharePreferencesProvider();

class SharePreferencesProvider {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  SharedPreferences? prefs;

  Future<void> initSharePreferences() async {
    prefs = await _prefs;
  }

  setString(String key, String value) => prefs!.setString(key, value);

  String getString(String key) {
    String a = prefs!.getString(key) ?? '';
    return a;
  }

  removeKey(String key) {
    prefs!.remove(key);
  }
}
