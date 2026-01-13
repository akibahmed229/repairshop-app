import 'dart:async';
import 'package:repair_shop/core/secrets/app_secrets.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatSocketService {
  final StreamController<Map<String, dynamic>> messageController;

  ChatSocketService({required this.messageController});

  io.Socket? _socket;
  bool _isConnecting = false;

  Stream<Map<String, dynamic>> get messageStream => messageController.stream;

  void connect(String userId, String token) {
    // 1. GUARD: If socket exists and is connected, or is currently connecting, STOP.
    if ((_socket != null && _socket!.connected) || _isConnecting) return;

    _isConnecting = true;

    _socket = io.io(
      AppSecrets.backendUri,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      _isConnecting = false; // Reset guard
      print("Socket connected");
      _socket!.emit('join_room', userId);
    });

    // Handle connection errors/timeouts to reset the guard
    _socket!.onConnectError((data) {
      _isConnecting = false;
    });

    _socket!.on('receiver_message', (data) {
      if (!messageController.isClosed) {
        messageController.add(data as Map<String, dynamic>);
      }
    });
  }

  void diconnect() {
    print("Socket disconnected");
    _socket?.disconnect();
    _socket?.dispose(); // Proper cleanup
    _socket = null; // Clear the reference
    _isConnecting = false;
    // Note: Be careful closing the controller if you plan to reconnect later
    // If it's a singleton, you might want to keep the controller alive.
  }
}
