import '../model/user_model.dart';
import 'package:local_flutter_login_google/service/service_google_sign_in.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

GoogleApiSheetProvider googleSheetProvider =
    GoogleApiSheetProvider(googleSignIn: googleSignInService.getGoogleSignIn);

abstract class IGoogleSheetProvider {
  Future init();
  Future<bool> createUser(ValueRange rowList, User infoUser);
  Future<int> getRowCount();
  Future<ValueRange> getAll();
  Future<bool> updateUser(
      int indexRow, Map<String, dynamic> user, List<String> columnsChanged);
  Future<bool> deleteById(String id, int indexRow);
  Future<bool> updateCellUser(
      String id, List<String> keyUpdate, ValueRange newValue, String indexRow);
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
  Future<ValueRange> getAll() async {
    if (sheetApi == null) return ValueRange();
    // Ver todos los datos
    final data = await sheetApi!.spreadsheets.values.get(spreadsheetId, "Users!A:D");

    return data;
  }

  @override
  Future<bool> createUser(ValueRange rowList, User infoUser) async {
    if (sheetApi == null) return false;
    if (infoUser.id == '') return false;

     try {
      //Agrego datos
      sheetApi?.spreadsheets.values
        .append(rowList, spreadsheetId, 'Users', valueInputOption: 'USER_ENTERED');
       return true;
     } catch (e) {
       return false;
     }
  }
  
  
  @override
  Future<bool> deleteById(String id, int indexRow) async {
    if (sheetApi == null) return false;
    
    try {
      await sheetApi?.spreadsheets.values
          .clear(ClearValuesRequest(), spreadsheetId, "A$indexRow:D$indexRow");
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
  Future<bool> updateCellUser(String id, List<String> keyUpdate,
      ValueRange newValue, String indexRow) async {

      if (sheetApi == null) return false;  

      try {
        sheetApi!.spreadsheets.values.update(newValue, spreadsheetId, indexRow, valueInputOption: 'USER_ENTERED');
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

// class GoogleSheetProvider implements IGoogleSheetProvider {
//   static const _credential = r'''
//       {
//       "type": "service_account",
//       "project_id": "login-with-b510f",
//       "private_key_id": "d5cbc4e0af206e6a1df54598a51999c09933eafb",
//       "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQD74cP49bsbx2yZ\nqRimb4yfMJeNwgn756Xna7zd9E8J3rpqVhrYaobANBE4zk0+Bn32rwWUnMBxAaA1\nGcnGv2sNRX/ZwWhUZ+28gyf0SysZL7m81Yg812lQcQvUs/AKl3JKcCG4aGQ9+jym\nrm/W4p5gdQ3QNGsWXHUZ49SYmCvPGsYSYPykQJLg2Ljd3Nn1bBWmXXALh2EVT+Cx\n4MfsZixt3ON9iiF9Sih9Lw3lsOGYw0+snh5vo6cep80rLxNb6F0Oj6BenW4FQFBT\npq3WBC5b+oWAn1RPathmajaM1D00tzp6Zf6tAOu73Yx9MR6WnLCFQK/j+UiOnIcO\nkb3FgtBFAgMBAAECggEAFrrGzn6ORfF3EV67BLnoPK1L39T0xbCfvgRw5K6ZO1DI\nDbR7c7AZPNr1+uRTABfh4hLlNAX5L7lv1ZrgJHk9ldMBuIrFeWhvgaVsQ5VM7Fbs\nMegrBSKDNGkfIjCiprIH9EOuJ0/0S8t7EaeIHCITHK0zc+hnCXuKba2rj6GbwnKA\nPMJcWFH9RLe5LSAV239Yq77jfTcO1LzQiCmsWyNVfLtKLg/F2P7mMUldQtmbDbdx\n2yxnN+rfx/J/9v2NE5JrRFhNj38LItTQQkFIzHPKKwvaOt9ZOq1bv3ZsncPUqbfg\nK99iHywmPZqFnyaKK2HnVgTmjMkIusikmzCSrNCF+QKBgQD+fRh0EUtCYEC7gB6a\nZxCp27LXwGo3nhQ3z9gnIoOeMx07oPU6g2HVYP08+d4lj68/3wcbTlf+46InoECX\nsaQybVQFfp4yLD86DUgbHwPaM/okzsfaeVjIqLFqIWi1KuOgdVkYJDmfY3Qmoy+q\np5Y4iQcV3Z9NCE6CTNghI8oNBwKBgQD9YLT2lJa05de2gwCFhq+8sPkQdDaGtw24\nbIso2SKuFgHunvFeEa7f3y3PWoOcHnDNHToZ4pyd+q9sKoJDK4se/uy9bUKPqC22\nTevRD0gSaQSQifMAi2sKmQHG9Q3Aw5dv9J7da4Ey0RAsYWaZ20h+ZSSKG9cERslT\nohMMgxvxUwKBgHxjZq1suo1iAKHlGJA9qi5r/TlpikFPGfDBvZQ7UXvk3fgET3jf\nONWUB5NjSkqvtWgRuiaFn4stdlfKA2hh4rDnMTdSUT6S1ACq90CSY06nMzAEhjjq\nMRQ7KCSI2eYbZZFLalXbdvLKKL6t6qGOMmXFzFnKro93bPBRYR6poJvHAoGAen/3\n3cNG/Zyl5wp9BRFyA3M4Z1kYR5dW3dQ0j4IzPyFKu9hCb61y86+OEVL8kE0zUieQ\nQJWMDOD3UP9YTStPLqQnRwn9BUFVIG+Z1FBkEuqNF2hqgNfm34/MCSnPBWRK4gjN\nidWA+FWVUS+iED6xVNKHkPIWyW2Dxph0RzdYGhsCgYB+FMjJC4N5cybFO1gEf3rH\nvYUKYfWtVi5bK2pzwGBxN4BFTAh/bI2M2b9nIiHzxeNws9jQ80SBWtXB1iM8RL4B\nSadGX3WVNURG41wV+fKvGcdTHbivVaVbUclQhUlUFYOEaM+SlEH4mwYdwhmHQ8BZ\nDn2+KHMTs7faftHwUW8DaQ==\n-----END PRIVATE KEY-----\n",
//       "client_email": "testgooglesheets@login-with-b510f.iam.gserviceaccount.com",
//       "client_id": "101747916206975066890",
//       "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//       "token_uri": "https://oauth2.googleapis.com/token",
//       "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
//       "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/testgooglesheets%40login-with-b510f.iam.gserviceaccount.com"
//     }
//   ''';

//   final _spreadSheetId = "1pG5-bac1UzNWln-zMukyHL19vrdT8V6796RSAQeNk0Q";

//   final _googleSheet = GSheets(_credential);

//   Worksheet? _userSheet;

//   ///Obtiene acceso al archivo y tambien obtiene la hoja de calculo
//   @override
//   Future init() async {
//     try {
//       final spreadSheet = await _googleSheet.spreadsheet(_spreadSheetId);
//       _userSheet = await _getWorkSheet(spreadSheet, title: 'Users');

//       ///Obtiene los nombres de las columnas y si no existe los inserta
//       final firstRow = UserFieldsGoogleSheet.getFields();
//       _userSheet!.values.insertRow(1, firstRow);
//     } catch (_) {}
//   }

//   ///Crea u obtiene la hoja de calculo con la que se trabajara
//   Future<Worksheet> _getWorkSheet(Spreadsheet spreadsheet,
//       {required String title}) async {
//     try {
//       return await spreadsheet.addWorksheet(title);
//     } catch (e) {
//       return spreadsheet.worksheetByTitle(title)!;
//     }
//   }

//   ///Crea Usuario
//   @override
//   Future<bool> createUser(User rowList) async {
//     if (_userSheet == null) return false;

//     if (rowList.id == '') return false;

//     try {
//       await _userSheet!.values.map.appendRow(rowList.tojson(rowList.comments));
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   ///Obtener ultima posicion
//   @override
//   Future<int> getRowCount() async {
//     if (_userSheet == null) return 0;

//     final lastRow = await _userSheet!.values.lastRow();
//     if (lastRow == null) return 0;
//     return int.tryParse(lastRow.first) ?? 0;
//   }

//   ///Obtener todos los usuario
//   @override
//   Future<List<Map<String, String>>?> getAll() async {
//     if (_userSheet == null) return [{}];

//     final List<Map<String, String>>? json =
//         await _userSheet?.values.map.allRows();

//     return json ?? [{}];
//   }

//   ///Actualiza un usuario dado su id
//   @override
//   Future<bool> updateUser(int indexRow, Map<String, dynamic> user,
//       List<String> columnsChanged) async {
//     if (_userSheet == null) return false;

//     try {
//       await _userSheet?.values.map.insertRow(indexRow, user);

//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   ///Elimina un usuario
//   @override
//   Future<bool> deleteById(String id, int indexRow) async {
//     if (_userSheet == null) return false;
//     try {
//       int? index = await _userSheet?.values.rowIndexOf(id);
//       await _userSheet!.deleteRow(index ?? 0);
//       return true;
//     } catch (e) {
//       return false;
//     }
//   }

//   //Funciones segundarias

//   ///Actualizar una celda en concreto.
//   ///id = para buscar el registro que se va a actualizar
//   ///keyUpdate = El nombre de la columna que se quiere cambiar
//   ///newValue: La informacion con la que se va a acutalizar en el campo elegido
//   @override
//   Future<bool> updateCellUser(String id, List<String> keyUpdate,
//       List<String> newValue, int indexRow) async {
//     if (_userSheet == null) return false;

//     try {
//       for (var key in keyUpdate) {
//         await _userSheet!.values.insertValueByKeys(
//             newValue[keyUpdate.indexOf(key)],
//             columnKey: key,
//             rowKey: id);
//       }

//       return true;
//     } catch (e) {
//       return false;
//     }
//   }
// }
