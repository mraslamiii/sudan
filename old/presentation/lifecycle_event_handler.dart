import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../core/utils/globals.dart';
import '../data/data_sources/remote_data_sources/socket/connection_requests/connection_requests_impl.dart';
import '../data/data_sources/remote_data_sources/socket/socket.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  LifecycleEventHandler();

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.detached:
        await _manageAppOnDetached();
        break;
      case AppLifecycleState.resumed:
        _manageAppOnResumed();
        break;
      case AppLifecycleState.paused:
        _manageAppOnPaused();
        break;
      default:
        break;
    }
  }

  Future<void> _manageAppOnDetached() async {
    _logger('_manageAppOnDetached', 'Method Called');

    ConnectionRequestsImpl.instance.destroyConnections();

    await Get.deleteAll(force: true);
  }

  Future<void> _manageAppOnPaused() async {
    _logger('_manageAppOnPaused', 'Method Called');

    ConnectionRequestsImpl.instance.disconnect();
  }

  Future<void> _manageAppOnResumed() async {
    _logger('_manageAppOnResumed', 'Method Called');

      ConnectionRequestsImpl.instance.reconnectRequest();

  }

  void _logger(String key, String value) {
    doLogGlobal('lifecycle_event_handler. H:$hashCode', key, value);
  }
}
