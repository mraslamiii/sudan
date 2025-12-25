class SocketConstants {
  static const String ip = '192.168.4.1';
  static const int port = 6269;

  static const command = '&';
  static const request = '@';
  static const startIpConfig = '%';
  static const startData = '#';
  static const startPlace = '*';
  static const newObject = '/';
  static const mode = 'M';
  static const floor = 'T';
  static const feedbackSetModemToDevice = '${request}M_S';
  static const feedbackSetModemIncorrectData = 'Error';
  static const feedbackSetModemNeedToTryAgain = 'Repeat';

  static const headLineLight = 'U';
  static const headLineCurtain = 'V';
  static const headLineTemperature = 'W';
  static const headLineScenarios = 'X';
  static const headLineCameras = 'X2';
  static const headLineBurglarAlarm = 'X1';

  static const hiddenDevice = 'z';

  //@M_IP
  static const requestIp = '${request + mode}_IP';

  //@M_F_C
  static const requestQueryFloorsCount = '${request + mode}_F_C';

  //@M_F_T◻️
  static const requestAFloor = '${request + mode}_F_';

  static const burglarAlarmIsOn = 'on';
  static const burglarAlarmIsOFF = 'of';
  static const requestBurglarAlarms = '${request + headLineBurglarAlarm}Z';

  static const curtainOpen = 'O';
  static const curtainClose = 'C';
  static const curtainStop = 'S';

  static const commandScenarioGeneral = '!&';
  static const commandScenarioFloor = '!^';
  static const commandScenarioPlace = '!~';

  static const sendSocketByDelay = 500;
  static const manageGettingConfigTimeOut = 60;
  static const connectionRequestsDelay = 10;
  static const requestChangeLightTimer = 300;
  static const sendDataSocketDelay = 200;
  static const placeLightsInitDelay = 500;
}
