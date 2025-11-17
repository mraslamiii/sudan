class SocketConstants {
  SocketConstants._();

  // Default connection settings
  static const String defaultIp = '192.168.4.1';
  static const int defaultPort = 6269;

  // Command prefixes
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

  // Hidden device
  static const String hiddenDevice = 'z';

  // Request commands
  static const String requestIp = '${request + mode}_IP';
  static const String requestQueryFloorsCount = '${request + mode}_F_C';
  static const String requestAFloor = '${request + mode}_F_';
  static const String requestBurglarAlarms = '${request + headLineBurglarAlarm}Z';

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

  // Scenario commands
  static const String commandScenarioGeneral = '!&';
  static const String commandScenarioFloor = '!^';
  static const String commandScenarioPlace = '!~';

  // Timing constants
  static const int sendSocketByDelay = 500;
  static const int manageGettingConfigTimeOut = 60;
  static const int connectionRequestsDelay = 10;
  static const int requestChangeLightTimer = 300;
  static const int sendDataSocketDelay = 200;
  static const int placeLightsInitDelay = 500;
}

