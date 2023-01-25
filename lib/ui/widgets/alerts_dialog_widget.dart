import 'package:flutter/material.dart';

class AlertDialogWidget {
  static Future<void> showMyDialogSuccesed({
    required BuildContext context,
    required String title,
    required String description,
    required Function() action,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(description),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: action,
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showCustomDialog(
      {required BuildContext context,
      required String title,
      required String description,
      required Function() action,
      required String titleButton}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(description),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: action,
              child: Text(titleButton),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showMyDialogFailed({
    required BuildContext context,
    required String title,
    required String description,
    required Function() action,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(description),
                const Text('Si el error continua contactese con Talent Pool'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: action,
              child: const Text('Volver'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showMyDialogConfirmateUpdate({
    required BuildContext context,
    required String title,
    required String description,
    required Function() allowAction,
    required Function() dismissAction,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(description),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => dismissAction(),
              child: const Text('No Aceptar'),
            ),
            TextButton(
              onPressed: () => allowAction(),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }
}
