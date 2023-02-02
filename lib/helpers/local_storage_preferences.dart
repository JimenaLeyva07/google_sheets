import 'package:shared_preferences/shared_preferences.dart';

class LocalStoragePreferences {
  static final LocalStoragePreferences _instance =
      LocalStoragePreferences._internal();

  factory LocalStoragePreferences() {
    return _instance;
  }

  LocalStoragePreferences._internal();

  late SharedPreferences _prefs;

  initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String get userEmail {
    return _prefs.getString('userEmail') ?? '';
  }

  set userEmail(String value) {
    _prefs.setString('userEmail', value);
  }
}
