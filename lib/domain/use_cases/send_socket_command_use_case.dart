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

  /// Send socket charge command
  /// Starts charging the tablet/device connected to the socket
  void sendSocketChargeCommand(String deviceId) {
    final command = '${SocketConstants.command}${SocketConstants.headLineSocket}$deviceId${SocketConstants.socketCharge}';
    sendString(command);
  }

  /// Send socket discharge command
  /// Starts discharging (stops charging) the tablet/device connected to the socket
  void sendSocketDischargeCommand(String deviceId) {
    final command = '${SocketConstants.command}${SocketConstants.headLineSocket}$deviceId${SocketConstants.socketDischarge}';
    sendString(command);
  }

  /// Send socket on/off command
  /// Controls the socket power state
  void sendSocketCommand(String deviceId, bool isOn) {
    final command = '${SocketConstants.command}${SocketConstants.headLineSocket}$deviceId${isOn ? '1' : '0'}';
    sendString(command);
  }

  /// Send socket command with action
  /// Supports: 'charge', 'discharge', 'on', 'off'
  void sendSocketActionCommand(String deviceId, String action) {
    String actionCode;
    switch (action.toLowerCase()) {
      case 'charge':
        actionCode = SocketConstants.socketCharge;
        break;
      case 'discharge':
        actionCode = SocketConstants.socketDischarge;
        break;
      case 'on':
        actionCode = '1';
        break;
      case 'off':
        actionCode = '0';
        break;
      default:
        actionCode = '0';
    }
    final command = '${SocketConstants.command}${SocketConstants.headLineSocket}$deviceId$actionCode';
    sendString(command);
  }

  /// Send elevator call command
  /// Calls the elevator to the specified floor
  void sendElevatorCallCommand(String deviceId, int targetFloor) {
    final command = '${SocketConstants.command}${SocketConstants.headLineElevator}$deviceId${SocketConstants.elevatorCall}$targetFloor';
    sendString(command);
  }

  /// Send door lock command
  /// Controls the door lock state (true = locked, false = unlocked)
  void sendDoorLockCommand(String deviceId, bool isLocked) {
    final actionCode = isLocked ? SocketConstants.doorLockLock : SocketConstants.doorLockUnlock;
    final command = '${SocketConstants.command}${SocketConstants.headLineDoorLock}$deviceId$actionCode';
    sendString(command);
  }

  /// Send door lock command with action
  /// Supports: 'lock' or 'unlock'
  void sendDoorLockActionCommand(String deviceId, String action) {
    String actionCode;
    switch (action.toLowerCase()) {
      case 'unlock':
        actionCode = SocketConstants.doorLockUnlock;
        break;
      case 'lock':
        actionCode = SocketConstants.doorLockLock;
        break;
      default:
        actionCode = SocketConstants.doorLockLock;
    }
    final command = '${SocketConstants.command}${SocketConstants.headLineDoorLock}$deviceId$actionCode';
    sendString(command);
  }
}


