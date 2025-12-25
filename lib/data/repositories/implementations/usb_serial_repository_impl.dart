import 'dart:async';
import 'package:usb_serial/usb_serial.dart';
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
}
