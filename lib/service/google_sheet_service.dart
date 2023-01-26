import 'package:local_flutter_login_google/provider/provider_google_sign_in.dart';

import '../model/student_model.dart';

import 'package:googleapis/classroom/v1.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:local_flutter_login_google/helpers/google_sheet_helpers.dart';
import 'package:local_flutter_login_google/model/courses_model.dart';

import '../model/user_model.dart';
import '../provider/google_sheet_data.dart';

GoogleSheetService googleSheetService = GoogleSheetService(
    googleSheetProvider: googleSheetProvider);

abstract class IGoogleSheetService {
  ///Create a user by obtaining their information
  ///Gets the last id of the spreadsheet to increment it by 1 and save the user with this id
  Future<bool> createUser(User infoUser);

  ///Gets all the information of all the users in the spreadsheet.
  ///Clean the data in case any information arrives that is empty.
  Future<List<Coursers>?> getAllCourses();

  ///Update some cells to a user
  Future<bool> updateCellUser(
      String id, List<String> keys, List<String> newValues, int indexRow);

  Future<void> init();
}

class GoogleSheetService implements IGoogleSheetService {
  GoogleSheetService(
      {required this.googleSheetProvider});

  final IGoogleSheetProvider googleSheetProvider;

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
    final bool result = await googleSheetProvider.createUser(vr, infoUser);
    return result;
  }

  @override
  Future<List<Coursers>?> getAllCourses() async {
    ValueRange data = await googleSheetProvider.getAllCourses();

    List<Map<String, dynamic>>? allCourses =
        GoogleSheetHelpers.getDataFormated(data);

    final cleanCourses = allCourses
        .map((course) => Coursers.fromJsontwo(course, allCourses.indexOf(course)))
        .where((course) => course.id != "")
        .toList();
    return cleanCourses;
  }


  @override
  Future<StudentModel> getUsers() async {
    ValueRange dataUsers  = await googleSheetProvider.getUsers();
    String filterEmail = googleSignInProvider.googleSignIn.currentUser!.email;
    List<Map<String,dynamic>> formatData =  GoogleSheetHelpers.getDataFormated(dataUsers);
    List<StudentModel> cleanStudent = formatData
        .map((student) => StudentModel.fromJsontwo(student, formatData.indexOf(student)))
        .where((student) => student.email == filterEmail )
        .toList();
    return cleanStudent.isNotEmpty ? cleanStudent[0]: StudentModel();
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
