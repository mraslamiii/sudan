import 'package:usb_serial/usb_serial.dart';
import '../repositories/usb_serial_repository.dart';

class ConnectUsbSerialUseCase {
  final UsbSerialRepository _usbSerialRepository;

  ConnectUsbSerialUseCase(this._usbSerialRepository);

  /// Get available USB devices
  Future<List<UsbDevice>> getAvailableDevices() async {
    return await _usbSerialRepository.getAvailableDevices();
  }

  /// Connect to USB device
  /// context: Android context for USB permission (optional)
  Future<void> execute({
    UsbDevice? device,
    int? baudRate,
    dynamic context,
  }) async {
    await _usbSerialRepository.connect(
      device: device,
      baudRate: baudRate,
      context: context,
    );
  }

  /// Disconnect from USB device
  Future<void> disconnect() async {
    await _usbSerialRepository.disconnect();
  }

  /// Reconnect to USB device
  Future<void> reconnect() async {
    await _usbSerialRepository.reconnect();
  }

  /// Check if connected
  bool isConnected() {
    return _usbSerialRepository.isConnected();
  }
}
