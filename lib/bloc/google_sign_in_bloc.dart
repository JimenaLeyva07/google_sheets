import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_flutter_login_google/service/google_sheet_service.dart';
import 'package:local_flutter_login_google/service/service_google_sign_in.dart';

import '../helpers/local_storage_preferences.dart';

class GoogleSignInBloc {
  final GoogleSignInService googleSignInService;
  GoogleSignInBloc({required this.googleSignInService});
  GoogleSignInAccount? user;

  final _controllerStateUser = StreamController<GoogleSignInAccount?>();
  Stream<GoogleSignInAccount?> get streamStateUser =>
      _controllerStateUser.stream;
  final LocalStoragePreferences _prefs = LocalStoragePreferences();

  void listenChangeInfoUser() {
    googleSignInService.getGoogleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) {
      user = account;
      _prefs.userEmail = account?.email ?? '';

      _controllerStateUser.add(account);
    });
  }

  void handleSignIn() async {
    try {
      await googleSignInService.handleSignIn();
      initGoogleApis();
    } catch (e) {
      throw "$e";
    }
  }

  void initGoogleApis() async {
    await googleSheetService.init();
  }

  void handleSignOut() {
    googleSignInService.handleSignOut();
  }

  void signInSilently() async {
    GoogleSignInAccount? dataSilently =
        await googleSignInService.signInSilently();

    if (dataSilently != null) initGoogleApis();
  }
}
