import 'package:local_flutter_login_google/service/service_google_sign_in.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

GoogleApiSheetProvider googleSheetProvider =
    GoogleApiSheetProvider(googleSignIn: googleSignInService.getGoogleSignIn);

abstract class IGoogleSheetProvider {
  Future init();
  Future<bool> addUserEmail(ValueRange vr, String columnLabel);
  Future<int> getRowCount();
  Future<ValueRange> getAllCourses();
  Future<ValueRange> getUsers();
  Future<bool> updateUser(
      int indexRow, Map<String, dynamic> user, List<String> columnsChanged);
  Future<bool> updateCellUser(BatchUpdateValuesByDataFilterRequest newValue);
}

class GoogleApiSheetProvider implements IGoogleSheetProvider {
  GoogleApiSheetProvider({required this.googleSignIn});

  GoogleSignIn googleSignIn;

  SheetsApi? sheetApi;
  String spreadsheetId = ('1pG5-bac1UzNWln-zMukyHL19vrdT8V6796RSAQeNk0Q');

  @override
  Future init() async {
    //Retrieve an [auth.AuthClient] from the current [GoogleSignIn] instance.
    try {
      final auth.AuthClient? client = await googleSignIn.authenticatedClient();

      assert(client != null, 'Authenticated client missing!');
      sheetApi = SheetsApi(client!);
    } catch (e) {
      throw "Error: $e";
    }
  }

  @override
  Future<ValueRange> getAllCourses() async {
    if (sheetApi == null) return ValueRange();
    // Ver todos los datos
    final data = await sheetApi!.spreadsheets.values
        .get(spreadsheetId, "CourseUsers", majorDimension: "COLUMNS");
    return data;
  }

  @override
  Future<ValueRange> getUsers() async {
    if (sheetApi == null) return ValueRange();
    final dataUsers = await sheetApi!.spreadsheets.values
        .get(spreadsheetId, "StudentProgress!A:D");
    return dataUsers;
  }

  @override
  Future<bool> addUserEmail(ValueRange vr, String columnLabel) async {
    if (sheetApi == null) return false;

    try {
      //Agrego datos
      sheetApi?.spreadsheets.values.append(
          vr, spreadsheetId, 'CourseUsers!$columnLabel',
          valueInputOption: 'USER_ENTERED');
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> getRowCount() async {
    final data =
        await sheetApi!.spreadsheets.values.get(spreadsheetId, "Users!A:D");

    int index = int.parse(data.values!.last[0] as String);

    return index;
  }

  @override
  Future<bool> updateCellUser(
      BatchUpdateValuesByDataFilterRequest newValue) async {
    if (sheetApi == null) return false;

    try {
      sheetApi!.spreadsheets.values
          .batchUpdateByDataFilter(newValue, spreadsheetId);
      return true;
    } catch (e) {
      return false;
    }
  }

  //No se implementa de momento
  @override
  Future<bool> updateUser(int indexRow, Map<String, dynamic> user,
      List<String> columnsChanged) async {
    if (sheetApi == null) return false;

    // TODO: implement updateUser
    throw UnimplementedError();
  }
}
