/// Constants for USB Serial communication protocol
class UsbSerialConstants {
  UsbSerialConstants._();

  // Default serial port settings
  static const int defaultBaudRate = 9600;
  static const int dataBits = 8;
  static const int stopBits = 1;
  static const int parity = 0; // 0 = None, 1 = Odd, 2 = Even

  // Protocol frame markers
  static const int frameStart = 0x02; // STX (Start of Text)
  static const int frameEnd = 0x03; // ETX (End of Text)
  static const int frameAck = 0x06; // ACK (Acknowledgment)
  static const int frameNack = 0x15; // NAK (Negative Acknowledgment)

  // Message types
  static const int msgTypeCommand = 0x01;
  static const int msgTypeRequest = 0x02;
  static const int msgTypeResponse = 0x03;
  static const int msgTypeHeartbeat = 0x04;
  static const int msgTypePushState = 0x05;

  // Heartbeat interval (milliseconds)
  static const int heartbeatInterval = 1000; // 1 second

  // Timeout settings (milliseconds)
  static const int ackTimeout = 2000; // 2 seconds
  static const int connectionTimeout = 5000; // 5 seconds

  // Command prefixes (compatible with existing SocketConstants)
  static const String command = '&';
  static const String request = '@';
  static const String startIpConfig = '%';
  static const String startData = '#';
  static const String startPlace = '*';
  static const String newObject = '/';
  static const String mode = 'M';
  static const String floor = 'T';

  // Headline codes
  static const String headLineLight = 'U';
  static const String headLineCurtain = 'V';
  static const String headLineTemperature = 'W';
  static const String headLineScenarios = 'X';
  static const String headLineCameras = 'X2';
  static const String headLineBurglarAlarm = 'X1';
  static const String headLineSocket = 'Y';
  static const String headLineElevator = 'E';
  static const String headLineDoorLock = 'L';

  // Hidden device
  static const String hiddenDevice = 'z';

  // Request commands
  static const String requestIp = '${request + mode}_IP';
  static const String requestQueryFloorsCount = '${request + mode}_F_C';
  static const String requestAFloor = '${request + mode}_F_';

  /// Request floor list (response: text lines, each line id|name|order|roomIds)
  static const String requestFloors = '${request + mode}_F_A';

  /// Create floor command: send one line id|name|order|roomIds (roomIds comma-sep)
  static const String commandCreateFloor = '${command + mode}_F_N';

  /// Update floor command: send one line id|name|order|roomIds
  static const String commandUpdateFloor = '${command + mode}_F_U';

  /// Delete floor command: send floor id (e.g. &M_F_D\nfloor_1 or &M_F_Dfloor_1)
  static const String commandDeleteFloor = '${command + mode}_F_D';

  /// Request room list for a floor: send this prefix + floorId (e.g. requestRoomsPrefix + 'floor_1').
  /// Micro returns only rooms of that floor (same line format).
  static const String requestRoomsPrefix = '${request + mode}_R';

  /// Create room command: send one line id|name|order|floorId|icon|deviceIds|isGeneral
  static const String commandCreateRoom = '${command + mode}_R_N';

  /// Update room command: send one line id|name|order|floorId|icon|deviceIds|isGeneral
  static const String commandUpdateRoom = '${command + mode}_R_U';

  /// Delete room command: send room id
  static const String commandDeleteRoom = '${command + mode}_R_D';

  // Text format delimiters (no JSON)
  static const String fieldSep = '|';
  static const String recordSep = '\n';
  static const String listSep = ',';
  static const String requestBurglarAlarms =
      '${request + headLineBurglarAlarm}Z';

  // Feedback
  static const String feedbackSetModemToDevice = '${request}M_S';
  static const String feedbackSetModemIncorrectData = 'Error';
  static const String feedbackSetModemNeedToTryAgain = 'Repeat';

  // Burglar alarm states
  static const String burglarAlarmIsOn = 'on';
  static const String burglarAlarmIsOff = 'of';

  // Curtain commands
  static const String curtainOpen = 'O';
  static const String curtainClose = 'C';
  static const String curtainStop = 'S';

  // Socket/Charger commands
  static const String socketCharge = 'C';
  static const String socketDischarge = 'D';
  static const String socketOff = 'O';

  // Elevator commands
  static const String elevatorCall = 'C';

  // Door lock commands
  static const String doorLockLock = 'L';
  static const String doorLockUnlock = 'U';

  // Scenario commands
  static const String commandScenarioGeneral = '!&';
  static const String commandScenarioFloor = '!^';
  static const String commandScenarioPlace = '!~';
}
