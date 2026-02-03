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
  /// Sends request and waits for response (text lines, no JSON).
  /// Returns parsed list of floor maps, or null on timeout/failure/disconnect.
  /// Expected response: one line per floor, format id|name|order|roomIds (roomIds comma-sep).
  Future<List<Map<String, dynamic>>?> requestFloors();

  /// Send create-floor command to microcontroller (text line: id|name|order|roomIds).
  Future<void> createFloorOnMicro(Map<String, dynamic> floor);

  /// Send update-floor command to microcontroller (text line: id|name|order|roomIds).
  Future<void> updateFloorOnMicro(Map<String, dynamic> floor);

  /// Send delete-floor command to microcontroller (floor id).
  Future<void> deleteFloorOnMicro(String floorId);

  /// Request room list from microcontroller via USB.
  /// Sends request and waits for response (text lines, no JSON).
  /// Returns parsed list of room maps, or null on timeout/failure/disconnect.
  /// Expected response: one line per room, format id|name|order|floorId|icon|deviceIds|isGeneral.
  Future<List<Map<String, dynamic>>?> requestRooms();

  /// Send create-room command to microcontroller.
  Future<void> createRoomOnMicro(Map<String, dynamic> room);

  /// Send update-room command to microcontroller.
  Future<void> updateRoomOnMicro(Map<String, dynamic> room);

  /// Send delete-room command to microcontroller (room id).
  Future<void> deleteRoomOnMicro(String roomId);
}
