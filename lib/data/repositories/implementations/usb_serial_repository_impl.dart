import 'dart:async';
import 'package:usb_serial/usb_serial.dart';
import '../../../../core/constants/usb_serial_constants.dart';
import '../../../../domain/repositories/usb_serial_repository.dart';
import '../../../../core/utils/usb_serial_protocol.dart';
import '../../data_sources/remote/usb_serial/usb_serial_service.dart';

/// Parse text response: one line per floor, format id|name|order|roomIds (roomIds comma-sep).
List<Map<String, dynamic>> _parseFloorsText(String text) {
  final list = <Map<String, dynamic>>[];
  final lines = text.split(UsbSerialConstants.recordSep);
  for (final line in lines) {
    final t = line.trim();
    if (t.isEmpty) continue;
    final parts = t.split(UsbSerialConstants.fieldSep);
    if (parts.length < 4) continue;
    final roomIds = parts[3].isEmpty
        ? <String>[]
        : parts[3]
              .split(UsbSerialConstants.listSep)
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
    list.add({
      'id': parts[0],
      'name': parts[1],
      'order': int.tryParse(parts[2]) ?? 0,
      'roomIds': roomIds,
    });
  }
  return list;
}

/// Format one floor as one line: id|name|order|roomIds.
String _floorToLine(Map<String, dynamic> floor) {
  final id = (floor['id'] as String?) ?? '';
  final name = (floor['name'] as String?) ?? '';
  final order = (floor['order'] as int?) ?? 0;
  final roomIds = (floor['roomIds'] as List<dynamic>?)?.cast<String>() ?? [];
  return '$id${UsbSerialConstants.fieldSep}$name${UsbSerialConstants.fieldSep}$order${UsbSerialConstants.fieldSep}${roomIds.join(UsbSerialConstants.listSep)}';
}

/// Parse text response: one line per room, format id|name|order|floorId|icon|deviceIds|isGeneral.
List<Map<String, dynamic>> _parseRoomsText(String text) {
  final list = <Map<String, dynamic>>[];
  final lines = text.split(UsbSerialConstants.recordSep);
  for (final line in lines) {
    final t = line.trim();
    if (t.isEmpty) continue;
    final parts = t.split(UsbSerialConstants.fieldSep);
    if (parts.length < 7) continue;
    final deviceIds = parts[5].isEmpty
        ? <String>[]
        : parts[5]
              .split(UsbSerialConstants.listSep)
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
    list.add({
      'id': parts[0],
      'name': parts[1],
      'order': int.tryParse(parts[2]) ?? 0,
      'floorId': parts[3].isEmpty ? null : parts[3],
      'icon': parts[4].isEmpty ? 'home' : parts[4],
      'deviceIds': deviceIds,
      'isGeneral': parts[6] == '1' || parts[6].toLowerCase() == 'true',
    });
  }
  return list;
}

class UsbSerialRepositoryImpl implements UsbSerialRepository {
  final UsbSerialService _usbSerialService;

  UsbSerialRepositoryImpl(this._usbSerialService);

  @override
  Future<List<UsbDevice>> getAvailableDevices() async {
    return await _usbSerialService.getAvailableDevices();
  }

  @override
  Future<void> connect({
    UsbDevice? device,
    int? baudRate,
    dynamic context,
  }) async {
    await _usbSerialService.connect(
      device: device,
      baudRate: baudRate,
      context: context,
    );
  }

  @override
  Future<void> disconnect() async {
    await _usbSerialService.disconnect();
  }

  @override
  Future<void> reconnect() async {
    await _usbSerialService.reconnect();
  }

  @override
  bool isConnected() {
    return _usbSerialService.isConnected;
  }

  @override
  Future<void> sendCommand(String command) async {
    await _usbSerialService.sendCommand(command);
  }

  @override
  Future<void> sendRequest(String request) async {
    await _usbSerialService.sendRequest(request);
  }

  @override
  Future<void> send({required int messageType, required String data}) async {
    await _usbSerialService.send(messageType: messageType, data: data);
  }

  @override
  Stream<List<int>> get dataStream => _usbSerialService.dataStream;

  @override
  Stream<UsbSerialMessage> get messageStream => _usbSerialService.messageStream;

  @override
  Stream<String> get connectionStatusStream =>
      _usbSerialService.connectionStatusStream;

  @override
  Future<List<Map<String, dynamic>>?> requestFloors() async {
    if (!_usbSerialService.isConnected) return null;
    try {
      final responseFuture = _usbSerialService.messageStream
          .where((m) => m.type == UsbSerialConstants.msgTypeResponse)
          .map((m) => m.data)
          .timeout(
            const Duration(milliseconds: UsbSerialConstants.connectionTimeout),
            onTimeout: (sink) =>
                sink.addError(TimeoutException('Floors response timeout')),
          )
          .first;

      await _usbSerialService.sendRequest(UsbSerialConstants.requestFloors);
      final responseData = await responseFuture;

      final list = _parseFloorsText(responseData);
      return list.isNotEmpty ? list : null;
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createFloorOnMicro(Map<String, dynamic> floor) async {
    if (!_usbSerialService.isConnected) return;
    try {
      final line = _floorToLine(floor);
      final data =
          '${UsbSerialConstants.commandCreateFloor}${UsbSerialConstants.recordSep}$line';
      await _usbSerialService.send(
        messageType: UsbSerialConstants.msgTypeCommand,
        data: data,
      );
    } catch (_) {
      // ignore – micro may not be listening
    }
  }

  @override
  Future<List<Map<String, dynamic>>?> requestRooms() async {
    if (!_usbSerialService.isConnected) return null;
    try {
      // Listen for response first so we don't miss it, then send request
      final responseFuture = _usbSerialService.messageStream
          .where((m) => m.type == UsbSerialConstants.msgTypeResponse)
          .map((m) => m.data)
          .timeout(
            const Duration(milliseconds: UsbSerialConstants.connectionTimeout),
            onTimeout: (sink) =>
                sink.addError(TimeoutException('Rooms response timeout')),
          )
          .first;

      await _usbSerialService.sendRequest(UsbSerialConstants.requestRooms);
      final responseData = await responseFuture;

      final list = _parseRoomsText(responseData);
      return list.isNotEmpty ? list : null;
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
