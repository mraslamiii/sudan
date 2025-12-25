# تحلیل پوشه Old - معماری قبلی پروژه

## 📋 خلاصه کلی

این پوشه شامل نسخه قبلی (legacy) یک اپلیکیشن Flutter برای مدیریت سیستم هوشمند ساختمان (BMS - Building Management System) است. این پروژه از معماری Clean Architecture با الگوی MVVM استفاده می‌کند.

---

## 🏗️ معماری کلی

### الگوی معماری: Clean Architecture + MVVM

پروژه به 4 لایه اصلی تقسیم شده است:

1. **Presentation Layer** - رابط کاربری و منطق نمایش
2. **Domain Layer** - منطق کسب‌وکار و Use Cases
3. **Data Layer** - دسترسی به داده‌ها (Local & Remote)
4. **Core Layer** - ابزارها و امکانات مشترک

---

## 📁 ساختار پوشه‌ها

### 1. Core Layer (`core/`)

#### Dependency Injection (`di/`)
- **app_binding.dart**: تنظیمات GetX برای Dependency Injection
  - ثبت Repository ها
  - تنظیمات Dio برای API
  - مدیریت Logger

#### Event Bus (`eventbus/`)
- سیستم Event Bus برای ارتباط بین کامپوننت‌ها
- **event_bus_const.dart**: ثابت‌های رویدادها
- **event_bus_model.dart**: مدل رویدادها

#### Utils (`utils/`)
- **globals.dart**: متغیرهای سراسری و توابع لاگ
- **constants.dart**: ثابت‌های عمومی
- **communication_constants.dart**: ثابت‌های ارتباطی
- **extension.dart**: Extension Methods
- **util.dart**: توابع کمکی
- **my_iterable.dart**: Extension برای Iterable

#### Values (`values/`)
- **theme.dart**: تنظیمات تم و استایل
- **colors.dart**: رنگ‌های اپلیکیشن
- **translates.dart**: سیستم ترجمه (فارسی/انگلیسی)

---

### 2. Data Layer (`data/`)

#### Data Sources

**Local Data Sources:**
- **Database** (Floor ORM):
  - `app_database.dart`: دیتابیس اصلی با Floor
  - Entities: Location, Place, Device, Scenario, ScenarioDet, Logger
  - DAO ها برای دسترسی به جداول
- **Preferences**: ذخیره‌سازی ساده با GetStorage

**Remote Data Sources:**
- **API** (Dio):
  - `weather_api.dart`: API آب و هوا
  - `dio_client.dart`: تنظیمات HTTP Client
  - `token_interceptor.dart`: مدیریت توکن
- **Socket** (TCP):
  - `socket.dart`: Singleton برای اتصال TCP
  - `tcp_socket_connection.dart`: پیاده‌سازی اتصال
  - `connection_requests/`: مدیریت اتصال‌ها و دریافت داده

#### Models
- **Database Models**: Device, Location, Place, Scenario, Logger
- **API Models**: WeatherModel, WeatherCurrentModel
- **Parser Models**: headline.dart, parser_data_holder.dart

#### Repositories
- `device_repository.dart`: مدیریت دستگاه‌ها
- `location_repository.dart`: مدیریت مکان‌ها
- `scenario_repository.dart`: مدیریت سناریوها
- `weather_repository.dart`: اطلاعات آب و هوا
- `logger_repository.dart`: سیستم لاگ

#### Enums
- `device_code.dart`: کدهای دستگاه‌ها
- `floor_code.dart`: کدهای طبقات
- `place_code.dart`: کدهای مکان‌ها
- `headline_code.dart`: کدهای هدلاین‌ها
- `connection_error_code.dart`: کدهای خطای اتصال

---

### 3. Domain Layer (`domain/`)

#### Use Cases (31 فایل)

**مدیریت دستگاه‌ها:**
- `get_devices`: دریافت لیست دستگاه‌ها
- `update_devices`: به‌روزرسانی دستگاه‌ها
- `change_light_status`: تغییر وضعیت چراغ
- `update_curtain`: به‌روزرسانی پرده

**مدیریت سناریوها:**
- `get_scenario`: دریافت سناریوها
- `run_scenario`: اجرای سناریو
- `update_scenario`: به‌روزرسانی سناریو
- `remove_scenario`: حذف سناریو

**ارتباط و تنظیمات:**
- `send_data`: ارسال داده از طریق Socket
- `set_modem`: تنظیم مودم
- `extract_data`: استخراج داده
- `extract_ip_config`: استخراج تنظیمات IP
- `store_ip_config`: ذخیره تنظیمات IP
- `user_location`: مدیریت موقعیت کاربر

**سایر:**
- `get_weather`: دریافت اطلاعات آب و هوا

---

### 4. Presentation Layer (`presentation/`)

#### Screens

**صفحات اصلی:**
- `splash/splash_screen.dart`: صفحه اسپلش
- `tabs/main_screen.dart`: صفحه اصلی با Bottom Navigation
  - Home Tab
  - Scenarios Tab
  - Security Tab
  - Settings Tab

**صفحات فرعی:**
- `home/`: صفحات خانه (چراغ، پرده، دما، سناریو)
- `scenario/`: مدیریت سناریوها
- `security/`: امنیت
- `settings/`: تنظیمات (مکان‌ها، QR Reader)
- `logger/`: نمایش لاگ‌ها
- `error_gps/`: خطای GPS
- `notfound/`: صفحه خطا

#### Logic (ViewModels با GetX)

**Logic Classes:**
- `base_logic.dart`: کلاس پایه برای تمام Logic ها
- `home_logic.dart`: منطق صفحه اصلی
- `scenario_logic.dart`: منطق سناریوها
- `security_logic.dart`: منطق امنیت
- `settings_logic.dart`: منطق تنظیمات
- `locations_logic.dart`: منطق مکان‌ها
- `place_lights_logic.dart`: منطق چراغ‌های مکان
- `place_curtain_logic.dart`: منطق پرده‌های مکان
- `place_temperature_logic.dart`: منطق دمای مکان
- `place_scenarios_logic.dart`: منطق سناریوهای مکان
- `logger_logic.dart`: منطق لاگ
- `splash_logic.dart`: منطق اسپلش

#### Components (Widgets مشترک)
- `appbar.dart`: AppBar سفارشی
- `primary_button.dart`: دکمه اصلی
- `secondary_button.dart`: دکمه ثانویه
- `rita_text_field.dart`: فیلد متنی سفارشی
- `logout_bottom_sheet.dart`: Bottom Sheet خروج
- `user_name_sheet.dart`: Bottom Sheet نام کاربر

#### Lifecycle
- `lifecycle_event_handler.dart`: مدیریت چرخه حیات اپلیکیشن
  - مدیریت اتصال Socket هنگام Pause/Resume
  - پاکسازی منابع هنگام Detach

---

## 🔧 تکنولوژی‌ها و کتابخانه‌ها

### State Management
- **GetX**: مدیریت state، navigation، و dependency injection

### Database
- **Floor**: ORM برای SQLite
- **GetStorage**: ذخیره‌سازی ساده

### Networking
- **Dio**: HTTP Client
- **TCP Socket**: اتصال مستقیم TCP برای ارتباط با پنل

### UI
- **Sizer**: مدیریت اندازه‌ها
- **Iconsax**: آیکون‌ها
- **Flutter SVG**: نمایش SVG
- **Fluttertoast**: نمایش Toast

### Localization
- **GetX Translations**: سیستم ترجمه
- پشتیبانی از فارسی و انگلیسی

---

## 🔄 جریان داده (Data Flow)

```
Socket/API → Remote Data Source → Repository → Use Case → Logic (ViewModel) → Screen
                                                              ↓
                                                         Local Database
```

### مثال: دریافت دستگاه‌ها
1. **Socket** داده را دریافت می‌کند
2. **Connection Manager** داده را پردازش می‌کند
3. **Repository** داده را در دیتابیس ذخیره می‌کند
4. **Use Case** داده را از Repository می‌گیرد
5. **Logic** Use Case را فراخوانی می‌کند
6. **Screen** از Logic داده را دریافت و نمایش می‌دهد

---

## 🎯 ویژگی‌های کلیدی

### 1. مدیریت اتصال Socket
- اتصال TCP به پنل هوشمند
- مدیریت خودکار reconnect
- مدیریت lifecycle (pause/resume)
- Cache برای اتصال‌ها

### 2. سیستم GPS
- بررسی فعال بودن GPS
- مدیریت خطاهای GPS

### 3. مدیریت مکان‌ها
- چند مکان (Location)
- چند طبقه (Floor)
- چند مکان در هر طبقه (Place)

### 4. کنترل دستگاه‌ها
- چراغ‌ها (Lights)
- پرده‌ها (Curtains)
- دما (Temperature)
- آسانسور (Elevator)
- دزدگیر (Burglar Alarm)

### 5. سناریوها
- ایجاد سناریو
- اجرای سناریو
- ویرایش سناریو
- حذف سناریو

### 6. سیستم لاگ
- لاگ کامل عملیات
- ذخیره در دیتابیس
- صفحه نمایش لاگ‌ها

---

## ⚠️ نکات مهم

### مشکلات احتمالی:
1. **WillPopScope** deprecated است (باید از `PopScope` استفاده شود)
2. استفاده از Singleton برای Socket ممکن است مشکلاتی ایجاد کند
3. مدیریت State با GetX ممکن است در پروژه‌های بزرگ پیچیده شود
4. عدم استفاده از Repository Pattern به صورت کامل (برخی Repository ها مستقیماً از DAO استفاده می‌کنند)

### نقاط قوت:
1. ✅ معماری Clean Architecture
2. ✅ جداسازی Concerns
3. ✅ استفاده از Use Cases
4. ✅ مدیریت مناسب Lifecycle
5. ✅ سیستم لاگ جامع

---

## 📊 آمار پروژه

- **تعداد Use Cases**: 31
- **تعداد Screens**: ~21
- **تعداد Logic Classes**: 16
- **تعداد Repositories**: 8
- **تعداد Data Sources**: 11+
- **تعداد Models**: 8+

---

## 🔄 مقایسه با نسخه جدید

این پوشه `old` احتمالاً نسخه قبلی پروژه است که در حال بازنویسی یا بهبود است. نسخه جدید در پوشه اصلی (`lib/`) قرار دارد و احتمالاً:
- معماری بهبود یافته‌ای دارد
- از پکیج‌های جدیدتری استفاده می‌کند
- کد تمیزتر و بهینه‌تری دارد

---

## 📝 نتیجه‌گیری

این پوشه یک پیاده‌سازی کامل از یک سیستم مدیریت ساختمان هوشمند است که:
- از معماری Clean Architecture استفاده می‌کند
- ارتباط Real-time با پنل از طریق TCP Socket دارد
- مدیریت کامل دستگاه‌ها، سناریوها و مکان‌ها را فراهم می‌کند
- سیستم لاگ و مدیریت خطا دارد

این کد می‌تواند به عنوان مرجع برای درک منطق کسب‌وکار و جریان داده استفاده شود.


