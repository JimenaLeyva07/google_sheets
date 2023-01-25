import 'package:google_sign_in/google_sign_in.dart';
import 'package:local_flutter_login_google/provider/provider_google_sign_in.dart';

GoogleSignInService googleSignInService =
    GoogleSignInService(googleSignInProvider: googleSignInProvider);

abstract class IGoogleSignInService {
  Future<void> handleSignOut();
  Future<void> handleSignIn();
  Future<void> signInSilently();
}

class GoogleSignInService implements IGoogleSignInService {
  final GoogleSignInProvider googleSignInProvider;

  GoogleSignInService({required this.googleSignInProvider});

  GoogleSignIn get getGoogleSignIn => googleSignInProvider.googleSignIn;

  @override
  Future<void> handleSignIn() async {
    await googleSignInProvider.handleSignIn();
  }

  @override
  Future<void> handleSignOut() async {
    await googleSignInProvider.handleSignOut();
  }

  @override
  Future<GoogleSignInAccount?> signInSilently() async {
    return await googleSignInProvider.signInSilently();
  }
}
