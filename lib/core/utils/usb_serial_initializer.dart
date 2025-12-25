import '../../core/di/injection_container.dart';
import '../../presentation/viewmodels/usb_serial_viewmodel.dart';
import 'package:usb_serial/usb_serial.dart';

/// USB Serial Initializer
/// Handles automatic USB Serial connection on app startup
class UsbSerialInitializer {
  static UsbSerialViewModel? _viewModel;
  static bool _isInitialized = false;

  /// Initialize USB Serial connection
  /// This should be called in main.dart after dependency injection
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _viewModel = getIt<UsbSerialViewModel>();

      // Try to connect to first available USB device
      final devices = await _viewModel!.getAvailableDevices();

      if (devices.isNotEmpty) {
        // Connect to first available device
        await _viewModel!.connect(device: devices.first, baudRate: 9600);
        print(
          '✅ [USB_SERIAL] Connected to device: ${devices.first.deviceName}',
        );
      } else {
        print('⚠️ [USB_SERIAL] No USB devices found');
      }

      _isInitialized = true;
    } catch (e) {
      print('❌ [USB_SERIAL] Failed to initialize: $e');
      // Don't throw - allow app to continue without USB connection
    }
  }

  /// Get the initialized ViewModel
  static UsbSerialViewModel? get viewModel => _viewModel;

  /// Check if USB Serial is initialized
  static bool get isInitialized => _isInitialized;

  /// Manually connect to a specific device
  static Future<void> connectToDevice(UsbDevice device, {int? baudRate}) async {
    if (_viewModel == null) {
      _viewModel = getIt<UsbSerialViewModel>();
    }

    await _viewModel!.connect(device: device, baudRate: baudRate ?? 9600);
  }

  /// Disconnect USB Serial
  static Future<void> disconnect() async {
    if (_viewModel != null) {
      await _viewModel!.disconnect();
    }
  }
}
