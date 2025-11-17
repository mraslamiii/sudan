import '../../../core/constants/socket_constants.dart';

class SendSocketCommandUseCase {
  final dynamic _socketRepository;

  SendSocketCommandUseCase(this._socketRepository);

  /// Send command as List<int>
  void send(List<int> command) {
    _socketRepository.send(command);
  }

  /// Send command as String
  void sendString(String message) {
    _socketRepository.sendString(message);
  }

  /// Send light command
  void sendLightCommand(String deviceId, bool isOn) {
    final command = '${SocketConstants.command}${SocketConstants.headLineLight}$deviceId${isOn ? '1' : '0'}';
    sendString(command);
  }

  /// Send curtain command
  void sendCurtainCommand(String deviceId, String action) {
    String actionCode;
    switch (action.toLowerCase()) {
      case 'open':
        actionCode = SocketConstants.curtainOpen;
        break;
      case 'close':
        actionCode = SocketConstants.curtainClose;
        break;
      case 'stop':
        actionCode = SocketConstants.curtainStop;
        break;
      default:
        actionCode = SocketConstants.curtainStop;
    }
    final command = '${SocketConstants.command}${SocketConstants.headLineCurtain}$deviceId$actionCode';
    sendString(command);
  }

  /// Request IP configuration
  void requestIpConfig() {
    sendString(SocketConstants.requestIp);
  }

  /// Request floors count
  void requestFloorsCount() {
    sendString(SocketConstants.requestQueryFloorsCount);
  }

  /// Request a specific floor
  void requestFloor(int floorNumber) {
    sendString('${SocketConstants.requestAFloor}$floorNumber');
  }

  /// Send scenario command
  void sendScenarioCommand(String scenarioId, String type) {
    String command;
    switch (type.toLowerCase()) {
      case 'general':
        command = '${SocketConstants.commandScenarioGeneral}$scenarioId';
        break;
      case 'floor':
        command = '${SocketConstants.commandScenarioFloor}$scenarioId';
        break;
      case 'place':
        command = '${SocketConstants.commandScenarioPlace}$scenarioId';
        break;
      default:
        command = '${SocketConstants.commandScenarioGeneral}$scenarioId';
    }
    sendString(command);
  }
}


