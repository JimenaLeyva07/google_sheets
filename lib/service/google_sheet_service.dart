import 'package:local_flutter_login_google/provider/provider_google_sign_in.dart';

import '../model/student_model.dart';

import 'package:googleapis/classroom/v1.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:local_flutter_login_google/helpers/google_sheet_helpers.dart';

import '../model/user_model.dart';
import '../provider/google_sheet_data.dart';
import 'service_google_sign_in.dart';

GoogleSheetService googleSheetService =
    GoogleSheetService(googleSheetProvider: googleSheetProvider);

abstract class IGoogleSheetService {
  ///Create a user by obtaining their information
  ///Gets the last id of the spreadsheet to increment it by 1 and save the user with this id
  Future<bool> createUser(String email, String label);

  ///Gets all the information of all the users in the spreadsheet.
  ///Clean the data in case any information arrives that is empty.
  Future<Map<String, dynamic>?> getAllCourses();

  ///Update some cells to a user
  Future<bool> updateCellUser(
      List<int> index, List<int> uncheckedList, String columnUpdate);

  Future<void> init();
}

class GoogleSheetService implements IGoogleSheetService {
  GoogleSheetService({required this.googleSheetProvider});

  final IGoogleSheetProvider googleSheetProvider;

  final int _charCodeUnitA = 'A'.codeUnitAt(0);

  @override
  Future<bool> createUser(String email, String label) async {
    ValueRange vr = ValueRange.fromJson({
      "values": [
        [email]
      ]
    });
    final bool result = await googleSheetProvider.createUser(vr, label);
    return result;
  }

  @override
  Future<Map<String, dynamic>?> getAllCourses() async {
    String userEmail = googleSignInService.getGoogleSignIn.currentUser!.email;
    ValueRange data = await googleSheetProvider.getAllCourses();
    List<String> listColumn = [];
    List<int> checkedCourses = [];

    Map<String, dynamic> mapData = data.toJson();
    List<List<String>> rows = [];
    String columnLabel = "";

    for (var element in mapData["values"]) {
      rows.add(List<String>.from(element));
    }

    List<Map<String, dynamic>>? allCourses =
        GoogleSheetHelpers.getDataFormated(rows);

    final int indexUser =
        rows.indexWhere((element) => element.contains(userEmail));
    print(indexUser);

    if (indexUser == -1) {
      columnLabel = "${getColumnLabel(rows.length + 1)}1";
      createUser(userEmail, columnLabel);
    } else {
      columnLabel = getColumnLabel(indexUser + 1);
      listColumn = List<String>.from(mapData["values"][indexUser]);
      for (var i = 1; i < listColumn.length; i++) {
        if (listColumn[i] == 'X') {
          checkedCourses.add(i + 1);
        }
      }
    }

    rows[0].removeAt(0);

    Map<String, dynamic> generalInfo = {
      'courseList': rows[0],
      'checkedCourses': checkedCourses,
      'columnLabel': columnLabel
    };
    print(listColumn);
    return generalInfo;
  }

  @override
  Future<bool> updateCellUser(List<int> checkedIndex, List<int> uncheckedIndex,
      String columnUpdate) async {
    List<DataFilterValueRange> dataToSend = [];

    for (var element in checkedIndex) {
      DataFilterValueRange vr = DataFilterValueRange(
          dataFilter: DataFilter(a1Range: "CourseUsers!$columnUpdate$element"),
          values: [
            ["X"]
          ]);
      dataToSend.add(vr);
    }
    for (var element in uncheckedIndex) {
      DataFilterValueRange vr = DataFilterValueRange(
          dataFilter: DataFilter(a1Range: "CourseUsers!$columnUpdate$element"),
          values: [
            [""]
          ]);
      dataToSend.add(vr);
    }

    BatchUpdateValuesByDataFilterRequest sendToProvider =
        BatchUpdateValuesByDataFilterRequest(
            data: dataToSend, valueInputOption: 'USER_ENTERED');

    bool result = await googleSheetProvider.updateCellUser(sendToProvider);
    print(result);
    return result;
  }

  int sum(int? i) {
    return (i! + 1);
  }

  @override
  Future<void> init() {
    return googleSheetProvider.init();
  }

  String getColumnLabel(int index) {
    final res = <String>[];
    var block = index - 1;
    while (block >= 0) {
      res.insert(0, String.fromCharCode((block % 26) + _charCodeUnitA));
      block = block ~/ 26 - 1;
    }
    return res.join();
  }
}
