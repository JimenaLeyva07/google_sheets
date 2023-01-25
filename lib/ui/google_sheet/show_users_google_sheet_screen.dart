import 'dart:convert';

import 'package:flutter/material.dart';

import '../../bloc/google_sheet_bloc.dart';
import '../../main.dart';
import '../../model/user_model.dart';
import '../widgets/alerts_dialog_widget.dart';
import '../widgets/custom_user_item.dart';
import 'create_user_screen.dart';

class ShowUsersGoogleSheetScreen extends StatefulWidget {
  const ShowUsersGoogleSheetScreen({Key? key}) : super(key: key);

  @override
  State<ShowUsersGoogleSheetScreen> createState() =>
      _ShowUsersGoogleSheetScreenState();
}

class _ShowUsersGoogleSheetScreenState
    extends State<ShowUsersGoogleSheetScreen> {
  late final GoogleSheetBloc googleSheetBloc =
      MyInheritedWidget.of(context).googleSheetBloc;

  @override
  void initState() {
    super.initState();

    googleSheetBloc.getAllUsers();
    googleSheetBloc.streamDeleteUser.listen((wasDelete) {
      if (wasDelete) {
        _showMyDialogSuccesed();
      } else {
        _showMyDialogFailed();
      }
    });
    googleSheetBloc.socketStream.listen((event) {
      handleSocket(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _navigateToCreateUserScreen(),
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: 35.0, vertical: 10.0),
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                ),
                child: const Center(child: Text('Create User')),
              ),
            ),
          ),
          StreamBuilder(
            stream: googleSheetBloc.streamListUser,
            builder: ((context, AsyncSnapshot<List<User>> snapshot) {
              if (snapshot.hasData) {
                final List<User> data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const Text(
                      'Actualmente no tiene datos la hoja de excel');
                }
                return Expanded(
                  child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return UserCustomItem(
                            user: data[index],
                            index: index,
                            function: () {
                              googleSheetBloc.deleteUser(data[index].id ?? '',
                                  data[index].indexRow ?? 0);
                            });
                      }),
                );
              }
              return const CircularProgressIndicator();
            }),
          ),
        ],
      ),
    );
  }

  Future<void> handleSocket(Map datos) async {
    if (datos['msg'] == "Tabla modificada") {
      await googleSheetBloc.getAllUsers();
      if (datos["action"] != "create") {
        googleSheetBloc.saveUserInfo(datos["user"]["id"], jsonEncode(datos));
      }
    }
  }

  void _navigateToCreateUserScreen() {
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
            return const CreateUserScreen();
          }),
    );
  }

  Future<void> _showMyDialogSuccesed() async {
    return AlertDialogWidget.showCustomDialog(
        context: context,
        title: 'Usuario eliminado',
        description: 'El usuario fue eliminado con exito de la hoja excel',
        action: () {
          googleSheetBloc.getAllUsers();
          Navigator.of(context).pop();
        },
        titleButton: 'Continuar');
  }

  Future<void> _showMyDialogFailed() async {
    return AlertDialogWidget.showCustomDialog(
        context: context,
        title: 'Error eliminando',
        description: 'Ocurrio un error en la eliminacion del usuario',
        action: () {
          googleSheetBloc.getAllUsers();
          Navigator.of(context).pop();
        },
        titleButton: 'Volver');
  }
}
