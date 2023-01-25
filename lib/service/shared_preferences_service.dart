import '../provider/shared_preferences_provider.dart';

SharedPreferencesService sharedPreferencesService = SharedPreferencesService();

class SharedPreferencesService {
  Future<void> initPreferences() =>
      sharedPreferencesProvider.initSharePreferences();

  void setString(key, value) => sharedPreferencesProvider.setString(key, value);

  String getString(key) {
    return sharedPreferencesProvider.getString(key);
  }

  removeKey(String key) {
    sharedPreferencesProvider.removeKey(key);
  }
}
