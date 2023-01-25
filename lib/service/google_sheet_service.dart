import 'dart:convert';

import 'package:googleapis/sheets/v4.dart';
import 'package:local_flutter_login_google/helpers/google_sheet_helpers.dart';

import '../model/user_model.dart';
import '../provider/google_sheet_data.dart';
import '../provider/socket.dart';

GoogleSheetService googleSheetService = GoogleSheetService(
    googleSheetProvider: googleSheetProvider, socketProvider: socketProvider);

abstract class IGoogleSheetService {
  ///Create a user by obtaining their information
  ///Gets the last id of the spreadsheet to increment it by 1 and save the user with this id
  Future<bool> createUser(User infoUser);

  ///Removes the user that corresponds to the selected id
  Future<bool> deleteUser(String id, int index);

  ///Gets all the information of all the users in the spreadsheet.
  ///Clean the data in case any information arrives that is empty.
  Future<List<User>?> getAllUser();

  ///Update some cells to a user
  Future<bool> updateCellUser(
      String id, List<String> keys, List<String> newValues, int indexRow);

  Future<void> init();
}

class GoogleSheetService implements IGoogleSheetService {
  GoogleSheetService(
      {required this.googleSheetProvider, required this.socketProvider});

  final IGoogleSheetProvider googleSheetProvider;
  final SocketProvider socketProvider;

  @override
  Future<bool> createUser(User infoUser) async {
    if (infoUser.id == null) {
      int indexUser = await googleSheetProvider.getRowCount() + 1;
      infoUser.id = indexUser.toString();
    }
    
    ValueRange vr = ValueRange.fromJson({
      "values": [
        [
          infoUser.id.toString(),
          infoUser.name,
          infoUser.email,
          infoUser.comments.join("\n")
        ]
      ]
    });
    Map data = {"msg": "Tabla modificada", "user": {}, "action": "create"};
      String dataEnconde = jsonEncode(data);

      final bool result = await googleSheetProvider.createUser(vr, infoUser);
      if (result) socketProvider.emitMessage(dataEnconde);

      return result;
  }

  @override
  Future<bool> deleteUser(String id, int index) async {
    Map data = {
      "msg": "Tabla modificada",
      "user": {"id": id, "index": index},
      "action": "delete",
      "columnsChanged": []
    };
    final bool result = await googleSheetProvider.deleteById(id, index);
    if (result) socketProvider.emitMessage(jsonEncode(data));
    return result;
  }

  @override
  Future<List<User>?> getAllUser() async {
    ValueRange data = await googleSheetProvider.getAll();

    List<Map<String, dynamic>>? allUsers =
        GoogleSheetHelpers.getDataFormated(data);

    final cleanUsers = allUsers
        .map((user) => User.fromJsontwo(user, allUsers.indexOf(user)))
        .where((user) => user.id != "")
        .toList();

    for (var user in cleanUsers) {
      user.comments.removeWhere((element) => element.isEmpty);
    }
    googleSheetProvider.getRowCount();

    return cleanUsers;
  }

  @override
  Future<bool> updateCellUser(String id, List<String> keys,
      List<String> newValues, int indexRow) async {
    if (keys.isEmpty) {
      return true;
    }

    Map data = {
      "msg": "Tabla modificada",
      "user": {
        "id": id,
        "index": indexRow,
      },
      "action": "update",
      "columnsChanged": keys
    };
    ValueRange vr;
    bool result=false;
    for (var element in keys) {
          vr = ValueRange.fromJson({
          "values": [
            [
              newValues[keys.indexOf(element)] 
            ]
          ]
        });

        String? range = "${UserFieldsGoogleSheet.getLettersColumns(element)}$indexRow";
        result = await googleSheetProvider.updateCellUser(id, keys, vr, range);
    }

    if (result) {
      socketProvider.emitMessage(jsonEncode(data));
    }
    return true;
  }

  int sum(int? i) {
    return (i! + 1);
  }

  @override
  Future<void> init() {
    return googleSheetProvider.init();
  }
}
