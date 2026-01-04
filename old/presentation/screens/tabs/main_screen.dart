import '../../../core/utils/extension.dart';
import '../../../core/values/theme.dart';
import '../../../double_back_exit.dart';
import '../../../presentation/logic/home_logic.dart';
import '../../../presentation/logic/security_logic.dart';
import '../../../presentation/logic/settings_logic.dart';
import '../../../presentation/screens/tabs/scenario/scenarios_screen.dart';
import '../../../presentation/screens/tabs/security/security_screen.dart';
import '../../../presentation/screens/tabs/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/utils/globals.dart';
import '../../logic/scenario_logic.dart';
import 'home/home_screen.dart';

class MainScreen extends StatefulWidget {
  int currentTab = 0;
  late final HomeScreen _homeScreen = HomeScreen();

  late final ScenariosScreen _scenariosScreen = ScenariosScreen();

  late final SecurityScreen _securityScreen = SecurityScreen();

  late final SettingsScreen _settingsScreen = SettingsScreen();

  MainScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  setScreen(int index) {
    switch (index) {
      case 0:
        return widget._homeScreen;

      case 1:
        return widget._scenariosScreen;

      case 2:
        return widget._securityScreen;

      case 3:
        return widget._settingsScreen;
    }
  }
  @override
  void dispose() async{
    super.dispose();
    doLogGlobal('main_screen', 'dispose', 'Method called');

 var homeStatus =  await  Get.delete<HomeLogic>();
    doLogGlobal('main_screen', 'dispose', 'HomeLogic $homeStatus');

    var scenarioStatus = await Get.delete<ScenarioLogic>();
    doLogGlobal('main_screen', 'dispose', 'ScenarioLogic $scenarioStatus');

    var securityStatus =  await  Get.delete<SecurityLogic>();
    doLogGlobal('main_screen', 'dispose', 'SecurityLogic $securityStatus');

    var settingsStatus = await  Get.delete<SettingsLogic>();
    doLogGlobal('main_screen', 'dispose', 'SettingsLogic $settingsStatus');


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DoubleBackExitApp(
        child: Stack(
          children: List<Widget>.generate(
            4,
            (index) {
              return IgnorePointer(
                ignoring: widget.currentTab != index,
                child: Opacity(
                  opacity: widget.currentTab == index ? 1 : 0,
                  child: setScreen(index),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        backgroundColor: AppTheme().cardBackground,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.all(4.0.dp),
                child: const Icon(Iconsax.home_2),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.all(4.0.dp),
                child: const Icon(Iconsax.home_2),
              ),
              label: 'home'.tr),
          BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.all(4.0.dp),
                child: const Icon(Iconsax.video_square),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.all(4.0.dp),
                child: const Icon(Iconsax.video_square),
              ),
              label: 'scenarios'.tr),
          BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.all(4.0.dp),
                child: const Icon(Iconsax.security),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.all(4.0.dp),
                child: const Icon(Iconsax.security),
              ),
              label: 'security'.tr),
          BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.all(4.0.dp),
                child: const Icon(Iconsax.setting),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.all(4.0.dp),
                child: const Icon(Iconsax.setting),
              ),
              label: 'settings'.tr),
        ],
        currentIndex: widget.currentTab,
        unselectedItemColor: AppTheme().textColor2,
        selectedItemColor: AppTheme().textColor1,
        unselectedFontSize: 10.0.sp,
        selectedFontSize: 10.0.sp,
        onTap: onItemTapped,
      ),
    );
  }

  void onItemTapped(int index) {
    setState(() {
      widget.currentTab = index;
    });
  }
}
