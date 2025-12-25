import 'package:bms/core/utils/globals.dart';
import 'package:bms/data/data_sources/local_data_sources/database/model/device.dart';
import 'package:bms/data/data_sources/remote_data_sources/socket/socket.dart';
import 'package:bms/domain/usecases/update_devices/update_devices_usecase_impl.dart';
import 'package:get/get.dart';

import '../../domain/usecases/send_data/send_data_socket_usecase.dart';
import '../../domain/usecases/send_data/send_data_socket_usecase_impl.dart';

class BaseLogic extends GetxController {
  final SendDataSocketUsecase _mSendDataSocket = SendDataSocketUsecaseImpl();

  renameDevice(Device device, String newName) {
    UpdateDeviceUseCaseImpl().renameDevice(device, newName);

    update();
  }

  sendMessageToSocket(String message) {
    if (Socket.instance.isConnected()) {
      _mSendDataSocket.sendString(message);
    } else {
      doLog('BaseLogic', 'sendMessageToSocket', 'Reject the request. message: $message');
    }
  }

  void doLog(String className, String methodName, String value) {
    doLogGlobal(className, methodName, value);
  }
}
