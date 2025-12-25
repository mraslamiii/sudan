import 'package:bms/core/eventbus/event_bus_const.dart';
import 'package:bms/core/eventbus/event_bus_model.dart';
import 'package:bms/core/utils/globals.dart';
import 'package:bms/data/data_sources/remote_data_sources/socket/tcp_socket_connection.dart';

import '../../../../core/utils/util.dart';
import '../../../enums/connection_error_code.dart';
import 'connection_requests/result.dart';

class Socket {
  TcpSocketConnection? _conn;

// Private constructor
  Socket._privateConstructor();

// Static private instance
  static final Socket _instance = Socket._privateConstructor();

  // Public static method to return the instance of the class
  static Socket get instance => _instance;

  connect(
      {required String ip,
      required int port,
      required Function(Result) resultCallback,
      required Function onSocketConnectedCallBack,
      required Function(List<int>) callback}) async {
    _logger('connect', 'ip : $ip - port: $port');

    _conn = TcpSocketConnection();

    dataCallback(List<int> data) async {
      _logger('connect', 'data : ${data.join('-')}');
      callback.call(data);
    }

    _conn?.setData(ip, port, dataCallback, onSocketConnectedCallBack, resultCallback);
    _conn?.enableConsolePrint(true);
    _conn?.connect(500, 10);
  }

  bool canReconnect() {
    _logger('canReconnect', '_conn : $_conn}');
    return _conn != null;
  }

  bool isConnected() {
    _logger('isConnected', '_conn : $_conn}');
    _logger('isConnected', 'status : ${_conn?.isConnected()}');

    return _conn?.isConnected() ?? false;
  }

  send(List<int> command) {
    if (isLoggerEnable) {
      List<String> bitArray = command.map((byte) => byte.toRadixString(2).padLeft(8, '0')).toList();
      _logger('send', 'command : ${bitArray.join(',')}');
    }
    if (isConnected()) {
      _conn?.sendMessage(command);
    } else {
      Utils.snackError('سوکت متصل نیست');
    }
  }

  sendString(String message) {
    _logger('sendString', 'message : $message');

    if (isConnected()) {
      _conn?.sendMessageString(message);
    } else {
      Utils.snackError('سوکت متصل نیست');
    }
  }

  disconnect() {
    _logger('disconnect', 'Method called');

    if (_conn != null) {
      _conn?.disconnect();

      _logger('disconnect', 'conn?.isConnected - status : ${_conn?.isConnected()}');
    }
  }

  reconnect() {
    _logger('reconnect', 'Method called');

    if (_conn != null && !_conn!.isConnected()) {
      _conn?.reconnect();
      _sendReconnectEvent();
      _logger('reconnect', 'conn?.isConnected - status : ${_conn?.isConnected()}');
    }
  }

  void _sendReconnectEvent() {
    eventBus.fire(EventBusModel(event: EventBusConst.eventSocketReconnect));
  }

  destroy() {
    _logger('destroy', 'Method called');
    disconnect();

    _conn = null;
    _logger('destroy', ' instances are : $_conn ');
  }

  void _logger(String key, String value) {
    doLogGlobal('socket. H:$hashCode', key, value);
  }
}
