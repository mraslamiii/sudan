import 'dart:async';
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

  /// Start listening to incoming data
  void _startListening() {
    _inputStreamSubscription?.cancel();
    _inputStreamSubscription = _port?.inputStream?.listen(
      (List<int> data) {
        _buffer.addAll(data);
        _processBuffer();
      },
      onError: (error) {
        _onError('Data receive error: $error');
      },
      cancelOnError: false,
    );
  }

  /// Process received data buffer
  void _processBuffer() {
    while (UsbSerialProtocol.hasCompleteFrame(_buffer)) {
      final message = UsbSerialProtocol.decodeMessage(_buffer);

      if (message != null) {
        // Remove processed frame from buffer
        int startIdx = _buffer.indexOf(UsbSerialConstants.frameStart);
        int endIdx = _buffer.indexOf(UsbSerialConstants.frameEnd, startIdx);
        if (endIdx != -1) {
          _buffer.removeRange(0, endIdx + 1);
        }

        // Handle ACK/NACK
        if (message.isAck || message.isNack) {
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
            // Heartbeat acknowledged, no further action needed
          } else {
            // Emit non-heartbeat messages
            _dataStreamController.add(message.data.codeUnits);
            _messageStreamController.add(message);
          }
        }
      } else {
        // Invalid frame, try to find next STX
        int startIdx = _buffer.indexOf(UsbSerialConstants.frameStart);
        if (startIdx > 0) {
          _buffer.removeRange(0, startIdx);
        } else if (startIdx == -1) {
          _buffer.clear(); // No valid frame start found
        } else {
          break; // Wait for more data
        }
      }
    }
  }

  /// Send raw bytes
  void _sendRaw(List<int> data) {
    if (!_isConnected || _port == null) {
      return;
    }

    try {
      _port!.write(Uint8List.fromList(data));
    } catch (e) {
      _onError('Send error: $e');
    }
  }

  /// Send a message with protocol framing
  Future<void> send({required int messageType, required String data}) async {
    if (!_isConnected || _port == null) {
      throw const UsbSerialException('USB Serial is not connected');
    }

    final frame = UsbSerialProtocol.encodeMessage(
      messageType: messageType,
      data: data,
    );

    _pendingMessage = UsbSerialMessage(type: messageType, data: data);

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

  /// Disconnect from USB device
  Future<void> disconnect() async {
    _stopHeartbeat();
    _ackTimeoutTimer?.cancel();
    _ackTimeoutTimer = null;

    // Cancel input stream subscription
    await _inputStreamSubscription?.cancel();
    _inputStreamSubscription = null;

    await _port?.close();
    _port = null;
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
