import 'dart:async';
import '../../../../core/constants/socket_constants.dart';
import '../../../../core/error/exceptions.dart';
import 'tcp_socket_connection.dart';

class SocketService {
  SocketService._privateConstructor();
  static final SocketService _instance = SocketService._privateConstructor();
  static SocketService get instance => _instance;

  TcpSocketConnection? _connection;
  bool _isConnected = false;
  final StreamController<List<int>> _dataStreamController = StreamController<List<int>>.broadcast();
  final StreamController<String> _connectionStatusController = StreamController<String>.broadcast();

  Stream<List<int>> get dataStream => _dataStreamController.stream;
  Stream<String> get connectionStatusStream => _connectionStatusController.stream;

  bool get isConnected => _isConnected;

  Future<void> connect({
    String? ip,
    int? port,
  }) async {
    final targetIp = ip ?? SocketConstants.defaultIp;
    final targetPort = port ?? SocketConstants.defaultPort;

    _connection = TcpSocketConnection();
    _connection!.enableConsolePrint(true);

    _connection!.setData(
      targetIp,
      targetPort,
      _onDataReceived,
      _onSocketConnected,
      _onError,
    );

    await _connection!.connect(
      SocketConstants.sendSocketByDelay,
      SocketConstants.connectionRequestsDelay,
    );
  }

  void _onDataReceived(List<int> data) {
    _dataStreamController.add(data);
  }

  void _onSocketConnected() {
    _isConnected = true;
    _connectionStatusController.add('connected');
  }

  void _onError(String error) {
    _isConnected = false;
    _connectionStatusController.add('error');
    throw SocketException(error);
  }

  void send(List<int> command) {
    if (!_isConnected || _connection == null) {
      throw const SocketException('Socket is not connected');
    }
    _connection!.sendMessage(command);
  }

  void sendString(String message) {
    if (!_isConnected || _connection == null) {
      throw const SocketException('Socket is not connected');
    }
    _connection!.sendMessageString(message);
  }

  void disconnect() {
    _connection?.disconnect();
    _isConnected = false;
    _connectionStatusController.add('disconnected');
  }

  void reconnect() {
    if (_connection != null && !_connection!.isConnected()) {
      _connection!.reconnect();
    }
  }

  void dispose() {
    disconnect();
    _dataStreamController.close();
    _connectionStatusController.close();
  }
}

