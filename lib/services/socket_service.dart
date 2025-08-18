import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect(String baseUrl, String token) {
    socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .disableAutoConnect()
          .build(),
    );
    socket.connect();
  }

  void on(String event, Function(dynamic) handler) => socket.on(event, (data) => handler(data));
  void emit(String event, dynamic data) => socket.emit(event, data);
  void disconnect() => socket.disconnect();
  bool get connected => socket.connected;
}
