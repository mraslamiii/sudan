import 'dart:async';
import '../../../../domain/repositories/socket_repository.dart';
import '../../data_sources/remote/socket/socket_service.dart';

class SocketRepositoryImpl implements SocketRepository {
  final SocketService _socketService;

  SocketRepositoryImpl(this._socketService);

  @override
  Future<void> connect({String? ip, int? port}) async {
    await _socketService.connect(ip: ip, port: port);
  }

  @override
  void disconnect() {
    _socketService.disconnect();
  }

  @override
  void reconnect() {
    _socketService.reconnect();
  }

  @override
  bool isConnected() {
    return _socketService.isConnected;
  }

  @override
  void send(List<int> command) {
    _socketService.send(command);
  }

  @override
  void sendString(String message) {
    _socketService.sendString(message);
  }

  @override
  Stream<List<int>> get dataStream => _socketService.dataStream;

  @override
  Stream<String> get connectionStatusStream => _socketService.connectionStatusStream;
}

