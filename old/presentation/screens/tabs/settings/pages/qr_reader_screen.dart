import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QRReaderScreen extends StatefulWidget {
  late Function(String ssid, String password) callback;

  QRReaderScreen(this.callback, {super.key});

  @override
  State<StatefulWidget> createState() => _QRReaderScreenState();
}

class _QRReaderScreenState extends State<QRReaderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          facing: CameraFacing.back,
        ),
        onDetect: (capture) {
          final Barcode barcode = capture.barcodes[0];
          // debugPrint('Barcode found! ${barcode.rawValue}');

          try {
            String ssid = barcode.rawValue!.substring(barcode.rawValue!.indexOf('S:') + 2,
                barcode.rawValue!.indexOf(';', barcode.rawValue!.indexOf('S:') + 2));
            String pass = barcode.rawValue!.substring(barcode.rawValue!.indexOf('P:') + 2,
                barcode.rawValue!.indexOf(';', barcode.rawValue!.indexOf('P:') + 2));

            widget.callback.call(ssid, pass);

            Get.back();
          } catch (e) {
            Get.snackbar('خطا', 'این کبو آر معتبر نمی باشد');
          }
        },
      ),
    );
  }
}
