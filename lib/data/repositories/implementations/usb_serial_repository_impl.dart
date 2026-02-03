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

/// Format one room as one line: id|name|order|floorId|icon|deviceIds|isGeneral.
String _roomToLine(Map<String, dynamic> room) {
  final id = (room['id'] as String?) ?? '';
  final name = (room['name'] as String?) ?? '';
  final order = (room['order'] as int?) ?? 0;
  final floorId = (room['floorId'] as String?) ?? '';
  final icon = (room['icon'] as String?) ?? 'home';
  final deviceIds = (room['deviceIds'] as List<dynamic>?)?.cast<String>() ?? [];
  final isGeneral = (room['isGeneral'] as bool?) ?? false;
  return '$id${UsbSerialConstants.fieldSep}$name${UsbSerialConstants.fieldSep}$order${UsbSerialConstants.fieldSep}$floorId${UsbSerialConstants.fieldSep}$icon${UsbSerialConstants.fieldSep}${deviceIds.join(UsbSerialConstants.listSep)}${UsbSerialConstants.fieldSep}${isGeneral ? '1' : '0'}';
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
      final completer = Completer<String>();
      late StreamSubscription<UsbSerialMessage> sub;
      sub = _usbSerialService.messageStream.listen((m) {
        if (m.type == UsbSerialConstants.msgTypeResponse &&
            !completer.isCompleted) {
          completer.complete(m.data);
        }
      });
      try {
        await _usbSerialService.sendRequest(UsbSerialConstants.requestFloors);
        final responseData = await completer.future.timeout(
          const Duration(milliseconds: UsbSerialConstants.connectionTimeout),
          onTimeout: () => throw TimeoutException('Floors response timeout'),
        );
        final list = _parseFloorsText(responseData);
        return list.isNotEmpty ? list : null;
      } finally {
        await sub.cancel();
      }
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
  Future<void> updateFloorOnMicro(Map<String, dynamic> floor) async {
    if (!_usbSerialService.isConnected) return;
    try {
      final line = _floorToLine(floor);
      final data =
          '${UsbSerialConstants.commandUpdateFloor}${UsbSerialConstants.recordSep}$line';
      await _usbSerialService.send(
        messageType: UsbSerialConstants.msgTypeCommand,
        data: data,
      );
    } catch (_) {
      // ignore
    }
  }

  @override
  Future<void> deleteFloorOnMicro(String floorId) async {
    if (!_usbSerialService.isConnected) return;
    try {
      final data =
          '${UsbSerialConstants.commandDeleteFloor}${UsbSerialConstants.recordSep}$floorId';
      await _usbSerialService.send(
        messageType: UsbSerialConstants.msgTypeCommand,
        data: data,
      );
    } catch (_) {
      // ignore
    }
  }

  @override
  Future<List<Map<String, dynamic>>?> requestRooms() async {
    if (!_usbSerialService.isConnected) return null;
    try {
      final completer = Completer<String>();
      late StreamSubscription<UsbSerialMessage> sub;
      sub = _usbSerialService.messageStream.listen((m) {
        if (m.type == UsbSerialConstants.msgTypeResponse &&
            !completer.isCompleted) {
          completer.complete(m.data);
        }
      });
      try {
        await _usbSerialService.sendRequest(UsbSerialConstants.requestRooms);
        final responseData = await completer.future.timeout(
          const Duration(milliseconds: UsbSerialConstants.connectionTimeout),
          onTimeout: () => throw TimeoutException('Rooms response timeout'),
        );
        final list = _parseRoomsText(responseData);
        return list.isNotEmpty ? list : null;
      } finally {
        await sub.cancel();
      }
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> createRoomOnMicro(Map<String, dynamic> room) async {
    if (!_usbSerialService.isConnected) return;
    try {
      final line = _roomToLine(room);
      final data =
          '${UsbSerialConstants.commandCreateRoom}${UsbSerialConstants.recordSep}$line';
      await _usbSerialService.send(
        messageType: UsbSerialConstants.msgTypeCommand,
        data: data,
      );
    } catch (_) {
      // ignore
    }
  }

  @override
  Future<void> updateRoomOnMicro(Map<String, dynamic> room) async {
    if (!_usbSerialService.isConnected) return;
    try {
      final line = _roomToLine(room);
      final data =
          '${UsbSerialConstants.commandUpdateRoom}${UsbSerialConstants.recordSep}$line';
      await _usbSerialService.send(
        messageType: UsbSerialConstants.msgTypeCommand,
        data: data,
      );
    } catch (_) {
      // ignore
    }
  }

  @override
  Future<void> deleteRoomOnMicro(String roomId) async {
    if (!_usbSerialService.isConnected) return;
    try {
      final data =
          '${UsbSerialConstants.commandDeleteRoom}${UsbSerialConstants.recordSep}$roomId';
      await _usbSerialService.send(
        messageType: UsbSerialConstants.msgTypeCommand,
        data: data,
      );
    } catch (_) {
      // ignore
    }
  }
}
