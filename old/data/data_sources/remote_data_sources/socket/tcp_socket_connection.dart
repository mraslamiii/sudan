library tcp_socket_connection;

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import '../../../../core/utils/globals.dart';
import '../../../enums/connection_error_code.dart';
import 'connection_requests/result.dart';

class TcpSocketConnection {
  late String _ipAddress;
  late int _portAddress;
  Socket? _server;
  bool _connected = false;
  bool _logPrintEnabled = false;
  late Function _mDataCallback;
  late Function _mOnSocketConnectedCallBack;
  late  Function(Result) _mResultCallback;
  StreamSubscription? _mStreamSubscription;
  bool _isTryingToConnect = false;

  /// Initializes class data
  ///  * @param  ip  the server's ip you are trying to connect to
  ///  * @param  port the servers's port you are trying to connect to
  setData(String ip, int port, Function dataCallback, Function onSocketConnectedCallBack,
        Function(Result) resultCallback) {
    _ipAddress = ip;
    _portAddress = port;
    _mDataCallback = dataCallback;
    _mOnSocketConnectedCallBack = onSocketConnectedCallBack;
    _mResultCallback = resultCallback;
  }

  /// Shows events in the console with print method
  /// * @param  enable if set to true, then events will be printed in the console
  enableConsolePrint(bool enable) {
    _logPrintEnabled = enable;
  }

/*
  /// Initializes the connection. Socket starts listening to server for data.
  /// 'callback' function will be called when 'eom' is received
  ///
  ///  * @param  timeOut  amount of time to attempt the connection in milliseconds
  ///  * @param  separator  sequence of characters to use between commands
  ///  * @param  eom  sequence of characters at the end of each single message
  ///  * @param  callback  function called when received a message. It must take 2 'String' as params. The first one is the command received, the second one is the message itself.
  ///  * @param  attempts  number of attempts before stop trying to connect. Default is 1.
  connectWithCommand(int timeOut, String separator, String eom,  Function callback, {int attempts=1}) async{
    if(_ipAddress==null){
      print("Class not initialized. You must call the constructor!");
      return;
    }
    _eom=eom;
    _separator=separator;
    int k=1;
    while(k<=attempts){
      try{
        _server = await Socket.connect(_ipAddress, _portAddress, timeout: new Duration(milliseconds: timeOut));
        break;
      }catch(Exception){
        _printData(k.toString()+" attempt: Socket not connected (Timeout reached)");
        if(k==attempts){
          return;
        }
      }
      k++;
    }
    _connected=true;
    _printData("Socket successfully connected");
    String message="";
    _server.listen((List<int> event) async {
      message += (utf8.decode(event));
      if(message.contains(eom)){
        List<String> commands=message.split(_separator);
        _printData("Message received: "+message);
        callback(commands[0],commands[1].split(eom)[0]);
        if(commands[1].split(eom).length>1){
          message=commands[1].split(eom)[1];
        }else{
          message="";
        }
      }
    });
  }*/

  /// Initializes the connection. Socket starts listening to server for data
  /// 'callback' function will be called whenever data is received. The developer elaborates the message received however he wants
  /// No separator is used to split message into parts
  ///  * @param  timeOut  the amount of time to attempt the connection in milliseconds
  ///  * @param  callback  the function called when received a message. It must take a 'String' as param which is the message received
  ///  * @param  attempts  the number of attempts before stop trying to connect. Default is 1.
  connect(int timeOut, int attempts) async {
    _printData('connect', "attempts : $attempts _isTryingToConnect $_isTryingToConnect");

    if (_isTryingToConnect == true) return;

    _isTryingToConnect = true;
    _doConnect(timeOut, attempts);
  }

  _doConnect(int timeOut, int attempts) async {
    _connectWithDelay(timeOut)
        .then((_) => {_onConnected()})
        .catchError((_) => {_onError(timeOut, attempts)});
  }

  _onConnected() {
    _connected = true;
    _isTryingToConnect = false;
    _printData(
        '_onConnected', "Socket successfully connected - Start listening _server obj: $_server");

    listenToSocket();
    _addErrorHandler();
    _mOnSocketConnectedCallBack.call();
  }

  void listenToSocket() {
    _mStreamSubscription = _server?.listen((List<int> event) async {
      _printData('listenToSocket', "listen happened: ${event.join('-')}");

      try {
        String received = (utf8.decode(event));
        _printData('listenToSocket', "listen received: $received");
      } catch (e) {}
      _mDataCallback.call(event);
    });
  }

  _addErrorHandler() {
    _printData('_addErrorHandler', 'Init  _server?.handleError()');

    // Add an error handler
    _server?.handleError((error) {
      _printData('_addErrorHandler', 'Method called');

      _connected = false;
      disconnect();

      if (error is SocketException) {
        _printData('_addErrorHandler', 'Connection closed by the other side');
        _mResultCallback.call(Result.failure( ConnectionErrorCode.socketClosedByOtherSide));
      } else {
        _printData('_addErrorHandler', 'An error occurred: $error');
        _mResultCallback.call(Result.failure( ConnectionErrorCode.errorInSocket));
      }
    });
  }

  _onError(timeOut, attempts) {
    _printData('_onError', "$attempts attempt: Socket not connected (Timeout reached)");

    if (attempts == 0) {
      _isTryingToConnect = false;
      _mResultCallback.call(Result.failure( ConnectionErrorCode.timeoutNotConnected));
    } else {
      attempts--;
      _doConnect(timeOut, attempts);
    }
  }

  Future _connectWithDelay(int timeOut) async {
    Completer statusCompleter = Completer();

    Timer(const Duration(seconds: 1), () async {
      try {
        _server = await Socket.connect(_ipAddress, _portAddress,
            timeout: Duration(milliseconds: timeOut));

        statusCompleter.complete();
      } catch (ex) {
        statusCompleter.completeError(ex);
      }
    });

    return statusCompleter.future;
  }

  void reconnect() {
    connect(500, 10);
  }

  /// Stops the connection and close the socket
  void disconnect() {
    _printData('disconnect', "Method called");

    if (_server != null) {
      try {
        _mStreamSubscription?.cancel();
        _printData('disconnect', "_mStreamSubscription got cancelled");

        _server?.close();
        _printData('disconnect', "Socket close called");
      } catch (exception) {
        _printData('disconnect', "ERROR : $exception");
      }
    }
    _connected = false;
  }

  /// Initializes the connection. Socket starts listening to server for data
  /// 'callback' function will be called when 'eom' is received
  ///  * @param  the timeOut  amount of time to attempt the connection in milliseconds
  ///  * @param  the eom  sequence of characters at the end of each single message
  ///  * @param  the callback  function called when received a message. It must take a 'String' as param which is the message received
  ///  * @param  the attempts  number of attempts before stop trying to connect. Default is 1
  connectEOM(int timeOut, String eom, Function callback, {int attempts = 1}) async {
    int k = 1;
    while (k <= attempts) {
      try {
        _server = await Socket.connect(_ipAddress, _portAddress,
            timeout: Duration(milliseconds: timeOut));
        break;
      } catch (exception) {
        _printData('connectEOM', "$k attempt: Socket not connected (Timeout reached)");
        if (k == attempts) {
          return;
        }
      }
      k++;
    }
    _connected = true;
    _printData('connectEOM', "Socket successfully connected");
    StringBuffer message = StringBuffer();
    _server!.listen((List<int> event) async {
      String received = (utf8.decode(event));
      message.write(received);
      if (received.contains(eom)) {
        _printData('connectEOM', "Message received: $message");

        List<String> messages = message.toString().split(eom);
        if (!received.endsWith(eom)) {
          message.clear();
          message.write(messages.last);
          messages.removeLast();
        } else {
          message.clear();
        }
        for (String m in messages) {
          callback(m);
        }
      }
    });
  }

  /// Checks if the socket is connected
  bool isConnected() {
    return _connected;
  }

  /// Sends a message to server. Make sure to have established a connection before calling this method
  /// Message will be sent as 'message'
  ///  * @param  message  message to send to server
  void sendMessage(List<int> data) async {
    if (_server != null && _connected) {
      _server!.add(data);
      //_printData("Message sent: "+message);
    } else {
      _printData('sendMessage',
          "Socket not initialized before sending message! Make sure you have already called the method 'connect()'");
    }
  }

  void sendMessageString(String message) async {
    if (_server != null && _connected) {
      _server!.add(utf8.encode(message));
      //_printData("Message sent: "+message);
    } else {
      _printData('sendMessageString',
          "Socket not initialized before sending message! Make sure you have already called the method 'connect()'");
    }
  }

  /// Sends a message to server. Make sure to have established a connection before calling this method
  /// Message will be sent as 'message'+'eom'
  ///  * @param  message  the message to send to server
  ///  * @param  eom  the end of message to send to server
  void sendMessageEOM(String message, String eom) async {
    if (_server != null && _connected) {
      _server!.add(utf8.encode(message + eom));
      _printData('sendMessageEOM', "Message sent: $message$eom");
    } else {
      _printData('sendMessageEOM',
          "Socket not initialized before sending message! Make sure you have already called the method 'connect()'");
    }
  }

/*
  /// Send message to server with a command. Make sure to have established a connection before calling this method. Never use this if the connection is established with the 'simpleConnnect()' method
  /// Message will be sent as 'command'+'separator'+'message'+'separator'+'eom'
  ///  * @param  message  message to send to server
  ///  * @param  command  tells the server what to do with the message
  void sendMessageWithCommand(String message, String command) async{
    if(_server!=null){
      _server.add(utf8.encode(command+_separator+message+_separator+_eom));
      _printData("Message sent: "+command+_separator+message+_separator+_eom);
    }else{
      print("Socket not initialized before sending message! Make sure you have alreadt called the method 'connect()'");
    }
  }*/

  /// Test the connection. It will try to connect to the endpoint and if it does, it will disconnect and return 'true' (otherwise false)
  ///  * @param  timeOut  the amount of time to attempt the connection in milliseconds
  ///  * @param  attempts  the number of attempts before stop trying to connect. Default is 1.
  Future<bool> canConnect(int timeOut, {int attempts = 1}) async {
    int k = 1;
    while (k <= attempts) {
      try {
        _server = await Socket.connect(_ipAddress, _portAddress,
            timeout: Duration(milliseconds: timeOut));
        disconnect();
        return true;
      } catch (exception) {
        _printData('canConnect', "$k attempt: Socket not connected (Timeout reached)");
        if (k == attempts) {
          disconnect();
          return false;
        }
      }
      k++;
    }
    disconnect();
    return false;
  }

  void _printData(String where, String data) {
    if (_logPrintEnabled) {
      doLogGlobal('tcp_socket_connection. H:$hashCode', where, data);
    }
  }
}
