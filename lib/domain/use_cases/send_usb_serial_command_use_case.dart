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

  /// Send LED color command
  /// Color format: RGB hex string (e.g., 'FF9500' for orange)
  Future<void> sendLEDColorCommand(String deviceId, String colorHex) async {
    // Remove # if present
    final cleanColor = colorHex.replaceAll('#', '');
    final command =
        '${UsbSerialConstants.command}${UsbSerialConstants.headLineLight}$deviceId${cleanColor}';
    await sendCommand(command);
  }

  /// Send LED brightness command (0-100)
  Future<void> sendLEDBrightnessCommand(String deviceId, int brightness) async {
    final clampedBrightness = brightness.clamp(0, 100);
    final command =
        '${UsbSerialConstants.command}${UsbSerialConstants.headLineLight}$deviceId${clampedBrightness.toString().padLeft(3, '0')}';
    await sendCommand(command);
  }

  /// Send curtain position command (0-100)
  Future<void> sendCurtainPositionCommand(String deviceId, int position) async {
    final clampedPosition = position.clamp(0, 100);
    String actionCode;
    if (clampedPosition == 0) {
      actionCode = UsbSerialConstants.curtainClose;
    } else if (clampedPosition == 100) {
      actionCode = UsbSerialConstants.curtainOpen;
    } else {
      // Send position as percentage
      actionCode = clampedPosition.toString().padLeft(3, '0');
    }
    final command =
        '${UsbSerialConstants.command}${UsbSerialConstants.headLineCurtain}$deviceId$actionCode';
    await sendCommand(command);
  }

  /// Send thermostat temperature command
  Future<void> sendThermostatTemperatureCommand(String deviceId, int temperature) async {
    final clampedTemp = temperature.clamp(10, 35);
    final command =
        '${UsbSerialConstants.command}${UsbSerialConstants.headLineTemperature}$deviceId${clampedTemp.toString().padLeft(2, '0')}';
    await sendCommand(command);
  }

  /// Send thermostat mode command (Auto, Cool, Heat)
  Future<void> sendThermostatModeCommand(String deviceId, String mode) async {
    String modeCode;
    switch (mode.toLowerCase()) {
      case 'auto':
        modeCode = 'A';
        break;
      case 'cool':
        modeCode = 'C';
        break;
      case 'heat':
        modeCode = 'H';
        break;
      default:
        modeCode = 'A';
    }
    final command =
        '${UsbSerialConstants.command}${UsbSerialConstants.headLineTemperature}$deviceId$modeCode';
    await sendCommand(command);
  }

  /// Send security system arm/disarm command
  Future<void> sendSecurityCommand(String deviceId, bool isArmed) async {
    final command =
        '${UsbSerialConstants.command}${UsbSerialConstants.headLineBurglarAlarm}$deviceId${isArmed ? '1' : '0'}';
    await sendCommand(command);
  }

  /// Send music play/pause command
  Future<void> sendMusicPlayPauseCommand(String deviceId, bool isPlaying) async {
    final command =
        '${UsbSerialConstants.command}${UsbSerialConstants.headLineScenarios}$deviceId${isPlaying ? 'P' : 'S'}';
    await sendCommand(command);
  }

  /// Send music previous track command
  Future<void> sendMusicPreviousCommand(String deviceId) async {
    final command =
        '${UsbSerialConstants.command}${UsbSerialConstants.headLineScenarios}$deviceId${'PREV'}';
    await sendCommand(command);
  }

  /// Send music next track command
  Future<void> sendMusicNextCommand(String deviceId) async {
    final command =
        '${UsbSerialConstants.command}${UsbSerialConstants.headLineScenarios}$deviceId${'NEXT'}';
    await sendCommand(command);
  }

  /// Send music volume command (0-100)
  Future<void> sendMusicVolumeCommand(String deviceId, int volume) async {
    final clampedVolume = volume.clamp(0, 100);
    final command =
        '${UsbSerialConstants.command}${UsbSerialConstants.headLineScenarios}$deviceId${'VOL'}${clampedVolume.toString().padLeft(3, '0')}';
    await sendCommand(command);
  }

  /// Send iPhone control command
  Future<void> sendIPhoneCommand(String deviceId, bool isActive) async {
    // iPhone commands might use a different protocol
    // Adjust based on actual protocol requirements
    final command =
        '${UsbSerialConstants.command}${UsbSerialConstants.headLineCameras}$deviceId${isActive ? '1' : '0'}';
    await sendCommand(command);
  }
}
