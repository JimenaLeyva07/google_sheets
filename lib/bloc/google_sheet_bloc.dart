import 'dart:async';

import '../model/user_model.dart';
import '../service/google_sheet_service.dart';
import '../service/shared_preferences_service.dart';
import '../service/socket_service.dart';

GoogleSheetBloc googleSheetBloc = GoogleSheetBloc(
    googleSheetService: googleSheetService,
    socketService: socketService,
    sharedPreferencesService: sharedPreferencesService);

/// Class for getting and deleting users in a user list
class GoogleSheetBloc {
  GoogleSheetBloc(
      {required this.sharedPreferencesService,
      required this.googleSheetService,
      required this.socketService});

  final GoogleSheetService googleSheetService;
  final SocketService socketService;
  final SharedPreferencesService sharedPreferencesService;

  /// Stream for control the list of users
  final _controllerListUser = StreamController<List<User>>.broadcast();
  Stream<List<User>> get streamListUser => _controllerListUser.stream;

  /// Stream for control when user was deleted
  final _controllerDeleteUser = StreamController<bool>();
  Stream<bool> get streamDeleteUser => _controllerDeleteUser.stream;

  ///Function for getting all users
  Future<void> getAllUsers() async {
    List<User>? listUsers = await googleSheetService.getAllUser();
    _controllerListUser.add(listUsers!);
  }

  ///Function for delete a user of user list
  Future<void> deleteUser(String id, int indexRow) async {
    bool wasUserDelete = await googleSheetService.deleteUser(id, indexRow);
    _controllerDeleteUser.add(wasUserDelete);
  }

  Stream<Map> get socketStream => socketService.socketStream;

  void saveUserInfo(String key, String value) {
    sharedPreferencesService.setString(key, value);
  }
}
