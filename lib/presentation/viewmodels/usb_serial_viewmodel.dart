import 'dart:async';
import 'package:usb_serial/usb_serial.dart';
import '../../core/base/base_viewmodel.dart';
import '../../domain/repositories/usb_serial_repository.dart';
import '../../domain/use_cases/connect_usb_serial_use_case.dart';
import '../../domain/use_cases/send_usb_serial_command_use_case.dart';
import '../../core/utils/usb_serial_protocol.dart';

/// ViewModel for USB Serial communication
class UsbSerialViewModel extends BaseViewModel {
  final UsbSerialRepository _usbSerialRepository;
  final ConnectUsbSerialUseCase _connectUseCase;
  final SendUsbSerialCommandUseCase _sendCommandUseCase;

  StreamSubscription<List<int>>? _dataSubscription;
  StreamSubscription<UsbSerialMessage>? _messageSubscription;
  StreamSubscription<String>? _statusSubscription;

  bool _usbConnected = false;
  bool get isUsbConnected => _usbConnected;

  String _connectionStatus = 'disconnected';
  String get connectionStatus => _connectionStatus;

  UsbSerialMessage? _lastReceivedMessage;
  UsbSerialMessage? get lastReceivedMessage => _lastReceivedMessage;

  UsbSerialViewModel(
    this._usbSerialRepository,
    this._connectUseCase,
    this._sendCommandUseCase,
  ) {
    _listenToConnectionStatus();
    _listenToMessages();
  }

  void _listenToConnectionStatus() {
    _statusSubscription = _usbSerialRepository.connectionStatusStream.listen((
      status,
    ) {
      _connectionStatus = status;
      _usbConnected = status == 'connected';
      notifyListeners();
    });
  }

  void _listenToMessages() {
    _messageSubscription = _usbSerialRepository.messageStream.listen((message) {
      _lastReceivedMessage = message;
      notifyListeners();
    });
  }

  /// Get available USB devices
  Future<List<UsbDevice>> getAvailableDevices() async {
    return await _connectUseCase.getAvailableDevices();
  }

  /// Connect to USB device
  Future<void> connect({
    UsbDevice? device,
    int? baudRate,
    dynamic context,
  }) async {
    setLoading(true);
    clearError();

    try {
      await _connectUseCase.execute(
        device: device,
        baudRate: baudRate,
        context: context,
      );
    } catch (e) {
      setError('Failed to connect: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  /// Disconnect from USB device
  Future<void> disconnect() async {
    await _connectUseCase.disconnect();
    _dataSubscription?.cancel();
    _messageSubscription?.cancel();
    _statusSubscription?.cancel();
  }

  /// Check if connected
  bool isConnected() {
    return _connectUseCase.isConnected();
  }

  /// Listen to data stream
  void listenToData(Function(List<int>) onData) {
    _dataSubscription?.cancel();
    _dataSubscription = _usbSerialRepository.dataStream.listen(onData);
  }

  /// Listen to message stream
  void listenToMessages(Function(UsbSerialMessage) onMessage) {
    _messageSubscription?.cancel();
    _messageSubscription = _usbSerialRepository.messageStream.listen(onMessage);
  }

  /// Listen to connection status
  void listenToStatus(Function(String) onStatus) {
    _statusSubscription?.cancel();
    _statusSubscription = _usbSerialRepository.connectionStatusStream.listen(
      onStatus,
    );
  }

  /// Send command
  Future<void> sendCommand(String command) async {
    try {
      await _sendCommandUseCase.sendCommand(command);
    } catch (e) {
      setError('Failed to send command: ${e.toString()}');
    }
  }

  /// Send request
  Future<void> sendRequest(String request) async {
    try {
      await _sendCommandUseCase.sendRequest(request);
    } catch (e) {
      setError('Failed to send request: ${e.toString()}');
    }
  }

  /// Send light command
  Future<void> sendLightCommand(String deviceId, bool isOn) async {
    await _sendCommandUseCase.sendLightCommand(deviceId, isOn);
  }

  /// Send curtain command
  Future<void> sendCurtainCommand(String deviceId, String action) async {
    await _sendCommandUseCase.sendCurtainCommand(deviceId, action);
  }

  /// Request IP configuration
  Future<void> requestIpConfig() async {
    await _sendCommandUseCase.requestIpConfig();
  }

  /// Request floors count
  Future<void> requestFloorsCount() async {
    await _sendCommandUseCase.requestFloorsCount();
  }

  /// Request a specific floor
  Future<void> requestFloor(int floorNumber) async {
    await _sendCommandUseCase.requestFloor(floorNumber);
  }

  /// Send socket command
  Future<void> sendSocketCommand(String deviceId, bool isOn) async {
    await _sendCommandUseCase.sendSocketCommand(deviceId, isOn);
  }

  /// Send socket charge command
  Future<void> sendSocketChargeCommand(String deviceId) async {
    await _sendCommandUseCase.sendSocketChargeCommand(deviceId);
  }

  /// Send socket discharge command
  Future<void> sendSocketDischargeCommand(String deviceId) async {
    await _sendCommandUseCase.sendSocketDischargeCommand(deviceId);
  }

  /// Send elevator call command
  Future<void> sendElevatorCallCommand(String deviceId, int targetFloor) async {
    await _sendCommandUseCase.sendElevatorCallCommand(deviceId, targetFloor);
  }

  /// Send door lock command
  Future<void> sendDoorLockCommand(String deviceId, bool isLocked) async {
    await _sendCommandUseCase.sendDoorLockCommand(deviceId, isLocked);
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _messageSubscription?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }
}
