import 'dart:async';
import 'dart:io' show Socket;
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';
import '../../../../core/constants/usb_serial_constants.dart';
import '../../../../core/utils/usb_serial_protocol.dart';
import '../../../../core/error/exceptions.dart';

/// USB Serial Service
/// Handles communication with microcontroller via USB Serial (OTG)
class UsbSerialService {
  UsbSerialService._privateConstructor();
  static final UsbSerialService _instance =
      UsbSerialService._privateConstructor();
  static UsbSerialService get instance => _instance;

  UsbPort? _port;
  Socket? _tcpSocket;
  bool _isConnected = false;
  Timer? _heartbeatTimer;
  Timer? _ackTimeoutTimer;
  StreamSubscription<List<int>>? _inputStreamSubscription;

  final StreamController<List<int>> _dataStreamController =
      StreamController<List<int>>.broadcast();
  final StreamController<UsbSerialMessage> _messageStreamController =
      StreamController<UsbSerialMessage>.broadcast();
  final StreamController<String> _connectionStatusController =
      StreamController<String>.broadcast();

  final List<int> _buffer = [];
  UsbSerialMessage? _pendingMessage;

  Stream<List<int>> get dataStream => _dataStreamController.stream;
  Stream<UsbSerialMessage> get messageStream => _messageStreamController.stream;
  Stream<String> get connectionStatusStream =>
      _connectionStatusController.stream;

  bool get isConnected => _isConnected;

  /// Get list of available USB devices
  Future<List<UsbDevice>> getAvailableDevices() async {
    try {
      final devices = await UsbSerial.listDevices();
      return devices;
    } catch (e) {
      throw UsbSerialException('Failed to list USB devices: $e');
    }
  }

  /// Connect via TCP (for debug: tablet connected to laptop, adb reverse tcp:9999 tcp:9999)
  /// App on tablet connects to 127.0.0.1:port so traffic is forwarded to laptop simulator.
  Future<void> connectTcpDebug({
    String host = '127.0.0.1',
    int port = 9999,
  }) async {
    try {
      if (_isConnected) await disconnect();

      print('📋 [USB_SERIAL] Connecting to TCP $host:$port...');
      final socket = await Socket.connect(host, port);
      print('📋 [USB_SERIAL] TCP connected successfully');
      _tcpSocket = socket;
      _port = null;
      _isConnected = true;
      _connectionStatusController.add('connected');

      _startListeningTcp();
      print('📋 [USB_SERIAL] TCP listener started');
      _startHeartbeat();
      print('📋 [USB_SERIAL] Heartbeat started');
    } catch (e) {
      print('📋 [USB_SERIAL] TCP connection failed: $e');
      _isConnected = false;
      _connectionStatusController.add('error');
      throw UsbSerialException('TCP debug connection failed: $e');
    }
  }

  /// Connect to a USB device
  /// Note: For Android, you may need to request USB permission first
  Future<void> connect({
    UsbDevice? device,
    int? baudRate,
    dynamic context, // Android context for USB permission
  }) async {
    try {
      if (_isConnected) {
        await disconnect();
      }

      _tcpSocket = null;

      List<UsbDevice> devices;
      if (device != null) {
        devices = [device];
      } else {
        devices = await getAvailableDevices();
        if (devices.isEmpty) {
          throw const UsbSerialException('No USB devices found');
        }
        // Use first available device
        device = devices.first;
      }

      final deviceId = device.deviceId;
      if (deviceId == null) {
        throw const UsbSerialException('Device ID is null');
      }

      // UsbSerial.create may require context for Android permission handling
      // If context is provided, use it; otherwise try without
      if (context != null) {
        _port = await UsbSerial.create(deviceId, context);
      } else {
        _port = await UsbSerial.create(deviceId, 0); // Try with default context
      }

      if (_port == null) {
        throw const UsbSerialException('Failed to create USB port');
      }

      final opened = await _port!.open();
      if (!opened) {
        throw const UsbSerialException('Failed to open USB port');
      }

      // Configure serial port
      await _port!.setDTR(true);
      await _port!.setRTS(true);
      await _port!.setPortParameters(
        baudRate ?? UsbSerialConstants.defaultBaudRate,
        UsbSerialConstants.dataBits,
        UsbSerialConstants.stopBits,
        UsbSerialConstants.parity,
      );

      _isConnected = true;
      _connectionStatusController.add('connected');

      // Start listening to incoming data
      _startListening();

      // Start heartbeat
      _startHeartbeat();
    } catch (e) {
      _isConnected = false;
      _connectionStatusController.add('error');
      if (e is UsbSerialException) {
        rethrow;
      }
      throw UsbSerialException('Connection failed: $e');
    }
  }

  /// Start listening to incoming data (USB)
  void _startListening() {
    _inputStreamSubscription?.cancel();
    _inputStreamSubscription = _port?.inputStream?.listen(
      (List<int> data) {
        print('📥 [USB_SERIAL] Raw data received: ${data.length} bytes');
        _buffer.addAll(data);
        _processBuffer();
      },
      onError: (error) {
        _onError('Data receive error: $error');
      },
      cancelOnError: false,
    );
  }

  /// Start listening to incoming data (TCP debug)
  void _startListeningTcp() {
    _inputStreamSubscription?.cancel();
    final socket = _tcpSocket;
    if (socket == null) {
      print('📋 [USB_SERIAL] _startListeningTcp: socket is null');
      return;
    }
    print('📋 [USB_SERIAL] _startListeningTcp: Setting up listener');
    _inputStreamSubscription = socket.listen(
      (List<int> data) {
        print(
          '📥 [USB_SERIAL] TCP raw data received: ${data.length} bytes, first bytes: ${data.take(20).toList()}',
        );
        _buffer.addAll(data);
        _processBuffer();
      },
      onError: (error) {
        print('📴 [USB_SERIAL] TCP error: $error');
        _onError('TCP receive error: $error');
      },
      onDone: () {
        _isConnected = false;
        _connectionStatusController.add('disconnected');
        print('📴 [USB_SERIAL] TCP connection closed (onDone)');
      },
      cancelOnError: false,
    );
    print('📋 [USB_SERIAL] _startListeningTcp: Listener setup complete');
  }

  /// Process received data buffer
  void _processBuffer() {
    print('📋 [USB_SERIAL] _processBuffer: buffer length=${_buffer.length}');

    // If buffer is too large (more than 10KB), clear it to prevent memory issues
    if (_buffer.length > 10000) {
      print(
        '📋 [USB_SERIAL] Buffer too large (${_buffer.length} bytes), clearing',
      );
      _buffer.clear();
      return;
    }

    int decodeAttempts = 0;
    const maxDecodeAttempts = 100; // Prevent infinite loop

    while (UsbSerialProtocol.hasCompleteFrame(_buffer) &&
        decodeAttempts < maxDecodeAttempts) {
      decodeAttempts++;
      print('📋 [USB_SERIAL] Found complete frame, decoding...');
      final message = UsbSerialProtocol.decodeMessage(_buffer);

      if (message != null) {
        print(
          '📋 [USB_SERIAL] Message decoded: type=${message.type}, isAck=${message.isAck}, isNack=${message.isNack}, isHeartbeat=${message.isHeartbeat}',
        );
        // Remove processed frame from buffer
        int startIdx = _buffer.indexOf(UsbSerialConstants.frameStart);
        int endIdx = _buffer.indexOf(UsbSerialConstants.frameEnd, startIdx);
        if (endIdx != -1) {
          _buffer.removeRange(0, endIdx + 1);
        }

        // Handle ACK/NACK
        if (message.isAck || message.isNack) {
          print('📋 [USB_SERIAL] Received ACK/NACK');
          _ackTimeoutTimer?.cancel();
          _ackTimeoutTimer = null;
          if (_pendingMessage != null) {
            if (message.isAck) {
              // Message acknowledged
              _pendingMessage = null;
            } else {
              // Message not acknowledged, might need retry
              _pendingMessage = null;
            }
          }
        } else {
          // Send ACK for received message (only once)
          _sendRaw(UsbSerialProtocol.createAck());

          // Handle heartbeat - no need to emit, just ACK was sent above
          if (message.isHeartbeat) {
            print('📋 [USB_SERIAL] Received heartbeat');
            // Heartbeat acknowledged, no further action needed
          } else {
            final typeStr = message.type == UsbSerialConstants.msgTypeResponse
                ? 'RESPONSE'
                : message.type == UsbSerialConstants.msgTypeCommand
                ? 'COMMAND'
                : 'type=${message.type}';
            final dataPreview = message.data.length > 80
                ? '${message.data.substring(0, 80)}...'
                : message.data;
            print('📥 [USB_SERIAL] RX $typeStr data=$dataPreview');
            // Emit non-heartbeat messages
            _dataStreamController.add(message.data.codeUnits);
            _messageStreamController.add(message);
            print('📋 [USB_SERIAL] Message emitted to messageStream');
          }
        }
      } else {
        print(
          '📋 [USB_SERIAL] Failed to decode message, buffer length=${_buffer.length}',
        );
        // Invalid frame, remove the first byte and try again
        // This handles corrupted data or partial frames
        if (_buffer.isNotEmpty) {
          print('📋 [USB_SERIAL] Removing first byte and retrying');
          _buffer.removeAt(0);
          // Continue loop to try again
          continue;
        } else {
          print('📋 [USB_SERIAL] Buffer is empty, breaking');
          break;
        }
      }
    }

    if (decodeAttempts >= maxDecodeAttempts) {
      print('📋 [USB_SERIAL] Max decode attempts reached, clearing buffer');
      _buffer.clear();
    }
  }

  /// Send raw bytes
  void _sendRaw(List<int> data) {
    if (!_isConnected) {
      print('📋 [USB_SERIAL] _sendRaw: Not connected');
      return;
    }

    try {
      if (_tcpSocket != null) {
        print('📋 [USB_SERIAL] _sendRaw: Sending ${data.length} bytes via TCP');
        _tcpSocket!.add(Uint8List.fromList(data));
        // Flush so data is sent immediately; otherwise it may be buffered
        unawaited(_tcpSocket!.flush());
      } else if (_port != null) {
        print('📋 [USB_SERIAL] _sendRaw: Sending ${data.length} bytes via USB');
        _port!.write(Uint8List.fromList(data));
      } else {
        print('📋 [USB_SERIAL] _sendRaw: No connection available');
      }
    } catch (e) {
      print('📴 [USB_SERIAL] Send failed: $e');
      // اگر socket بسته شده، onDone را trigger نکن - فقط خطا را لاگ کن
      // چون onDone خودش از stream می‌آید
      if (_tcpSocket != null) {
        // اگر socket بسته شده، اتصال را قطع کن
        _isConnected = false;
        _connectionStatusController.add('disconnected');
      } else {
        _onError('Send error: $e');
      }
    }
  }

  /// Send a message with protocol framing
  Future<void> send({required int messageType, required String data}) async {
    if (!_isConnected || (_port == null && _tcpSocket == null)) {
      throw const UsbSerialException('USB Serial is not connected');
    }

    final frame = UsbSerialProtocol.encodeMessage(
      messageType: messageType,
      data: data,
    );

    _pendingMessage = UsbSerialMessage(type: messageType, data: data);

    // لاگ برای همهٔ درخواست/دستور (heartbeat لاگ نمی‌شود تا کنسول شلوغ نشود)
    if (messageType != UsbSerialConstants.msgTypeHeartbeat) {
      final typeStr = messageType == UsbSerialConstants.msgTypeRequest
          ? 'REQUEST'
          : messageType == UsbSerialConstants.msgTypeCommand
          ? 'COMMAND'
          : messageType == UsbSerialConstants.msgTypeResponse
          ? 'RESPONSE'
          : 'type=$messageType';
      final dataPreview = data.length > 80
          ? '${data.substring(0, 80)}...'
          : data;
      print('📤 [USB_SERIAL] TX $typeStr data=$dataPreview');
    }

    // Set ACK timeout
    _ackTimeoutTimer?.cancel();
    _ackTimeoutTimer = Timer(
      const Duration(milliseconds: UsbSerialConstants.ackTimeout),
      () {
        _ackTimeoutTimer = null;
        _pendingMessage = null;
        // Could implement retry logic here
      },
    );

    _sendRaw(frame);
  }

  /// Send command (compatible with existing socket commands)
  Future<void> sendCommand(String command) async {
    await send(messageType: UsbSerialConstants.msgTypeCommand, data: command);
  }

  /// Send request (compatible with existing socket requests)
  Future<void> sendRequest(String request) async {
    await send(messageType: UsbSerialConstants.msgTypeRequest, data: request);
  }

  /// Start heartbeat timer
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(milliseconds: UsbSerialConstants.heartbeatInterval),
      (timer) {
        if (_isConnected) {
          _sendRaw(UsbSerialProtocol.createHeartbeat());
        } else {
          timer.cancel();
        }
      },
    );
  }

  /// Stop heartbeat timer
  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Handle errors
  void _onError(String error) {
    _isConnected = false;
    _connectionStatusController.add('error');
    throw UsbSerialException(error);
  }

  /// Disconnect from USB device or TCP
  Future<void> disconnect() async {
    _stopHeartbeat();
    _ackTimeoutTimer?.cancel();
    _ackTimeoutTimer = null;

    await _inputStreamSubscription?.cancel();
    _inputStreamSubscription = null;

    await _port?.close();
    _port = null;
    await _tcpSocket?.close();
    _tcpSocket = null;
    _isConnected = false;
    _buffer.clear();
    _pendingMessage = null;
    _connectionStatusController.add('disconnected');
  }

  /// Reconnect to USB device
  Future<void> reconnect() async {
    if (_port != null && !_isConnected) {
      await connect(device: null);
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
    _dataStreamController.close();
    _messageStreamController.close();
    _connectionStatusController.close();
  }
}
