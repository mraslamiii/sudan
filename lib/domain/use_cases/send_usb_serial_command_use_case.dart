import '../../../core/constants/usb_serial_constants.dart';
import '../repositories/usb_serial_repository.dart';

class SendUsbSerialCommandUseCase {
  final UsbSerialRepository _usbSerialRepository;

  SendUsbSerialCommandUseCase(this._usbSerialRepository);

  /// Send command as String (compatible with existing socket commands)
  Future<void> sendCommand(String command) async {
    await _usbSerialRepository.sendCommand(command);
  }

  /// Send request as String (compatible with existing socket requests)
  Future<void> sendRequest(String request) async {
    await _usbSerialRepository.sendRequest(request);
  }

  /// Send light command
  Future<void> sendLightCommand(String deviceId, bool isOn) async {
    final command =
        '${UsbSerialConstants.command}${UsbSerialConstants.headLineLight}$deviceId${isOn ? '1' : '0'}';
    await sendCommand(command);
  }

  /// Send curtain command
  Future<void> sendCurtainCommand(String deviceId, String action) async {
    String actionCode;
    switch (action.toLowerCase()) {
      case 'open':
        actionCode = UsbSerialConstants.curtainOpen;
        break;
      case 'close':
        actionCode = UsbSerialConstants.curtainClose;
        break;
      case 'stop':
        actionCode = UsbSerialConstants.curtainStop;
        break;
      default:
        actionCode = UsbSerialConstants.curtainStop;
    }
    final command =
        '${UsbSerialConstants.command}${UsbSerialConstants.headLineCurtain}$deviceId$actionCode';
    await sendCommand(command);
  }

  /// Request IP configuration
  Future<void> requestIpConfig() async {
    await sendRequest(UsbSerialConstants.requestIp);
  }

  /// Request floors count
  Future<void> requestFloorsCount() async {
    await sendRequest(UsbSerialConstants.requestQueryFloorsCount);
  }

  /// Request a specific floor
  Future<void> requestFloor(int floorNumber) async {
    await sendRequest('${UsbSerialConstants.requestAFloor}$floorNumber');
  }

  /// Send scenario command
  Future<void> sendScenarioCommand(String scenarioId, String type) async {
    String command;
    switch (type.toLowerCase()) {
      case 'general':
        command = '${UsbSerialConstants.commandScenarioGeneral}$scenarioId';
        break;
      case 'floor':
        command = '${UsbSerialConstants.commandScenarioFloor}$scenarioId';
        break;
      case 'place':
        command = '${UsbSerialConstants.commandScenarioPlace}$scenarioId';
        break;
      default:
        command = '${UsbSerialConstants.commandScenarioGeneral}$scenarioId';
    }
    await sendCommand(command);
  }

  /// Send socket charge command
  Future<void> sendSocketChargeCommand(String deviceId) async {
    final command =
        '${UsbSerialConstants.command}${UsbSerialConstants.headLineSocket}$deviceId${UsbSerialConstants.socketCharge}';
    await sendCommand(command);
  }

  /// Send socket discharge command
  Future<void> sendSocketDischargeCommand(String deviceId) async {
    final command =
        '${UsbSerialConstants.command}${UsbSerialConstants.headLineSocket}$deviceId${UsbSerialConstants.socketDischarge}';
    await sendCommand(command);
  }

  /// Send socket on/off command
  Future<void> sendSocketCommand(String deviceId, bool isOn) async {
    final command =
        '${UsbSerialConstants.command}${UsbSerialConstants.headLineSocket}$deviceId${isOn ? '1' : '0'}';
    await sendCommand(command);
  }

  /// Send socket command with action
  Future<void> sendSocketActionCommand(String deviceId, String action) async {
    String actionCode;
    switch (action.toLowerCase()) {
      case 'charge':
        actionCode = UsbSerialConstants.socketCharge;
        break;
      case 'discharge':
        actionCode = UsbSerialConstants.socketDischarge;
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
    final command =
        '${UsbSerialConstants.command}${UsbSerialConstants.headLineSocket}$deviceId$actionCode';
    await sendCommand(command);
  }

  /// Send elevator call command
  Future<void> sendElevatorCallCommand(String deviceId, int targetFloor) async {
    final command =
        '${UsbSerialConstants.command}${UsbSerialConstants.headLineElevator}$deviceId${UsbSerialConstants.elevatorCall}$targetFloor';
    await sendCommand(command);
  }

  /// Send door lock command
  Future<void> sendDoorLockCommand(String deviceId, bool isLocked) async {
    final actionCode = isLocked
        ? UsbSerialConstants.doorLockLock
        : UsbSerialConstants.doorLockUnlock;
    final command =
        '${UsbSerialConstants.command}${UsbSerialConstants.headLineDoorLock}$deviceId$actionCode';
    await sendCommand(command);
  }

  /// Send door lock command with action
  Future<void> sendDoorLockActionCommand(String deviceId, String action) async {
    String actionCode;
    switch (action.toLowerCase()) {
      case 'unlock':
        actionCode = UsbSerialConstants.doorLockUnlock;
        break;
      case 'lock':
        actionCode = UsbSerialConstants.doorLockLock;
        break;
      default:
        actionCode = UsbSerialConstants.doorLockLock;
    }
    final command =
        '${UsbSerialConstants.command}${UsbSerialConstants.headLineDoorLock}$deviceId$actionCode';
    await sendCommand(command);
  }
}
