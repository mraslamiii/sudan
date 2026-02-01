import 'dart:async';
import 'package:usb_serial/usb_serial.dart';
import '../../../../core/utils/usb_serial_protocol.dart';
import '../../../../domain/repositories/usb_serial_repository.dart';

/// Mock USB Serial Repository for testing without real microcontroller.
/// Use "Simulate connection" in USB panel (Debug) to connect; then room list
/// is returned from this mock when app requests rooms.
class MockUsbSerialRepositoryImpl implements UsbSerialRepository {
  bool _connected = false;

  final StreamController<List<int>> _dataStreamController =
      StreamController<List<int>>.broadcast();
  final StreamController<UsbSerialMessage> _messageStreamController =
      StreamController<UsbSerialMessage>.broadcast();
  final StreamController<String> _connectionStatusController =
      StreamController<String>.broadcast();

  static List<Map<String, dynamic>> get _sampleFloors => [
    {
      'id': 'floor_1',
      'name': 'طبقه اول',
      'order': 0,
      'roomIds': <String>['room_living', 'room_kitchen', 'room_bathroom'],
      'icon': 'layers',
    },
    {
      'id': 'floor_2',
      'name': 'طبقه دوم',
      'order': 1,
      'roomIds': <String>['room_bedroom'],
      'icon': 'layers',
    },
  ];

  static List<Map<String, dynamic>> get _sampleRooms => [
    {
      'id': 'room_general',
      'name': 'عمومی',
      'order': -1,
      'floorId': null,
      'icon': 'home',
      'deviceIds': <String>[],
      'isGeneral': true,
    },
    {
      'id': 'room_living',
      'name': 'اتاق نشیمن',
      'order': 0,
      'floorId': 'floor_1',
      'icon': 'living',
      'deviceIds': <String>[],
      'isGeneral': false,
    },
    {
      'id': 'room_kitchen',
      'name': 'آشپزخانه',
      'order': 1,
      'floorId': 'floor_1',
      'icon': 'kitchen',
      'deviceIds': <String>[],
      'isGeneral': false,
    },
    {
      'id': 'room_bedroom',
      'name': 'اتاق خواب',
      'order': 0,
      'floorId': 'floor_2',
      'icon': 'bedroom',
      'deviceIds': <String>[],
      'isGeneral': false,
    },
  ];

  @override
  Future<List<UsbDevice>> getAvailableDevices() async => [];

  @override
  Future<void> connect({
    UsbDevice? device,
    int? baudRate,
    dynamic context,
  }) async {
    _connected = true;
    _connectionStatusController.add('connected');
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    _connectionStatusController.add('disconnected');
  }

  @override
  Future<void> reconnect() async {
    if (_connected) {
      _connectionStatusController.add('connected');
    }
  }

  @override
  bool isConnected() => _connected;

  @override
  Future<void> sendCommand(String command) async {}

  @override
  Future<void> sendRequest(String request) async {}

  @override
  Future<void> send({required int messageType, required String data}) async {}

  @override
  Stream<List<int>> get dataStream => _dataStreamController.stream;

  @override
  Stream<UsbSerialMessage> get messageStream => _messageStreamController.stream;

  @override
  Stream<String> get connectionStatusStream =>
      _connectionStatusController.stream;

  @override
  Future<List<Map<String, dynamic>>?> requestFloors() async {
    if (!_connected) return null;
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_sampleFloors);
  }

  @override
  Future<void> createFloorOnMicro(Map<String, dynamic> floor) async {
    if (!_connected) return;
    await Future.delayed(const Duration(milliseconds: 50));
    // Mock: no-op; micro would store the floor
  }

  @override
  Future<List<Map<String, dynamic>>?> requestRooms() async {
    if (!_connected) return null;
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_sampleRooms);
  }
}
