import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_flutter_login_google/bloc/google_sign_in_bloc.dart';
import 'package:local_flutter_login_google/provider/provider_google_sign_in.dart';
import 'package:local_flutter_login_google/service/google_sheet_service.dart';
import 'package:local_flutter_login_google/service/service_google_sign_in.dart';
import 'package:local_flutter_login_google/ui/my_home_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'bloc/google_sheet_bloc.dart';
import 'helpers/local_storage_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final pref = LocalStoragePreferences();
  await pref.initPrefs();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GoogleSignInBloc googleSignInBloc =
      GoogleSignInBloc(googleSignInService: googleSignInService);

  late ConnectivityResult result;
  bool isFirstEjecutation = true;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    initConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (_) {
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MyInheritedWidget(
      googleSignInBloc: googleSignInBloc,
      googleSheetService: googleSheetService,
      googleSheetProvider: googleSignInProvider,
      googleSheetBloc: googleSheetBloc,
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyInheritedWidget extends InheritedWidget {
  const MyInheritedWidget({
    required this.googleSignInBloc,
    required this.googleSheetBloc,
    required this.googleSheetProvider,
    required this.googleSheetService,
    required Widget child,
    Key? key,
  }) : super(child: child, key: key);

  final GoogleSignInBloc googleSignInBloc;
  final GoogleSheetService googleSheetService;
  final GoogleSignInProvider googleSheetProvider;
  final GoogleSheetBloc googleSheetBloc;

  static MyInheritedWidget of(BuildContext context) =>
      context.findAncestorWidgetOfExactType<MyInheritedWidget>()!;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
