class ConnectSocketUseCase {
  final dynamic _socketRepository;

  ConnectSocketUseCase(this._socketRepository);

  Future<void> call({String? ip, int? port}) async {
    await _socketRepository.connect(ip: ip, port: port);
  }
}


