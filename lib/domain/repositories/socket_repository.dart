abstract class SocketRepository {
  Future<void> connect({String? ip, int? port});
  void disconnect();
  void reconnect();
  bool isConnected();
  void send(List<int> command);
  void sendString(String message);
  Stream<List<int>> get dataStream;
  Stream<String> get connectionStatusStream;
}


