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

  /// Request floor list from microcontroller via USB.
  /// Sends request and waits for response (JSON array of floor objects).
  /// Returns parsed list of floor maps, or null on timeout/failure/disconnect.
  /// Expected response format: [{"id":"floor_1","name":"...","order":0,"roomIds":[]}, ...]
  Future<List<Map<String, dynamic>>?> requestFloors();

  /// Notify microcontroller that a new floor was created (command + JSON).
  /// Payload should include action, id, name, order, roomIds, icon.
  Future<void> createFloorOnMicro(Map<String, dynamic> floor);

  /// Request room list from microcontroller via USB.
  /// Sends request and waits for response (JSON array of room objects).
  /// Returns parsed list of room maps, or null on timeout/failure/disconnect.
  /// Expected response format: [{"id":"room_1","name":"...","order":0,"floorId":"...","icon":"living"}, ...]
  Future<List<Map<String, dynamic>>?> requestRooms();
}
