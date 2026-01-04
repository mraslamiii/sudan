import '../../../core/utils/constants.dart';
import '../../../core/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/utils/globals.dart';
import '../../components/user_name_sheet.dart';
import '../../logic/splash_logic.dart';

class SplashScreen extends StatelessWidget {
  late SplashLogic logic;

  SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    logic = Get.put(SplashLogic());

    _checkLocationPermission();

    return GetBuilder<SplashLogic>(
      assignId: true,
      builder: (logic) {
        return Scaffold(
          body: Center(
            child: Lottie.asset('assets/lottie/splash.json', repeat: false),
          ),
        );
      },
    );
  }

  _checkLocationPermission() async {
    var permissionStatus = await Permission.locationWhenInUse.status;

    if (permissionStatus.isGranted) {
      _checkGetUsername();
    } else {
      _requestPermissions();
    }
  }

  _checkGetUsername() {
    enableGPS();
    Future.delayed(const Duration(milliseconds: Constants.splashScreenDelay), () {
      if (logic.isUserNameEmpty()) {
        showDialogUserName();
      } else {
        logic.goNextScreen();
      }
    });
  }

  void showDialogUserName() {
    showChangeUsernameSheet(callback: (userName) {
      if (!isUserNameValid(userName)) return;

      Navigator.pop(Get.context!);
      logic.storeUserName(userName);
      logic.goNextScreen();
      return;
    });
  }

  isUserNameValid(String userName) {
    if (userName.isEmpty) {
      Navigator.pop(Get.context!);
      Get.snackbar('خطا', 'باید نام را وارد کنید');
      return false;
    }
    return true;
  }

  _requestPermissions() async {
    await Permission.locationWhenInUse.onDeniedCallback(() {
      Get.snackbar('خطا', 'مجوزها اجباری است');
    }).onGrantedCallback(() {
      _checkGetUsername();
    }).request();
  }

  void _logger(String key, String value) {
    doLogGlobal('splash_screen.dart. H:$hashCode', key, value);
  }
}
