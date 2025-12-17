# Socket Communication Documentation

این فایل نحوه استفاده از ارتباطات Socket با سخت‌افزار را توضیح می‌دهد.

## ساختار

### 1. TcpSocketConnection
کلاس پایه برای اتصال TCP Socket که ارتباط مستقیم با سخت‌افزار را مدیریت می‌کند.

### 2. SocketService
سرویس Singleton که wrapper برای TcpSocketConnection است و Stream ها را برای دریافت داده و وضعیت اتصال فراهم می‌کند.

### 3. SocketRepository
Repository interface و implementation برای مدیریت ارتباطات Socket در لایه Domain.

## استفاده

### اتصال به سخت‌افزار

```dart
final socketViewModel = getIt<SocketViewModel>();

// اتصال با IP و Port پیش‌فرض
await socketViewModel.connect();

// اتصال با IP و Port مشخص
await socketViewModel.connect(
  ip: '192.168.1.100',
  port: 6269,
);
```

### ارسال دستورات

```dart
// ارسال دستور به صورت List<int>
socketViewModel.sendCommand([65, 66, 67]);

// ارسال دستور به صورت String
socketViewModel.sendCommandString('@M_IP');

// ارسال دستور روشن/خاموش کردن لامپ
socketViewModel.sendLightCommand('1', true); // روشن
socketViewModel.sendLightCommand('1', false); // خاموش

// ارسال دستور پرده
socketViewModel.sendCurtainCommand('1', 'open'); // باز کردن
socketViewModel.sendCurtainCommand('1', 'close'); // بستن
socketViewModel.sendCurtainCommand('1', 'stop'); // توقف

// درخواست تنظیمات IP
socketViewModel.requestIpConfig();

// درخواست تعداد طبقات
socketViewModel.requestFloorsCount();

// درخواست اطلاعات یک طبقه
socketViewModel.requestFloor(1);

// ارسال دستور سناریو
socketViewModel.sendScenarioCommand('1', 'general');
socketViewModel.sendScenarioCommand('1', 'floor');
socketViewModel.sendScenarioCommand('1', 'place');

// ارسال دستور شارژ تبلت
socketViewModel.sendSocketChargeCommand('1'); // شروع شارژ

// ارسال دستور دی‌شارژ تبلت
socketViewModel.sendSocketDischargeCommand('1'); // توقف شارژ (دی‌شارژ)

// ارسال دستور روشن/خاموش پریز
socketViewModel.sendSocketCommand('1', true); // روشن
socketViewModel.sendSocketCommand('1', false); // خاموش

// ارسال دستور پریز با action
socketViewModel.sendSocketActionCommand('1', 'charge'); // شارژ
socketViewModel.sendSocketActionCommand('1', 'discharge'); // دی‌شارژ
socketViewModel.sendSocketActionCommand('1', 'on'); // روشن
socketViewModel.sendSocketActionCommand('1', 'off'); // خاموش
```

### دریافت داده

```dart
// گوش دادن به داده‌های دریافتی
socketViewModel.dataStream.listen((data) {
  print('Data received: ${data.join('-')}');
});

// گوش دادن به وضعیت اتصال
socketViewModel.connectionStatusStream.listen((status) {
  print('Connection status: $status');
});
```

## پروتکل دستورات

### پیشوندهای دستورات

- `&` - Command
- `@` - Request
- `%` - Start IP Config
- `#` - Start Data
- `*` - Start Place
- `/` - New Object

### کدهای Headline

- `U` - Light
- `V` - Curtain
- `W` - Temperature
- `X` - Scenarios
- `X1` - Burglar Alarm
- `X2` - Cameras
- `Y` - Socket/Charger

### دستورات پرده

- `O` - Open
- `C` - Close
- `S` - Stop

### دستورات سناریو

- `!&` - General Scenario
- `!^` - Floor Scenario
- `!~` - Place Scenario

### دستورات پریز/شارژر

- `C` - Charge (شارژ)
- `D` - Discharge (دی‌شارژ)
- `O` - Off (خاموش)
- `1` - On (روشن)
- `0` - Off (خاموش)

## مثال کامل

```dart
class DeviceControlPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<SocketViewModel>(),
      child: Consumer<SocketViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            body: Column(
              children: [
                // نمایش وضعیت اتصال
                Text(viewModel.isConnected ? 'Connected' : 'Disconnected'),
                
                // دکمه اتصال
                ElevatedButton(
                  onPressed: () => viewModel.connect(),
                  child: Text('Connect'),
                ),
                
                // دکمه‌های کنترل
                ElevatedButton(
                  onPressed: viewModel.isConnected
                      ? () => viewModel.sendLightCommand('1', true)
                      : null,
                  child: Text('Turn On Light'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

## نکات مهم

1. همیشه قبل از ارسال دستور، وضعیت اتصال را بررسی کنید
2. از `SocketViewModel` برای مدیریت state استفاده کنید
3. برای دریافت داده‌ها از Stream ها استفاده کنید
4. در صورت قطع اتصال، از `reconnect()` استفاده کنید


