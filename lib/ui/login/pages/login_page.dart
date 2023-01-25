import 'package:flutter/material.dart';
import 'package:local_flutter_login_google/main.dart';

import '../../google_sheet/show_users_google_sheet_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final bloc = MyInheritedWidget.of(context).googleSignInBloc;

  @override
  void initState() {
    super.initState();
    bloc.streamStateUser.listen((event) {
      if (event!.email.isNotEmpty) {
        Navigator.of(context).push(
          PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 850),
              transitionsBuilder: (_, animation, __, child) {
                return ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.elasticOut,
                  ),
                  child: child,
                );
              },
              pageBuilder: (_, animation, __) {
                return const ShowUsersGoogleSheetScreen();
              }),
        );
      }
    });
    bloc.listenChangeInfoUser();
    bloc.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    if (bloc.user != null) {
      return const SizedBox();
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          const Text('You are not currently signed in.'),
          ElevatedButton(
            onPressed: bloc.handleSignIn,
            child: const Text('SIGN IN'),
          ),
        ],
      );
    }
  }
}
