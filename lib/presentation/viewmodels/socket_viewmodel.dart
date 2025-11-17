import 'dart:async';
import '../../../core/base/base_viewmodel.dart';
import '../../../domain/repositories/socket_repository.dart';
import '../../../domain/use_cases/connect_socket_use_case.dart';
import '../../../domain/use_cases/send_socket_command_use_case.dart';

class SocketViewModel extends BaseViewModel {
  final SocketRepository _socketRepository;
  final ConnectSocketUseCase _connectSocketUseCase;
  final SendSocketCommandUseCase _sendSocketCommandUseCase;

  StreamSubscription<List<int>>? _dataSubscription;
  StreamSubscription<String>? _statusSubscription;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  List<int>? _lastReceivedData;
  List<int>? get lastReceivedData => _lastReceivedData;

  String _connectionStatus = 'disconnected';
  String get connectionStatus => _connectionStatus;

  SocketViewModel(
    this._socketRepository,
    this._connectSocketUseCase,
    this._sendSocketCommandUseCase,
  ) {
    _listenToConnectionStatus();
    _listenToData();
  }

  void _listenToConnectionStatus() {
    _statusSubscription = _socketRepository.connectionStatusStream.listen(
      (status) {
        _connectionStatus = status;
        _isConnected = status == 'connected';
        notifyListeners();
      },
    );
  }

  void _listenToData() {
    _dataSubscription = _socketRepository.dataStream.listen(
      (data) {
        _lastReceivedData = data;
        notifyListeners();
      },
    );
  }

  Future<void> connect({String? ip, int? port}) async {
    setLoading(true);
    clearError();

    try {
      await _connectSocketUseCase(ip: ip, port: port);
    } catch (e) {
      setError('Failed to connect: ${e.toString()}');
    } finally {
      setLoading(false);
    }
  }

  void disconnect() {
    _socketRepository.disconnect();
  }

  void reconnect() {
    _socketRepository.reconnect();
  }

  void sendCommand(List<int> command) {
    try {
      _sendSocketCommandUseCase.send(command);
    } catch (e) {
      setError('Failed to send command: ${e.toString()}');
    }
  }

  void sendCommandString(String message) {
    try {
      _sendSocketCommandUseCase.sendString(message);
    } catch (e) {
      setError('Failed to send command: ${e.toString()}');
    }
  }

  void sendLightCommand(String deviceId, bool isOn) {
    try {
      _sendSocketCommandUseCase.sendLightCommand(deviceId, isOn);
    } catch (e) {
      setError('Failed to send light command: ${e.toString()}');
    }
  }

  void sendCurtainCommand(String deviceId, String action) {
    try {
      _sendSocketCommandUseCase.sendCurtainCommand(deviceId, action);
    } catch (e) {
      setError('Failed to send curtain command: ${e.toString()}');
    }
  }

  void requestIpConfig() {
    try {
      _sendSocketCommandUseCase.requestIpConfig();
    } catch (e) {
      setError('Failed to request IP config: ${e.toString()}');
    }
  }

  void requestFloorsCount() {
    try {
      _sendSocketCommandUseCase.requestFloorsCount();
    } catch (e) {
      setError('Failed to request floors count: ${e.toString()}');
    }
  }

  void requestFloor(int floorNumber) {
    try {
      _sendSocketCommandUseCase.requestFloor(floorNumber);
    } catch (e) {
      setError('Failed to request floor: ${e.toString()}');
    }
  }

  void sendScenarioCommand(String scenarioId, String type) {
    try {
      _sendSocketCommandUseCase.sendScenarioCommand(scenarioId, type);
    } catch (e) {
      setError('Failed to send scenario command: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _statusSubscription?.cancel();
    super.dispose();
  }
}


