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
- `@M_F_A` - درخواست لیست طبقات (صفحه اول اپ؛ پاسخ: آرایه JSON طبقات)
- `@M_R` - درخواست لیست اتاق‌ها (پاسخ: آرایه JSON اتاق‌ها)
- و غیره...

### درخواست لیست طبقات – صفحه اول (`@M_F_A`)

اپ در **صفحه اول** (لیست طبقات) وقتی USB متصل است، لیست طبقات را از میکرو درخواست می‌کند.

- **درخواست**: نوع پیام `msgTypeRequest` (0x02)، داده: `@M_F_A`
- **پاسخ**: نوع پیام `msgTypeResponse` (0x03)، داده: رشته JSON آرایهٔ طبقات

**فرمت پاسخ (JSON):**

```json
[
  {"id": "floor_1", "name": "طبقه اول", "order": 0, "roomIds": ["room_living", "room_kitchen"], "icon": "layers"},
  {"id": "floor_2", "name": "طبقه دوم", "order": 1, "roomIds": ["room_bedroom"], "icon": "layers"}
]
```

فیلدهای اختیاری: `icon` (پیش‌فرض: `layers`)، `roomIds` (پیش‌فرض: `[]`).

### ایجاد طبقه (Command + JSON)

وقتی کاربر در اپ یک **طبقه جدید** ایجاد می‌کند، اپ در صورت اتصال USB یک **Command** با دادهٔ JSON به میکرو می‌فرستد.

- **نوع پیام**: `msgTypeCommand` (0x01)
- **داده**: رشته JSON یک آبجکت با فیلد `action: "create_floor"` و بقیهٔ فیلدهای طبقه

**فرمت داده (JSON):**

```json
{
  "action": "create_floor",
  "id": "floor_3",
  "name": "طبقه سوم",
  "order": 2,
  "roomIds": [],
  "icon": "layers"
}
```

میکرو می‌تواند این پیام را با ACK تأیید کند و طبقه را در حافظهٔ خود ذخیره کند.

### درخواست لیست اتاق‌ها (`@M_R`)

اپلیکیشن هنگام اتصال USB و بارگذاری داشبورد، لیست اتاق‌ها را از میکرو درخواست می‌کند.

- **درخواست**: نوع پیام `msgTypeRequest` (0x02)، داده: `@M_R`
- **پاسخ**: نوع پیام `msgTypeResponse` (0x03)، داده: رشته JSON آرایهٔ اتاق‌ها

**فرمت پاسخ (JSON):**

```json
[
  {"id": "room_living", "name": "اتاق نشیمن", "order": 0, "floorId": "floor_1", "icon": "living", "deviceIds": [], "isGeneral": false},
  {"id": "room_kitchen", "name": "آشپزخانه", "order": 1, "floorId": "floor_1", "icon": "kitchen", "deviceIds": [], "isGeneral": false}
]
```

فیلدهای اختیاری: `icon` (پیش‌فرض: `home`)، `deviceIds` (پیش‌فرض: `[]`)، `isGeneral` (پیش‌فرض: `false`)، `imageUrl`. مقادیر مجاز `icon`: `living`, `bedroom`, `kitchen`, `bathroom`, `office`, `garage`, `garden`, `home`.

## تست بدون میکرو (تبلت به لپ‌تاپ)

### روش ۱: اتصال شبیه‌سازی (Debug)

وقتی اپ را در حالت **Debug** اجرا می‌کنید و تبلت با USB به لپ‌تاپ وصل است (بدون میکرو):

1. پنل USB Serial را در داشبورد باز کنید.
2. اگر «هیچ دستگاه USB یافت نشد» دیدید، دکمه **اتصال** را بزنید؛ در Debug همان دکمه اتصال شبیه‌سازی می‌کند.
3. پیام «اتصال شبیه‌سازی شد (تست)» را ببینید؛ لیست اتاق‌ها از Mock داخل اپ می‌آید.
4. داشبورد را رفرش یا دوباره باز کنید تا اتاق‌های شبیه‌سازی‌شده (عمومی، اتاق نشیمن، آشپزخانه، اتاق خواب) را ببینید.

با این روش می‌توانید بدون میکرو و بدون پورت سریال واقعی، جریان دیتا (درخواست/پاسخ اتاق‌ها) را تست کنید.

### روش ۲: شبیه‌ساز روی لپ‌تاپ (پورت سریال واقعی)

اگر تبلت را با **مبدل USB-Serial** به لپ‌تاپ وصل کنید (مثلاً تبلت ← OTG ← مبدل A ← کابل سریال ← مبدل B ← لپ‌تاپ)، می‌توانید میکرو را روی لپ‌تاپ شبیه‌سازی کنید:

1. نصب پایتون و pyserial:
   ```bash
   pip install pyserial
   ```
2. اجرای اسکریپت (پورت را با پورت واقعی عوض کنید؛ ویندوز: `COM3`، لینوکس: `/dev/ttyUSB0`):
   ```bash
   cd scripts
   python usb_serial_simulator.py COM3
   ```
3. در اپ روی تبلت به دستگاه USB متصل شوید و داشبورد را باز کنید؛ لیست اتاق‌ها از اسکریپت لپ‌تاپ می‌آید و در لاگ لپ‌تاپ «Sent rooms response» چاپ می‌شود.

با این روش می‌توانید مطمئن شوید دیتا واقعاً از پورت سریال می‌رود و برمی‌گردد.

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

