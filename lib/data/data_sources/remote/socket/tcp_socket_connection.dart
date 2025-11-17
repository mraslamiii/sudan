import 'dart:async';
import 'dart:io';
import 'dart:convert';

class TcpSocketConnection {
  String? _ipAddress;
  int? _portAddress;
  Socket? _server;
  bool _connected = false;
  bool _logPrintEnabled = false;
  Function(List<int>)? _dataCallback;
  Function? _onSocketConnectedCallback;
  Function(String)? _errorCallback;
  StreamSubscription? _streamSubscription;
  bool _isTryingToConnect = false;

  void setData(
    String ip,
    int port,
    Function(List<int>) dataCallback,
    Function onSocketConnectedCallback,
    Function(String) errorCallback,
  ) {
    _ipAddress = ip;
    _portAddress = port;
    _dataCallback = dataCallback;
    _onSocketConnectedCallback = onSocketConnectedCallback;
    _errorCallback = errorCallback;
  }

  void enableConsolePrint(bool enable) {
    _logPrintEnabled = enable;
  }

  Future<void> connect(int timeOut, int attempts) async {
    _printData('connect', 'attempts: $attempts, _isTryingToConnect: $_isTryingToConnect');

    if (_isTryingToConnect) return;

    _isTryingToConnect = true;
    await _doConnect(timeOut, attempts);
  }

  Future<void> _doConnect(int timeOut, int attempts) async {
    try {
      await _connectWithDelay(timeOut);
      _onConnected();
    } catch (e) {
      _onError(timeOut, attempts, e.toString());
    }
  }

  void _onConnected() {
    _connected = true;
    _isTryingToConnect = false;
    _printData('_onConnected', 'Socket successfully connected');

    _listenToSocket();
    _addErrorHandler();
    _onSocketConnectedCallback?.call();
  }

  void _listenToSocket() {
    _streamSubscription = _server?.listen(
      (List<int> event) {
        _printData('_listenToSocket', 'Data received: ${event.join('-')}');
        _dataCallback?.call(event);
      },
      onError: (error) {
        _printData('_listenToSocket', 'Error: $error');
        _errorCallback?.call(error.toString());
      },
    );
  }

  void _addErrorHandler() {
    _server?.handleError((error) {
      _printData('_addErrorHandler', 'Error occurred: $error');
      _connected = false;
      disconnect();
      _errorCallback?.call(error.toString());
    });
  }

  void _onError(int timeOut, int attempts, String error) {
    _printData('_onError', '$attempts attempt: Socket not connected - $error');

    if (attempts == 0) {
      _isTryingToConnect = false;
      _errorCallback?.call('Connection timeout');
    } else {
      _doConnect(timeOut, attempts - 1);
    }
  }

  Future<void> _connectWithDelay(int timeOut) async {
    await Future.delayed(const Duration(seconds: 1));
    _server = await Socket.connect(
      _ipAddress!,
      _portAddress!,
      timeout: Duration(milliseconds: timeOut),
    );
  }

  void reconnect() {
    connect(500, 10);
  }

  void disconnect() {
    _printData('disconnect', 'Method called');

    if (_server != null) {
      try {
        _streamSubscription?.cancel();
        _server?.close();
        _printData('disconnect', 'Socket closed');
      } catch (exception) {
        _printData('disconnect', 'ERROR: $exception');
      }
    }
    _connected = false;
  }

  bool isConnected() {
    return _connected;
  }

  void sendMessage(List<int> data) {
    if (_server != null && _connected) {
      _server!.add(data);
      _printData('sendMessage', 'Message sent: ${data.join('-')}');
    } else {
      _printData('sendMessage', 'Socket not connected');
      _errorCallback?.call('Socket not connected');
    }
  }

  void sendMessageString(String message) {
    if (_server != null && _connected) {
      _server!.add(utf8.encode(message));
      _printData('sendMessageString', 'Message sent: $message');
    } else {
      _printData('sendMessageString', 'Socket not connected');
      _errorCallback?.call('Socket not connected');
    }
  }

  void _printData(String where, String data) {
    if (_logPrintEnabled) {
      print('[TcpSocketConnection] $where: $data');
    }
  }
}

