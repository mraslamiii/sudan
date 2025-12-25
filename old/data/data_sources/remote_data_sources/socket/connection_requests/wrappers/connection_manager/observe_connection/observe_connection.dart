import 'dart:async';

import 'package:bms/data/data_sources/remote_data_sources/socket/socket.dart';
import 'package:bms/data/enums/connection_error_code.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../../../../../../../core/eventbus/event_bus_const.dart';
import '../../../../../../../../core/eventbus/event_bus_model.dart';
import '../../../../../../../../core/utils/globals.dart';

class ObserveConnection {
  late String? wifiBSSIDLookingFor;
  StreamSubscription<List<ConnectivityResult>>? _mSubscription;

  ObserveConnection();

  void subscribe(String? wifiBSSIDLookingFor) {
    this.wifiBSSIDLookingFor = wifiBSSIDLookingFor;
    _logger('_subscribeToWifiChanges', 'do subscription');
    _mSubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    _logger('_updateConnectionStatus1', 'Changed to: ${result.join('-')}');
    final networkInfo = NetworkInfo();

    if (result.last == ConnectivityResult.wifi) {
      String? wifiBSSID = await networkInfo.getWifiBSSID();

      if (wifiBSSID != null && wifiBSSID == wifiBSSIDLookingFor) {
        // Steel connecting
        // If socket is not connect in this place we could try
        _logger('_updateConnectionStatus', 'It\'s the right wifi');
      } else {
        // Disconnected
        _logger('_updateConnectionStatus', 'Unknown network');
        onDisconnected();
      }
    } else if (result.last == ConnectivityResult.mobile) {
      _logger('_updateConnectionStatus', 'On mobile internet');
    }
    else if (result.last == ConnectivityResult.vpn) {
      _logger('_updateConnectionStatus', 'On vpn internet');
    } else {
      // Disconnected
      _logger('_updateConnectionStatus', 'No wifi available');
      onDisconnected();
    }

// Get WiFi Details
    String? wifiName = await networkInfo.getWifiName();
    String? wifiBSSID = await networkInfo.getWifiBSSID();
    String? wifiIP = await networkInfo.getWifiIP();

    _logger('_subscribeToWifiChanges', 'wifiName: $wifiName wifiBSSID: $wifiBSSID wifiIP: $wifiIP');
  }

  void onDisconnected() {
    _logger('onDisconnected', 'onDisconnected called');
    if (Socket.instance.isConnected()) {
      cancel();

      eventBus.fire(EventBusModel(
          event: EventBusConst.eventSocketFailed, data: ConnectionErrorCode.wifiLost));
    }
  }

  void cancel() {
    _logger('cancel', 'Method called');
    _mSubscription?.cancel();
  }

  void _logger(String key, String value) {
    doLogGlobal('observe_connection. H:$hashCode', key, value);
  }
}
