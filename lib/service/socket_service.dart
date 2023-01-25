import '../provider/socket.dart';

abstract class ISocketService {
  Future<void> init();

  void emitMessage(String data);

  Stream<Map> get socketStream;
}

final SocketService socketService = SocketService(socketProvider);

class SocketService implements ISocketService {
  final SocketProvider socketProvider;

  SocketService(this.socketProvider);
  @override
  void emitMessage(String data) {
    socketProvider.emitMessage(data);
  }

  @override
  Future<void> init() async {
    return await socketProvider.init();
  }

  @override
  Stream<Map> get socketStream => socketProvider.socketStream;
}
