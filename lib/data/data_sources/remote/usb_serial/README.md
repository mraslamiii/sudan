# USB Serial Communication

این ماژول ارتباط USB Serial بین تبلت و میکروکنترلر را از طریق OTG پیاده‌سازی می‌کند.

## ویژگی‌ها

- ✅ ارتباط USB Serial از طریق OTG
- ✅ پشتیبانی از مبدل‌های USB-to-Serial (CH340, FT232, و غیره)
- ✅ پروتکل ارتباطی با فریم‌بندی
- ✅ ACK/NACK برای تأیید دریافت
- ✅ Heartbeat (پینگ هر 1 ثانیه)
- ✅ Push State از میکروکنترلر
- ✅ سازگار با دستورات موجود Socket

## نحوه استفاده

### 1. دریافت دستگاه‌های USB موجود

```dart
final usbSerialVM = getIt<UsbSerialViewModel>();
final devices = await usbSerialVM.getAvailableDevices();
```

### 2. اتصال به میکروکنترلر

```dart
// اتصال به اولین دستگاه موجود
await usbSerialVM.connect();

// یا اتصال به دستگاه خاص
await usbSerialVM.connect(
  device: selectedDevice,
  baudRate: 9600, // اختیاری
  context: context, // برای Android permission (اختیاری)
);
```

### 3. ارسال دستورات

```dart
// ارسال دستور روشن/خاموش لامپ
await usbSerialVM.sendLightCommand('device_id', true);

// ارسال دستور پرده
await usbSerialVM.sendCurtainCommand('device_id', 'open');

// درخواست IP
await usbSerialVM.requestIpConfig();

// درخواست تعداد طبقات
await usbSerialVM.requestFloorsCount();
```

### 4. گوش دادن به داده‌های دریافتی

```dart
// گوش دادن به داده‌های خام
usbSerialVM.listenToData((data) {
  print('Data received: $data');
});

// گوش دادن به پیام‌های decode شده
usbSerialVM.listenToMessages((message) {
  if (message.isPushState) {
    // پردازش تغییرات وضعیت از میکروکنترلر
    print('State update: ${message.data}');
  }
});

// گوش دادن به وضعیت اتصال
usbSerialVM.listenToStatus((status) {
  print('Connection status: $status');
});
```

### 5. قطع اتصال

```dart
await usbSerialVM.disconnect();
```

## پروتکل ارتباطی

### فرمت فریم

```
[STX][Type][Length][Data...][Checksum][ETX]
```

- **STX**: 0x02 (Start of Text)
- **ETX**: 0x03 (End of Text)
- **Type**: نوع پیام (Command, Request, Response, Heartbeat, PushState)
- **Length**: طول داده
- **Data**: داده‌های پیام
- **Checksum**: مجموع کنترل

### انواع پیام

- `msgTypeCommand` (0x01): دستورات
- `msgTypeRequest` (0x02): درخواست‌ها
- `msgTypeResponse` (0x03): پاسخ‌ها
- `msgTypeHeartbeat` (0x04): پینگ
- `msgTypePushState` (0x05): ارسال وضعیت از میکروکنترلر

### ACK/NACK

- **ACK** (0x06): تأیید دریافت
- **NACK** (0x15): عدم تأیید

## تنظیمات پیش‌فرض

- **Baud Rate**: 9600
- **Data Bits**: 8
- **Stop Bits**: 1
- **Parity**: None
- **Heartbeat Interval**: 1000ms (1 ثانیه)
- **ACK Timeout**: 2000ms (2 ثانیه)

## سازگاری با دستورات Socket

تمام دستورات موجود در `SocketConstants` با USB Serial نیز سازگار هستند:

- `&U...` - دستورات لامپ
- `&V...` - دستورات پرده
- `@M_IP` - درخواست IP
- `@M_F_C` - درخواست تعداد طبقات
- و غیره...

## نکات مهم

1. **Android Permission**: برای Android ممکن است نیاز به درخواست مجوز USB باشد
2. **OTG Support**: تبلت باید از OTG پشتیبانی کند
3. **Driver**: مبدل USB-to-Serial باید درایور مناسب داشته باشد
4. **Heartbeat**: اتصال به صورت خودکار با Heartbeat بررسی می‌شود

## مثال کامل

```dart
import 'package:provider/provider.dart';
import 'package:sudan/core/di/injection_container.dart';
import 'package:sudan/presentation/viewmodels/usb_serial_viewmodel.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late UsbSerialViewModel usbSerialVM;

  @override
  void initState() {
    super.initState();
    usbSerialVM = getIt<UsbSerialViewModel>();
    
    // گوش دادن به وضعیت اتصال
    usbSerialVM.listenToStatus((status) {
      print('USB Serial Status: $status');
    });
    
    // گوش دادن به پیام‌ها
    usbSerialVM.listenToMessages((message) {
      if (message.isPushState) {
        // پردازش تغییرات وضعیت
        handleStateUpdate(message.data);
      }
    });
  }

  Future<void> connectToMicrocontroller() async {
    try {
      final devices = await usbSerialVM.getAvailableDevices();
      if (devices.isNotEmpty) {
        await usbSerialVM.connect(device: devices.first);
        print('Connected to microcontroller');
      }
    } catch (e) {
      print('Connection error: $e');
    }
  }

  Future<void> sendLightCommand() async {
    await usbSerialVM.sendLightCommand('light_001', true);
  }

  @override
  void dispose() {
    usbSerialVM.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: connectToMicrocontroller,
            child: Text('Connect'),
          ),
          ElevatedButton(
            onPressed: sendLightCommand,
            child: Text('Turn On Light'),
          ),
        ],
      ),
    );
  }
}
```

