import 'dart:async';
import 'package:usb_serial/usb_serial.dart';
import '../../../../core/constants/usb_serial_constants.dart';
import '../../../../domain/repositories/usb_serial_repository.dart';
import '../../../../core/utils/usb_serial_protocol.dart';
import '../../data_sources/remote/usb_serial/usb_serial_service.dart';

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

      final decoded = json.decode(responseData);
      if (decoded is! List) return null;
      final list = decoded
          .whereType<Map<String, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
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
      final data = json.encode(floor);
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

      final decoded = json.decode(responseData);
      if (decoded is! List) return null;
      final list = decoded
          .whereType<Map<String, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      return list.isNotEmpty ? list : null;
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
