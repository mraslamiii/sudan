import 'dart:async';
import 'package:usb_serial/usb_serial.dart';
import '../../core/utils/usb_serial_protocol.dart';

abstract class UsbSerialRepository {
  /// Get list of available USB devices
  Future<List<UsbDevice>> getAvailableDevices();

  /// Connect to a USB device
  /// context: Android context for USB permission (optional)
  Future<void> connect({UsbDevice? device, int? baudRate, dynamic context});

  /// Disconnect from USB device
  Future<void> disconnect();

  /// Reconnect to USB device
  Future<void> reconnect();

  /// Check if connected
  bool isConnected();

  /// Send command
  Future<void> sendCommand(String command);

  /// Send request
  Future<void> sendRequest(String request);

  /// Send raw message with type
  Future<void> send({required int messageType, required String data});

  /// Stream of raw data bytes
  Stream<List<int>> get dataStream;

  /// Stream of decoded messages
  Stream<UsbSerialMessage> get messageStream;

  /// Stream of connection status
  Stream<String> get connectionStatusStream;
}
