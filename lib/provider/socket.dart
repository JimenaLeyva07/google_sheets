import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../bloc/google_sheet_bloc.dart';

SocketProvider socketProvider = SocketProvider();

class SocketProvider {
  Socket? socket;
  GoogleSheetBloc? googleSheetBloc;

  final StreamController<Map> _socketController =
      StreamController<Map>.broadcast();

  Stream<Map> get socketStream => _socketController.stream;

  Future<void> init() async {
    socket = await Socket.connect("192.168.1.1", 3003);
    socket!.listen(
      (Uint8List data) async {
        final serverResponse = String.fromCharCodes(data);
        Map datos = jsonDecode(serverResponse);
        _socketController.sink.add(datos);
      },
      onError: (error) async {
        await _closeSocket();
        socket!.destroy();
      },
      onDone: () {
        socket!.destroy();
      },
    );
  }

  void emitMessage(String data) {
    socket!.write(data);
  }

  Future<void> _closeSocket() async {
    socket!.write('disconect');
  }
}
