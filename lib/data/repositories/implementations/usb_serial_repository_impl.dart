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
  Future<void> connectTcpDebug({
    String host = '127.0.0.1',
    int port = 9999,
  }) async {
    await _usbSerialService.connectTcpDebug(host: host, port: port);
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

  /// فقط وقتی پاسخ مربوط به لیست طبقات است complete کن (جلوگیری از قاطی شدن با requestRooms)
  static bool _isFloorsResponse(String data) {
    if (data.isEmpty) {
      print('📋 [USB_SERIAL] _isFloorsResponse: data is empty');
      return false;
    }
    final hasFloor = data.contains('floor_');
    final hasFieldSep = data.contains(UsbSerialConstants.fieldSep);
    print(
      '📋 [USB_SERIAL] _isFloorsResponse: hasFloor=$hasFloor, hasFieldSep=$hasFieldSep, data=${data.substring(0, data.length > 100 ? 100 : data.length)}',
    );
    return hasFloor && hasFieldSep;
  }

  /// فقط وقتی پاسخ مربوط به لیست اتاق‌ها است complete کن
  static bool _isRoomsResponse(String data) {
    if (data.isEmpty) return false;
    return data.contains('room_') && data.contains(UsbSerialConstants.fieldSep);
  }

  @override
  Future<List<Map<String, dynamic>>?> requestFloors() async {
    if (!_usbSerialService.isConnected) return null;
    print('📋 [USB_SERIAL] REQUEST requestFloors');
    try {
      final completer = Completer<String>();
      late StreamSubscription<UsbSerialMessage> sub;

      // Create subscription BEFORE sending request to avoid missing the response
      sub = _usbSerialService.messageStream.listen((m) {
        print(
          '📋 [USB_SERIAL] messageStream received: type=${m.type}, data=${m.data.substring(0, m.data.length > 50 ? 50 : m.data.length)}...',
        );
        if (m.type == UsbSerialConstants.msgTypeResponse &&
            !completer.isCompleted &&
            _isFloorsResponse(m.data)) {
          print('📋 [USB_SERIAL] Completing with floors response');
          completer.complete(m.data);
        }
      });

      // Small delay to ensure subscription is ready
      await Future.delayed(const Duration(milliseconds: 50));

      try {
        await _usbSerialService.sendRequest(UsbSerialConstants.requestFloors);
        final responseData = await completer.future.timeout(
          const Duration(milliseconds: UsbSerialConstants.connectionTimeout),
          onTimeout: () => throw TimeoutException('Floors response timeout'),
        );
        final list = _parseFloorsText(responseData);
        print('📋 [USB_SERIAL] RESPONSE requestFloors count=${list.length}');
        return list.isNotEmpty ? list : null;
      } finally {
        await sub.cancel();
      }
    } on TimeoutException {
      print('📋 [USB_SERIAL] requestFloors TIMEOUT');
      return null;
    } catch (e) {
      print('📋 [USB_SERIAL] requestFloors ERROR: $e');
      return null;
    }
  }

  @override
  Future<void> createFloorOnMicro(Map<String, dynamic> floor) async {
    if (!_usbSerialService.isConnected) return;
    print('📋 [USB_SERIAL] REQUEST createFloorOnMicro id=${floor['id']}');
    try {
      final line = _floorToLine(floor);
      final data =
          '${UsbSerialConstants.commandCreateFloor}${UsbSerialConstants.recordSep}$line';
      await _usbSerialService.send(
        messageType: UsbSerialConstants.msgTypeCommand,
        data: data,
      );
      print('📋 [USB_SERIAL] SENT createFloorOnMicro');
    } catch (e) {
      print('📋 [USB_SERIAL] createFloorOnMicro ERROR: $e');
    }
  }

  @override
  Future<void> updateFloorOnMicro(Map<String, dynamic> floor) async {
    if (!_usbSerialService.isConnected) return;
    print('📋 [USB_SERIAL] REQUEST updateFloorOnMicro id=${floor['id']}');
    try {
      final line = _floorToLine(floor);
      final data =
          '${UsbSerialConstants.commandUpdateFloor}${UsbSerialConstants.recordSep}$line';
      await _usbSerialService.send(
        messageType: UsbSerialConstants.msgTypeCommand,
        data: data,
      );
      print('📋 [USB_SERIAL] SENT updateFloorOnMicro');
    } catch (e) {
      print('📋 [USB_SERIAL] updateFloorOnMicro ERROR: $e');
    }
  }

  @override
  Future<void> deleteFloorOnMicro(String floorId) async {
    if (!_usbSerialService.isConnected) return;
    print('📋 [USB_SERIAL] REQUEST deleteFloorOnMicro floorId=$floorId');
    try {
      final data =
          '${UsbSerialConstants.commandDeleteFloor}${UsbSerialConstants.recordSep}$floorId';
      await _usbSerialService.send(
        messageType: UsbSerialConstants.msgTypeCommand,
        data: data,
      );
      print('📋 [USB_SERIAL] SENT deleteFloorOnMicro');
    } catch (e) {
      print('📋 [USB_SERIAL] deleteFloorOnMicro ERROR: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>?> requestRooms(String floorId) async {
    if (!_usbSerialService.isConnected) return null;
    print('📋 [USB_SERIAL] REQUEST requestRooms floorId=$floorId');
    try {
      final completer = Completer<String>();
      late StreamSubscription<UsbSerialMessage> sub;
      sub = _usbSerialService.messageStream.listen((m) {
        if (m.type == UsbSerialConstants.msgTypeResponse &&
            !completer.isCompleted &&
            _isRoomsResponse(m.data)) {
          completer.complete(m.data);
        }
      });
      try {
        final requestData =
            '${UsbSerialConstants.requestRoomsPrefix}$floorId';
        await _usbSerialService.sendRequest(requestData);
        final responseData = await completer.future.timeout(
          const Duration(milliseconds: UsbSerialConstants.connectionTimeout),
          onTimeout: () => throw TimeoutException('Rooms response timeout'),
        );
        final list = _parseRoomsText(responseData);
        print('📋 [USB_SERIAL] RESPONSE requestRooms count=${list.length}');
        return list.isNotEmpty ? list : null;
      } finally {
        await sub.cancel();
      }
    } on TimeoutException {
      print('📋 [USB_SERIAL] requestRooms TIMEOUT');
      return null;
    } catch (e) {
      print('📋 [USB_SERIAL] requestRooms ERROR: $e');
      return null;
    }
  }

  @override
  Future<void> createRoomOnMicro(Map<String, dynamic> room) async {
    if (!_usbSerialService.isConnected) return;
    print('📋 [USB_SERIAL] REQUEST createRoomOnMicro id=${room['id']}');
    try {
      final line = _roomToLine(room);
      final data =
          '${UsbSerialConstants.commandCreateRoom}${UsbSerialConstants.recordSep}$line';
      await _usbSerialService.send(
        messageType: UsbSerialConstants.msgTypeCommand,
        data: data,
      );
      print('📋 [USB_SERIAL] SENT createRoomOnMicro');
    } catch (e) {
      print('📋 [USB_SERIAL] createRoomOnMicro ERROR: $e');
    }
  }

  @override
  Future<void> updateRoomOnMicro(Map<String, dynamic> room) async {
    if (!_usbSerialService.isConnected) return;
    print('📋 [USB_SERIAL] REQUEST updateRoomOnMicro id=${room['id']}');
    try {
      final line = _roomToLine(room);
      final data =
          '${UsbSerialConstants.commandUpdateRoom}${UsbSerialConstants.recordSep}$line';
      await _usbSerialService.send(
        messageType: UsbSerialConstants.msgTypeCommand,
        data: data,
      );
      print('📋 [USB_SERIAL] SENT updateRoomOnMicro');
    } catch (e) {
      print('📋 [USB_SERIAL] updateRoomOnMicro ERROR: $e');
    }
  }

  @override
  Future<void> deleteRoomOnMicro(String roomId) async {
    if (!_usbSerialService.isConnected) return;
    print('📋 [USB_SERIAL] REQUEST deleteRoomOnMicro roomId=$roomId');
    try {
      final data =
          '${UsbSerialConstants.commandDeleteRoom}${UsbSerialConstants.recordSep}$roomId';
      await _usbSerialService.send(
        messageType: UsbSerialConstants.msgTypeCommand,
        data: data,
      );
      print('📋 [USB_SERIAL] SENT deleteRoomOnMicro');
    } catch (e) {
      print('📋 [USB_SERIAL] deleteRoomOnMicro ERROR: $e');
    }
  }
}
