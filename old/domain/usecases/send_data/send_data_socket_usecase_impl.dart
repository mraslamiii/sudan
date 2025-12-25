import 'dart:async';

import 'package:bms/core/utils/communication_constants.dart';
import 'package:bms/data/data_sources/remote_data_sources/socket/socket.dart';
import 'package:bms/domain/usecases/send_data/send_data_socket_usecase.dart';

import '../../../core/utils/globals.dart';

class SendDataSocketUsecaseImpl extends SendDataSocketUsecase {
  bool _classLocked = false;
  final Socket _mSocket = Socket.instance;

  @override
  send(List<int> command) {
    _logger("send", 'Method called command:${command.join('-')}');

    if (_isClassLocked()) return;
    _lockTheClass();

    _mSocket.send(command);
  }

  @override
  sendString(String message) {
    _logger("sendString", 'Method called message: $message');

    if (_isClassLocked()) return;
    _lockTheClass();

    _mSocket.sendString(message);
  }

  _lockTheClass() {
    _classLocked = true;
    _updateTimer();
  }

  bool _isClassLocked() {
    _logger("_isClassLocked", ' _classLocked: $_classLocked');

    return _classLocked == true;
  }

  _updateTimer() {
    _logger("_updateTimer", 'Method called');
    Timer(const Duration(milliseconds: SocketConstants.sendDataSocketDelay), () {
      _logger("_updateTimer", 'un LockTheClass by timer');
      _unLockTheClass();
    });
  }

  _unLockTheClass() {
    _logger("unLockTheClass", 'Method called');

    _classLocked = false;
  }

  void _logger(String key, String value) {
    doLogGlobal('send_data_socket_usecase_impl. H:$hashCode', key, value);
  }
}
